# Shared label layer for highlighted markers. Uses ggrepel when available
# (non-overlapping, with leader lines), otherwise a plain overlap-checked
# geom_text. `xcol`/`ycol` name the position columns and `hits` must carry a
# `.label` column.
.repel_labels <- function(hits, colour, xcol, ycol) {
  if (requireNamespace("ggrepel", quietly = TRUE)) {
    ggrepel::geom_text_repel(
      data = hits,
      ggplot2::aes(x = .data[[xcol]], y = .data[[ycol]], label = .data$.label),
      colour = colour, size = 3, fontface = "bold",
      min.segment.length = 0, max.overlaps = Inf,
      segment.colour = "grey60", segment.size = 0.3,
      box.padding = 0.4, seed = 1
    )
  } else {
    ggplot2::geom_text(
      data = hits,
      ggplot2::aes(x = .data[[xcol]], y = .data[[ycol]], label = .data$.label),
      colour = colour, size = 3, fontface = "bold",
      vjust = -0.8, check_overlap = TRUE
    )
  }
}
