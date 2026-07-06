# Column-name aliases recognised by validate_gwas(). Matching is
# case-insensitive and ignores non-alphanumeric characters.
.gwas_aliases <- list(
  SNP   = c("snp", "marker", "markername", "rsid", "rs", "id", "variant",
            "variantid"),
  CHR   = c("chr", "chrom", "chromosome", "chrid", "hashchrom"),
  POS   = c("pos", "bp", "position", "basepair", "bpposition", "ps",
            "location"),
  P     = c("p", "pval", "pvalue", "pvalue", "praw", "pbolt", "pwald",
            "frequentistaddpvalue"),
  gene  = c("gene", "genename", "geneid", "nearestgene", "symbol"),
  trait = c("trait", "phenotype", "pheno", "group", "study")
)

# Normalise a column name for alias matching: lower-case, strip anything
# that is not a letter or digit.
.norm_name <- function(x) gsub("[^a-z0-9]", "", tolower(x))

# Given the data's column names and a target role, return the matching
# column name (or NULL). `explicit` short-circuits auto-detection.
.match_column <- function(cols, role, explicit = NULL) {
  if (!is.null(explicit)) {
    if (!explicit %in% cols) {
      stop(sprintf("Column '%s' (requested for '%s') not found in data.",
                   explicit, role), call. = FALSE)
    }
    return(explicit)
  }
  normed <- .norm_name(cols)
  hit <- which(normed %in% .gwas_aliases[[role]])
  if (length(hit) == 0) return(NULL)
  cols[hit[1]]
}

#' Order chromosome labels in natural genomic order
#'
#' Numeric chromosomes are sorted ascending, followed by the sex and
#' mitochondrial chromosomes (`X`, `Y`, `XY`, `MT`/`M`) and finally any other
#' labels alphabetically. A leading `"chr"` prefix is ignored when sorting but
#' preserved in the returned levels.
#'
#' @param x A vector of chromosome labels.
#'
#' @return A character vector of the unique labels in natural order, suitable
#'   for use as factor levels.
#' @export
#'
#' @examples
#' order_chromosomes(c("chr2", "chr10", "chrX", "chr1"))
order_chromosomes <- function(x) {
  u <- unique(as.character(x))
  u <- u[!is.na(u)]
  clean <- sub("^chr", "", u, ignore.case = TRUE)
  num <- suppressWarnings(as.numeric(clean))
  is_num <- !is.na(num)

  num_levels <- u[is_num][order(num[is_num])]

  conv <- c("X", "Y", "XY", "MT", "M")
  rest_clean <- clean[!is_num]
  rest_u <- u[!is_num]
  ord <- order(match(toupper(rest_clean), conv), toupper(rest_clean))
  nonnum_levels <- rest_u[ord]

  c(num_levels, nonnum_levels)
}

