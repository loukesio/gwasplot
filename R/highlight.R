#' Specify which top markers to highlight
#'
#' A small constructor that bundles a highlight specification for reuse across
#' the plotting functions and the top-hits table. Criteria are combined as a
#' union: a marker is highlighted if it satisfies *any* of the supplied rules.
#'
#' @param top_n Integer; highlight the `top_n` markers with the smallest
#'   p-values (per group when `by` is set).
#' @param threshold Numeric p-value; highlight markers with `P <= threshold`.
#' @param snps,genes Character vectors of `SNP` ids / `gene` names to highlight.
#' @param by Optional grouping column applied before `top_n`
#'   (e.g. `"CHR"` for the top hit on each chromosome, or `"trait"`).
#'
#' @return An object of class `"gwas_highlight"` (a list of the criteria).
#' @export
#'
#' @examples
#' highlight_top(top_n = 10)
#' highlight_top(threshold = 5e-8, genes = c("GENE01000"))
#' highlight_top(top_n = 1, by = "CHR")  # lead SNP per chromosome
highlight_top <- function(top_n = NULL, threshold = NULL,
                          snps = NULL, genes = NULL, by = NULL) {
  if (is.null(top_n) && is.null(threshold) &&
      is.null(snps) && is.null(genes)) {
    stop("highlight_top(): supply at least one of top_n, threshold, snps, genes.",
         call. = FALSE)
  }
  structure(
    list(top_n = top_n, threshold = threshold,
         snps = snps, genes = genes, by = by),
    class = "gwas_highlight"
  )
}

# Coerce user input into a gwas_highlight spec. Accepts an existing spec, a
# bare number (treated as top_n), or NULL.
.as_highlight <- function(x) {
  if (is.null(x)) return(NULL)
  if (inherits(x, "gwas_highlight")) return(x)
  if (is.numeric(x) && length(x) == 1) return(highlight_top(top_n = x))
  stop("`highlight` must be NULL, a single number, or a highlight_top() spec.",
       call. = FALSE)
}

# Apply a highlight spec to a (prepared) data frame, returning the selected
# rows via .select_top().
.apply_highlight <- function(data, spec) {
  if (is.null(spec)) return(data[0, , drop = FALSE])
  .select_top(data,
              top_n = spec$top_n, threshold = spec$threshold,
              snps = spec$snps, genes = spec$genes, by = spec$by)
}
