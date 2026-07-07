# --- Interactivity helpers (ggiraph) ----------------------------------------
# gwasplot's plots become interactive by swapping their point layers for
# ggiraph interactive geoms and wrapping the finished ggplot in girafe().
# ggiraph is an optional (Suggests) dependency, guarded at every use.

# Build the per-point hover text shown in tooltips.
.tooltip_text <- function(df) {
  txt <- paste0("SNP: ", df$SNP)
  if ("gene" %in% names(df)) txt <- paste0(txt, "<br/>Gene: ", df$gene)
  if ("trait" %in% names(df)) txt <- paste0(txt, "<br/>Trait: ", df$trait)
  paste0(
    txt,
    "<br/>CHR: ", as.character(df$CHR),
    "<br/>POS: ", format(df$POS, big.mark = ",", scientific = FALSE,
                         trim = TRUE),
    sprintf("<br/>P: %.2e", df$P)
  )
}

# A point layer that is interactive (ggiraph) when `interactive = TRUE` and
# ggiraph is installed, otherwise a plain geom_point. `mapping` may include
# the `tooltip`/`data_id` aesthetics; they are stripped for the static geom.
.point_geom <- function(interactive, mapping, ...) {
  if (isTRUE(interactive) && requireNamespace("ggiraph", quietly = TRUE)) {
    ggiraph::geom_point_interactive(mapping = mapping, ...)
  } else {
    mapping[["tooltip"]] <- NULL
    mapping[["data_id"]] <- NULL
    ggplot2::geom_point(mapping = mapping, ...)
  }
}

# Wrap a finished ggplot as an interactive girafe widget, or return it
# unchanged when interactive is FALSE. Warns (and falls back to static) if
# ggiraph is unavailable.
.as_girafe <- function(p, interactive, width_svg = 8, height_svg = 5.5) {
  if (!isTRUE(interactive)) return(p)
  if (!requireNamespace("ggiraph", quietly = TRUE)) {
    warning("interactive = TRUE requires the 'ggiraph' package; ",
            "returning a static plot.", call. = FALSE)
    return(p)
  }
  ggiraph::girafe(
    ggobj = p, width_svg = width_svg, height_svg = height_svg,
    options = list(
      ggiraph::opts_hover(css = "stroke:#d1422f;stroke-width:1.5px;"),
      ggiraph::opts_tooltip(
        css = paste0("background:#2b2b2b;color:#fff;padding:6px 8px;",
                     "border-radius:4px;font-size:11px;font-family:sans-serif;"),
        opacity = 0.95
      ),
      ggiraph::opts_zoom(min = 1, max = 6)
    )
  )
}
