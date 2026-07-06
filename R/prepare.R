# Internal helpers shared by the plotting functions.

#' Compute cumulative genome coordinates for a validated GWAS frame
#'
#' Adds the columns needed to lay chromosomes out end-to-end along a single
#' axis: `neg_log10_p`, a cumulative x-position (`cum_pos`) and an alternating
#' `chr_band` flag for colouring. Also returns, as attributes, the per-chrom
#' axis tick centres and the chromosome boundaries.
#'
#' @param data A data frame that has already passed [validate_gwas()].
#' @param gap Fraction of the total genome length to insert as padding between
#'   chromosomes (default `0.005`).
#'
#' @return `data` with extra columns, plus attributes `"chr_centers"` (named
#'   numeric of tick positions) and `"chr_max"` (cumulative end of each chrom).
#' @keywords internal
#' @noRd
.prepare_manhattan <- function(data, gap = 0.005) {
  data$CHR <- droplevels(data$CHR)
  chr_levels <- levels(data$CHR)

  # Per-chromosome span; add a small gap between chromosomes.
  chr_max <- tapply(data$POS, data$CHR, max, na.rm = TRUE)
  chr_max <- chr_max[chr_levels]
  total <- sum(chr_max)
  pad <- gap * total

  offsets <- c(0, cumsum(chr_max[-length(chr_max)] + pad))
  names(offsets) <- chr_levels

  data$cum_pos <- data$POS + offsets[as.character(data$CHR)]
  data$neg_log10_p <- -log10(data$P)
  data$chr_band <- (match(as.character(data$CHR), chr_levels) %% 2L) == 1L

  centers <- offsets + chr_max / 2
  ends <- offsets + chr_max

  attr(data, "chr_centers") <- centers
  attr(data, "chr_ends") <- ends
  data
}

#' Select top markers from a validated GWAS frame
#'
#' Resolves a highlight specification into a subset of `data`. Used by all
#' plotting functions and by the (Phase 4) top-hits table.
#'
#' @param data A data frame that has passed [validate_gwas()].
#' @param top_n Integer; keep the `top_n` markers with the smallest p-values.
#'   Applied per group when `by` is supplied.
#' @param threshold Numeric p-value; keep markers with `P <= threshold`.
#' @param snps,genes Character vectors of `SNP` ids / `gene` names to keep.
#' @param by Optional column name to group by before taking `top_n`
#'   (e.g. `"trait"` for multi-trait data, or `"CHR"` for one hit per chrom).
#'
#' @return A subset of `data` (same columns), ordered by p-value. When several
#'   selection criteria are given they are combined with a union.
#' @keywords internal
#' @noRd
.select_top <- function(data, top_n = NULL, threshold = NULL,
                        snps = NULL, genes = NULL, by = NULL) {
  idx <- logical(nrow(data))

  if (!is.null(threshold)) idx <- idx | (data$P <= threshold)
  if (!is.null(snps))      idx <- idx | (data$SNP %in% snps)
  if (!is.null(genes) && "gene" %in% names(data)) {
    idx <- idx | (data$gene %in% genes)
  }

  if (!is.null(top_n)) {
    if (!is.null(by) && by %in% names(data)) {
      grp <- data[[by]]
      for (g in unique(grp)) {
        rows <- which(grp == g)
        ord <- rows[order(data$P[rows])]
        idx[utils::head(ord, top_n)] <- TRUE
      }
    } else {
      ord <- order(data$P)
      idx[utils::head(ord, top_n)] <- TRUE
    }
  }

  out <- data[idx, , drop = FALSE]
  out[order(out$P), , drop = FALSE]
}