#' Validate and standardise a GWAS data frame
#'
#' Checks that a data frame contains the columns required by \pkg{gwasplot}
#' and returns a tidy, type-coerced [tibble][tibble::tibble] with canonical
#' column names. Column names are auto-detected from a set of common aliases
#' (for example `BP` or `position` map to `POS`; `pvalue` maps to `P`) or can
#' be supplied explicitly.
#'
#' The canonical contract is four required columns --- `SNP` (marker id),
#' `CHR` (chromosome), `POS` (base-pair position) and `P` (p-value) --- plus
#' two optional columns, `gene` and `trait`. `CHR` is returned as an ordered
#' factor in natural genomic order (see [order_chromosomes()]). Any additional
#' columns in `data` are preserved, which is convenient for interactive
#' tooltips.
#'
#' @param data A data frame of GWAS summary statistics.
#' @param snp,chr,pos,p Optional strings giving the column names to use for
#'   each role, overriding auto-detection.
#' @param gene,trait Optional strings giving the column names to use for the
#'   (optional) gene and trait roles.
#' @param na.rm Logical; drop rows with a missing `CHR`, `POS` or `P`
#'   (default `TRUE`).
#'
#' @return A [tibble][tibble::tibble] with columns `SNP`, `CHR` (ordered
#'   factor), `POS` (numeric), `P` (numeric) first, followed by `gene` and/or
#'   `trait` when present, and then any remaining columns from `data`.
#' @export
#'
#' @examples
#' df <- data.frame(
#'   marker = c("rs1", "rs2", "rs3"),
#'   chrom  = c(1, 1, 2),
#'   bp     = c(100, 200, 150),
#'   pvalue = c(1e-8, 0.2, 3e-3)
#' )
#' validate_gwas(df)
validate_gwas <- function(data,
                          snp = NULL, chr = NULL, pos = NULL, p = NULL,
                          gene = NULL, trait = NULL,
                          na.rm = TRUE) {
  if (!is.data.frame(data)) {
    stop("`data` must be a data frame.", call. = FALSE)
  }
  if (nrow(data) == 0) {
    stop("`data` has no rows.", call. = FALSE)
  }
  cols <- names(data)

  col_chr <- .match_column(cols, "CHR", chr)
  col_pos <- .match_column(cols, "POS", pos)
  col_p   <- .match_column(cols, "P",   p)
  col_snp <- .match_column(cols, "SNP", snp)

  missing_roles <- c(
    CHR = is.null(col_chr),
    POS = is.null(col_pos),
    P   = is.null(col_p)
  )
  if (any(missing_roles)) {
    stop(
      "Could not find required column(s): ",
      paste(names(missing_roles)[missing_roles], collapse = ", "),
      ".\n  Available columns: ", paste(cols, collapse = ", "),
      ".\n  Supply them explicitly, e.g. validate_gwas(data, chr = \"my_chr\").",
      call. = FALSE
    )
  }

  col_gene  <- .match_column(cols, "gene",  gene)
  col_trait <- .match_column(cols, "trait", trait)

  # Build the standardised frame.
  out <- tibble::tibble(
    CHR = as.character(data[[col_chr]]),
    POS = suppressWarnings(as.numeric(data[[col_pos]])),
    P   = suppressWarnings(as.numeric(data[[col_p]]))
  )
  out$SNP <- if (is.null(col_snp)) {
    paste0(out$CHR, ":", format(out$POS, scientific = FALSE, trim = TRUE))
  } else {
    as.character(data[[col_snp]])
  }
  if (!is.null(col_gene))  out$gene  <- as.character(data[[col_gene]])
  if (!is.null(col_trait)) out$trait <- as.character(data[[col_trait]])

  # Preserve any remaining columns for downstream use (e.g. tooltips).
  used <- c(col_chr, col_pos, col_p, col_snp, col_gene, col_trait)
  extra <- setdiff(cols, used)
  for (nm in extra) out[[nm]] <- data[[nm]]

  # --- Validation of values -------------------------------------------------
  if (all(is.na(out$POS))) {
    stop("Column '", col_pos, "' could not be coerced to numeric positions.",
         call. = FALSE)
  }
  if (all(is.na(out$P))) {
    stop("Column '", col_p, "' could not be coerced to numeric p-values.",
         call. = FALSE)
  }

  if (na.rm) {
    keep <- !(is.na(out$CHR) | is.na(out$POS) | is.na(out$P))
    dropped <- sum(!keep)
    if (dropped > 0) {
      message(sprintf("validate_gwas(): dropped %d row(s) with missing CHR/POS/P.",
                      dropped))
    }
    out <- out[keep, , drop = FALSE]
  }

  bad_pos <- !is.na(out$POS) & out$POS < 0
  if (any(bad_pos)) {
    stop(sprintf("Found %d negative position(s) in '%s'.", sum(bad_pos), col_pos),
         call. = FALSE)
  }

  bad_range <- !is.na(out$P) & (out$P < 0 | out$P > 1)
  if (any(bad_range)) {
    stop(sprintf("Found %d p-value(s) outside (0, 1] in '%s'.",
                 sum(bad_range), col_p),
         call. = FALSE)
  }
  zero_p <- !is.na(out$P) & out$P == 0
  if (any(zero_p)) {
    floor_val <- .Machine$double.xmin
    warning(sprintf(
      "Found %d p-value(s) equal to 0; flooring to %.3g to keep -log10(P) finite.",
      sum(zero_p), floor_val), call. = FALSE)
    out$P[zero_p] <- floor_val
  }

  # Natural chromosome ordering.
  out$CHR <- factor(out$CHR, levels = order_chromosomes(out$CHR))

  # Canonical column order first, then whatever remains.
  lead <- c("SNP", "CHR", "POS", "P",
            intersect(c("gene", "trait"), names(out)))
  out <- out[, c(lead, setdiff(names(out), lead)), drop = FALSE]

  out
}
