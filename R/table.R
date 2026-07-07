#' Extract the top GWAS markers as a tidy table
#'
#' Returns the top hits selected by a [highlight_top()] specification, ordered
#' by p-value, with a `neg_log10_p` column added. This is the data behind
#' [gwas_table()] and uses the same selection logic as the plots' `highlight`
#' argument, so a table and a figure can be kept perfectly in sync.
#'
#' @param data A GWAS data frame (passed through [validate_gwas()]).
#' @param highlight A [highlight_top()] spec, or a single number (`top_n`).
#'   Defaults to the 10 smallest-p markers.
#' @param columns Optional character vector of columns to keep (and order). By
#'   default keeps `SNP`, `gene`, `trait`, `CHR`, `POS`, `P`, `neg_log10_p`
#'   when present.
#'
#' @return A [tibble][tibble::tibble] of the selected markers.
#' @seealso [gwas_table()], [highlight_top()]
#' @export
#'
#' @examples
#' data(gwas_example)
#' gwas_top(gwas_example, highlight = highlight_top(top_n = 5))
gwas_top <- function(data,
                     highlight = highlight_top(top_n = 10),
                     columns = NULL) {
  data <- validate_gwas(data)
  data$neg_log10_p <- -log10(data$P)

  spec <- .as_highlight(highlight)
  hits <- .apply_highlight(data, spec)

  default_cols <- intersect(
    c("SNP", "gene", "trait", "CHR", "POS", "P", "neg_log10_p"),
    names(hits)
  )
  keep <- columns %||% default_cols
  keep <- intersect(keep, names(hits))
  tibble::as_tibble(hits[, keep, drop = FALSE])
}

#' A formatted table of the top GWAS markers
#'
#' Builds a publication-ready [gt][gt::gt] table of the top hits, mirroring the
#' top-markers table in the \pkg{ggvolc} package. Positions are shown with
#' thousands separators, p-values in scientific notation, and
#' \eqn{-\log_{10}(P)} is optionally colour-scaled.
#'
#' @inheritParams gwas_top
#' @param color Logical; colour the `neg_log10_p` column by value
#'   (default `TRUE`).
#' @param title,subtitle Optional table title and subtitle.
#'
#' @return A `gt` table object (class `gt_tbl`, see [gt::gt()]). Requires the
#'   \pkg{gt} package.
#' @seealso [gwas_top()], [gwas_manhattan()], [gwas_circular()]
#' @export
#'
#' @examples
#' if (requireNamespace("gt", quietly = TRUE)) {
#'   data(gwas_example)
#'   gwas_table(gwas_example, highlight = highlight_top(top_n = 8))
#' }
gwas_table <- function(data,
                       highlight = highlight_top(top_n = 10),
                       columns = NULL,
                       color = TRUE,
                       title = NULL,
                       subtitle = NULL) {
  if (!requireNamespace("gt", quietly = TRUE)) {
    stop("gwas_table() requires the 'gt' package. Install it with ",
         "install.packages(\"gt\"), or use gwas_top() for a plain table.",
         call. = FALSE)
  }
  top <- gwas_top(data, highlight = highlight, columns = columns)

  # Friendly column labels.
  labels <- list(
    SNP = "SNP", gene = "Gene", trait = "Trait", CHR = "Chr",
    POS = "Position", P = "P-value",
    neg_log10_p = gt::html("&minus;log<sub>10</sub>(P)")
  )
  labels <- labels[intersect(names(labels), names(top))]

  tbl <- gt::gt(top)
  tbl <- gt::cols_label(tbl, .list = labels)

  if ("POS" %in% names(top)) {
    tbl <- gt::fmt_number(tbl, columns = "POS", decimals = 0,
                          use_seps = TRUE)
  }
  if ("P" %in% names(top)) {
    tbl <- gt::fmt_scientific(tbl, columns = "P", decimals = 2)
  }
  if ("neg_log10_p" %in% names(top)) {
    tbl <- gt::fmt_number(tbl, columns = "neg_log10_p", decimals = 1)
    if (isTRUE(color)) {
      tbl <- gt::data_color(
        tbl, columns = "neg_log10_p",
        palette = c("#fee5d9", "#fcae91", "#fb6a4a", "#de2d26", "#a50f15")
      )
    }
  }

  if (!is.null(title) || !is.null(subtitle)) {
    tbl <- gt::tab_header(
      tbl,
      title = title %||% gt::md(""),
      subtitle = subtitle
    )
  }

  tbl |>
    gt::tab_options(table.font.size = gt::px(13),
                    data_row.padding = gt::px(4)) |>
    gt::opt_row_striping()
}
