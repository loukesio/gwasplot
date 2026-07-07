#' Single-chromosome (regional) plot of GWAS results
#'
#' Zooms into one chromosome (optionally a base-pair window), plotting
#' \eqn{-\log_{10}(P)} against position in megabases. Significance lines and
#' top-marker highlighting work as in [gwas_manhattan()].
#'
#' @inheritParams gwas_manhattan
#' @param chr The chromosome to plot (matched against the `CHR` column, with or
#'   without a `"chr"` prefix).
#' @param xlim Optional numeric length-2 base-pair window `c(start, end)` to
#'   restrict the region shown.
#' @param point_color Colour for the (non-highlighted) points.
#'
#' @return A [ggplot2::ggplot] object.
#' @seealso [gwas_manhattan()], [highlight_top()]
#' @export
#'
#' @examples
#' data(gwas_example)
#' gwas_chromosome(gwas_example, chr = 1)
#' gwas_chromosome(gwas_example, chr = 1, highlight = highlight_top(top_n = 3))
gwas_chromosome <- function(data,
                            chr,
                            xlim = NULL,
                            threshold = 5e-8,
                            suggestive = 1e-5,
                            highlight = NULL,
                            label = TRUE,
                            label_by = c("gene", "SNP"),
                            point_color = "#2f5c8f",
                            highlight_color = "#d1422f",
                            point_size = 1.4,
                            point_alpha = 0.85,
                            title = NULL,
                            subtitle = NULL) {
  data <- validate_gwas(data)
  label_by <- match.arg(label_by)

  # Resolve the requested chromosome against the CHR factor levels.
  want <- sub("^chr", "", as.character(chr), ignore.case = TRUE)
  lev_clean <- sub("^chr", "", levels(data$CHR), ignore.case = TRUE)
  hit_lev <- levels(data$CHR)[match(want, lev_clean)]
  if (is.na(hit_lev)) {
    stop(sprintf("Chromosome '%s' not found. Available: %s",
                 chr, paste(levels(data$CHR), collapse = ", ")),
         call. = FALSE)
  }

  sub <- data[as.character(data$CHR) == hit_lev, , drop = FALSE]
  if (!is.null(xlim)) {
    sub <- sub[sub$POS >= xlim[1] & sub$POS <= xlim[2], , drop = FALSE]
  }
  if (nrow(sub) == 0) {
    stop("No markers on chromosome ", hit_lev,
         if (!is.null(xlim)) " in the requested window." else ".",
         call. = FALSE)
  }

  sub$neg_log10_p <- -log10(sub$P)
  sub$pos_mb <- sub$POS / 1e6

  spec <- .as_highlight(highlight)
  hits <- .apply_highlight(sub, spec)

  p <- ggplot2::ggplot(
    sub, ggplot2::aes(x = .data$pos_mb, y = .data$neg_log10_p)
  ) +
    ggplot2::geom_point(colour = point_color, size = point_size,
                        alpha = point_alpha) +
    ggplot2::scale_y_continuous(
      expand = ggplot2::expansion(mult = c(0.01, 0.08))
    )

  if (!is.null(suggestive)) {
    p <- p + ggplot2::geom_hline(yintercept = -log10(suggestive),
                                 linetype = "dashed", colour = "#f4ab5c",
                                 linewidth = 0.5)
  }
  if (!is.null(threshold)) {
    p <- p + ggplot2::geom_hline(yintercept = -log10(threshold),
                                 linetype = "solid", colour = "#b03024",
                                 linewidth = 0.5)
  }

  if (nrow(hits) > 0) {
    hits$pos_mb <- hits$POS / 1e6
    p <- p + ggplot2::geom_point(
      data = hits, ggplot2::aes(x = .data$pos_mb, y = .data$neg_log10_p),
      colour = highlight_color, size = point_size * 1.7, alpha = 0.9
    )
    if (isTRUE(label)) {
      lab_col <- if (label_by == "gene" && "gene" %in% names(hits)) {
        "gene"
      } else {
        "SNP"
      }
      hits$.label <- hits[[lab_col]]
      p <- p + .repel_labels(hits, highlight_color, "pos_mb", "neg_log10_p")
    }
  }

  p +
    ggplot2::labs(
      x = paste0("Chromosome ", hit_lev, " position (Mb)"),
      y = expression(-log[10](italic(P))),
      title = title %||% paste("Chromosome", hit_lev),
      subtitle = subtitle
    ) +
    theme_gwasplot()
}
