# --- Large-GWAS helpers -----------------------------------------------------
# Genome-wide studies can carry tens of millions of SNPs, which overwhelms
# ggplot2 (a grob per point) and browsers (an SVG node per point). gwasplot
# handles this with three composable ideas, all switched on by `big_data =
# TRUE` in the plot functions:
#   1. fast prep      -- integer-coded genome layout (see prepare.R)
#   2. rasterisation  -- draw the point layer as a bitmap (scattermore)
#   3. thinning       -- keep every hit, sub-sample the null background
# thin_gwas() below is the thinning step, exported for direct use.

#' Thin a large GWAS data frame for plotting
#'
#' Reduces a very large GWAS table to a manageable number of points while
#' preserving its appearance and *every* interesting association. All markers
#' with `P <= keep_below` are kept unconditionally; the dense null background is
#' grid-thinned --- the genome (x) by \eqn{-\log_{10}(P)} (y) plane is divided
#' into cells and one representative point is kept per cell --- and, if still
#' above budget, randomly sub-sampled down to `max_points`. The number of
#' dropped markers is reported with a message (never silently).
#'
#' This is what `big_data = TRUE` uses for interactive plots, where the whole
#' data cannot become SVG nodes. For static plots, rasterisation
#' (`raster = TRUE`) is usually preferable because it keeps all points.
#'
#' @param data A GWAS data frame (passed through [validate_gwas()]).
#' @param max_points Approximate upper bound on the number of retained markers.
#' @param keep_below Keep every marker with `P` at or below this value,
#'   regardless of budget (default `1e-2`).
#' @param n_pos_bins,n_p_bins Grid resolution for thinning the background: the
#'   number of position bins along the genome and \eqn{-\log_{10}(P)} bins.
#' @param seed Optional integer seed for the random sub-sampling step.
#'
#' @return A [tibble][tibble::tibble] --- the thinned subset of `data`, with an
#'   attribute `"thinned_from"` recording the original row count.
#' @seealso [gwas_manhattan()] (`big_data` argument)
#' @export
#'
#' @examples
#' big <- simulate_gwas(n_chr = 22, snps_per_chr = 5000, seed = 1)
#' nrow(big)
#' small <- thin_gwas(big, max_points = 5000)
#' nrow(small)
thin_gwas <- function(data,
                      max_points = 2e5,
                      keep_below = 1e-2,
                      n_pos_bins = 1500,
                      n_p_bins = 300,
                      seed = NULL) {
  data <- validate_gwas(data)
  .thin_validated(data, max_points, keep_below, n_pos_bins, n_p_bins, seed)
}

# Thinning on already-validated data (skips a second validate() pass, which
# matters at tens of millions of rows). Called directly by the plot functions.
.thin_validated <- function(data,
                            max_points = 2e5,
                            keep_below = 1e-2,
                            n_pos_bins = 1500,
                            n_p_bins = 300,
                            seed = NULL) {
  n <- nrow(data)
  if (n <= max_points) return(data)
  if (!is.null(seed)) set.seed(seed)

  nlp <- -log10(data$P)
  keep_sig <- which(data$P <= keep_below)
  budget <- max(0L, as.integer(max_points) - length(keep_sig))

  rest <- which(data$P > keep_below)
  chosen_bg <- integer(0)
  if (length(rest) > 0 && budget > 0) {
    chr_i <- as.integer(data$CHR[rest])
    pos_bin <- as.integer(data$POS[rest] / (1e8 / n_pos_bins))
    p_bin <- as.integer(nlp[rest] * (n_p_bins / max(nlp[rest], 1)))
    has_trait <- "trait" %in% names(data)
    tr_i <- if (has_trait) as.integer(factor(data$trait[rest])) else 0L

    # One representative per (trait, chr, pos-bin, p-bin) cell. A single
    # numeric composite key + duplicated() is fast even at tens of millions of
    # rows and avoids a hard data.table dependency.
    key <- (((tr_i * 64 + chr_i) * (n_pos_bins + 1) + pos_bin) *
              (n_p_bins + 1) + p_bin)
    reps <- rest[!duplicated(key)]

    # If the grid still exceeds the budget, sample down.
    chosen_bg <- if (length(reps) > budget) sample(reps, budget) else reps
  }

  final <- sort(c(keep_sig, chosen_bg))
  out <- data[final, , drop = FALSE]
  message(sprintf(
    "thin_gwas(): kept %s of %s markers (%s hit%s at P<=%g + %s background); dropped %s.",
    format(length(final), big.mark = ","), format(n, big.mark = ","),
    format(length(keep_sig), big.mark = ","),
    if (length(keep_sig) == 1) "" else "s", keep_below,
    format(length(chosen_bg), big.mark = ","),
    format(n - length(final), big.mark = ",")))
  attr(out, "thinned_from") <- n
  out
}

# Resolve the big_data / raster / max_points arguments into a concrete plan.
# This is the ONLY place big-data behaviour is decided; when big_data is FALSE
# and raster is NULL the plan matches the ordinary (non-big-data) code path
# exactly, so normal plots are never altered.
#
# For big_data the design is a hybrid: the dense background is drawn as a
# raster bitmap (all points, no SVG nodes), and interactivity -- when asked for
# -- is carried only by the highlighted markers, which are the only points
# anyone hovers. That keeps "big_data + interactive" both sensible and fast,
# with no whole-data thinning.
.resolve_bigdata <- function(big_data, raster, max_points, interactive) {
  big <- isTRUE(big_data)
  interactive <- isTRUE(interactive)

  # Background rasterised for big data (or when the user asks with raster=TRUE).
  base_raster <- if (is.null(raster)) big else isTRUE(raster)
  # A rasterised background is never itself an interactive SVG layer.
  list(
    base_raster = base_raster,
    base_interactive = interactive && !base_raster,
    highlight_interactive = interactive,
    return_girafe = interactive,
    max_points = max_points,   # only thins when the user sets it explicitly
    fast = big
  )
}
