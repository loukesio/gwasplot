#' Manhattan plot of GWAS results
#'
#' Draws a classic linear Manhattan plot: \eqn{-\log_{10}(P)} against genome
#' position, with chromosomes laid end-to-end and coloured in alternating
#' bands. Genome-wide and suggestive significance lines are drawn by default,
#' and top markers can be highlighted and labelled.
#'
#' @param data A GWAS data frame. It is passed through [validate_gwas()], so
#'   raw column names (e.g. `BP`, `pvalue`) are accepted.
#' @param threshold Genome-wide significance p-value drawn as a solid line
#'   (default `5e-8`). Use `NULL` to omit.
#' @param suggestive Suggestive significance p-value drawn as a dashed line
#'   (default `1e-5`). Use `NULL` to omit.
#' @param highlight A [highlight_top()] specification, a single number
#'   (shorthand for `top_n`), or `NULL` for no highlighting. Highlighted
#'   markers are drawn in `highlight_color`.
#' @param label Logical; label the highlighted markers (default `TRUE` when
#'   `highlight` is given). Requires the highlighted set to be non-empty.
#' @param label_by Column used for labels, `"gene"` (default, falls back to
#'   `"SNP"` if absent) or `"SNP"`.
#' @param colors Length-2 vector of alternating chromosome-band colours.
#' @param highlight_color Colour for highlighted markers and their labels.
#' @param point_size,point_alpha Size and alpha of the non-highlighted points.
#' @param ylim Optional numeric length-2 y-axis limit on the
#'   \eqn{-\log_{10}(P)} scale.
#' @param interactive Logical; if `TRUE`, points carry hover tooltips (SNP,
#'   gene, chromosome, position, p-value) and the plot is returned as an
#'   interactive `girafe` widget. Requires the \pkg{ggiraph} package.
#' @param title,subtitle Optional plot title and subtitle.
#'
#' @return A [ggplot2::ggplot] object, or a [ggiraph::girafe()] htmlwidget when
#'   `interactive = TRUE`.
#' @seealso [highlight_top()], [gwas_chromosome()], [gwas_table()],
#'   [theme_gwasplot()]
#' @export
#'
#' @examples
#' data(gwas_example)
#' gwas_manhattan(gwas_example)
#' gwas_manhattan(gwas_example, highlight = highlight_top(top_n = 5))
gwas_manhattan <- function(data,
                           threshold = 5e-8,
                           suggestive = 1e-5,
                           highlight = NULL,
                           label = TRUE,
                           label_by = c("gene", "SNP"),
                           colors = c("#2f5c8f", "#a7bcd6"),
                           highlight_color = "#d1422f",
                           point_size = 1,
                           point_alpha = 0.8,
                           ylim = NULL,
                           interactive = FALSE,
                           title = NULL,
                           subtitle = NULL) {
  data <- validate_gwas(data)
  prepped <- .prepare_manhattan(data)
  prepped$.tooltip <- .tooltip_text(prepped)
  centers <- attr(prepped, "chr_centers")
  label_by <- match.arg(label_by)

  spec <- .as_highlight(highlight)
  hits <- .apply_highlight(prepped, spec)

  p <- ggplot2::ggplot(
    prepped,
    ggplot2::aes(x = .data$cum_pos, y = .data$neg_log10_p)
  ) +
    .point_geom(
      interactive,
      ggplot2::aes(colour = .data$chr_band,
                   tooltip = .data$.tooltip, data_id = .data$SNP),
      size = point_size, alpha = point_alpha
    ) +
    ggplot2::scale_colour_manual(values = c(`TRUE` = colors[1],
                                            `FALSE` = colors[2]),
                                 guide = "none") +
    ggplot2::scale_x_continuous(
      breaks = centers,
      labels = names(centers),
      expand = ggplot2::expansion(mult = 0.01)
    ) +
    ggplot2::scale_y_continuous(expand = ggplot2::expansion(mult = c(0.01, 0.08)))

  # Significance lines.
  if (!is.null(suggestive)) {
    p <- p + ggplot2::geom_hline(
      yintercept = -log10(suggestive),
      linetype = "dashed", colour = "#f4ab5c", linewidth = 0.5
    )
  }
  if (!is.null(threshold)) {
    p <- p + ggplot2::geom_hline(
      yintercept = -log10(threshold),
      linetype = "solid", colour = "#b03024", linewidth = 0.5
    )
  }

  # Highlighted markers + labels.
  if (nrow(hits) > 0) {
    p <- p + .point_geom(
      interactive,
      ggplot2::aes(x = .data$cum_pos, y = .data$neg_log10_p,
                   tooltip = .data$.tooltip, data_id = .data$SNP),
      data = hits,
      colour = highlight_color, size = point_size * 1.9, alpha = 0.9
    )
    if (isTRUE(label)) {
      lab_col <- if (label_by == "gene" && "gene" %in% names(hits)) {
        "gene"
      } else {
        "SNP"
      }
      hits$.label <- hits[[lab_col]]
      p <- p + .repel_labels(hits, highlight_color, "cum_pos", "neg_log10_p")
    }
  }

  p <- p +
    ggplot2::labs(
      x = "Chromosome",
      y = expression(-log[10](italic(P))),
      title = title,
      subtitle = subtitle
    ) +
    (if (!is.null(ylim)) ggplot2::coord_cartesian(ylim = ylim) else NULL) +
    theme_gwasplot()

  .as_girafe(p, interactive, width_svg = 10, height_svg = 5)
}
