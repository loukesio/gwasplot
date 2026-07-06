#' A clean theme for gwasplot figures
#'
#' A minimal [ggplot2::theme_minimal()]-based theme with no vertical grid
#' lines, tidy axis titles and a subtle significance-line look. Used by
#' default in [gwas_manhattan()]; add or override it like any ggplot2 theme.
#'
#' @param base_size Base font size, passed to [ggplot2::theme_minimal()].
#' @param base_family Base font family.
#'
#' @return A ggplot2 theme object.
#' @export
#'
#' @examples
#' library(ggplot2)
#' ggplot(mtcars, aes(wt, mpg)) + geom_point() + theme_gwasplot()
theme_gwasplot <- function(base_size = 12, base_family = "") {
  ggplot2::theme_minimal(base_size = base_size, base_family = base_family) +
    ggplot2::theme(
      panel.grid.major.x = ggplot2::element_blank(),
      panel.grid.minor.x = ggplot2::element_blank(),
      panel.grid.minor.y = ggplot2::element_blank(),
      panel.grid.major.y = ggplot2::element_line(linewidth = 0.3,
                                                 colour = "grey92"),
      axis.line.x = ggplot2::element_line(linewidth = 0.4, colour = "grey30"),
      axis.ticks.x = ggplot2::element_line(linewidth = 0.4, colour = "grey30"),
      axis.text = ggplot2::element_text(colour = "grey20"),
      plot.title = ggplot2::element_text(face = "bold"),
      plot.subtitle = ggplot2::element_text(colour = "grey30"),
      legend.position = "none"
    )
}

# Default alternating chromosome colours (blue / slate) and the highlight
# accent, echoing the red used in the user's original figure.
.gwasplot_pal <- list(
  band   = c("#2f5c8f", "#a7bcd6"),
  accent = "#d1422f",
  genome = "#b03024",
  suggestive = "#f4ab5c"
)
