# --- Polar geometry helpers -------------------------------------------------
# Angles are measured clockwise from the top (12 o'clock): a point at genome
# fraction f sits at angle 2*pi*f, with x = r*sin(angle), y = r*cos(angle).

# Points along a circular arc, for drawing threshold rings / chromosome ticks.
.arc_path <- function(a1, a2, r, n = 120) {
  a <- seq(a1, a2, length.out = n)
  data.frame(x = r * sin(a), y = r * cos(a))
}

# A filled annulus sector (ring segment between radii r1 < r2 and angles
# a1 < a2), for background chromosome bands and the central ideogram.
.annulus_sector <- function(a1, a2, r1, r2, n = 60) {
  a_out <- seq(a1, a2, length.out = n)
  a_in <- rev(a_out)
  data.frame(
    x = c(r2 * sin(a_out), r1 * sin(a_in)),
    y = c(r2 * cos(a_out), r1 * cos(a_in))
  )
}

#' Compute shared circular genome coordinates
#'
#' Lays every chromosome around a circle once (shared angular axis across all
#' traits) and returns each row's angle plus, as attributes, the per-chrom
#' angular spans and centres.
#'
#' @param data A validated GWAS frame (possibly multi-trait).
#' @param gap Fraction of the genome length inserted as padding after each
#'   chromosome (also opens a seam at the top).
#' @return `data` with a `theta` column and `neg_log10_p`; attributes
#'   `"chr_ang"` (matrix of start/centre/end angles per chromosome).
#' @keywords internal
#' @noRd
.prepare_circular <- function(data, gap = 0.01, fast = FALSE) {
  data$CHR <- droplevels(data$CHR)
  chr_levels <- levels(data$CHR)

  # Genome layout uses the max position seen for each chromosome across ALL
  # traits, so every ring shares one angular axis.
  chr_max <- .group_max(data$POS, as.integer(data$CHR), length(chr_levels), fast)
  names(chr_max) <- chr_levels
  n_chr <- length(chr_levels)
  pad <- gap * sum(chr_max)
  total <- sum(chr_max) + n_chr * pad

  offsets <- c(0, cumsum(chr_max[-n_chr] + pad))
  names(offsets) <- chr_levels

  cum <- data$POS + offsets[as.character(data$CHR)]
  data$theta <- 2 * pi * (cum / total)
  data$neg_log10_p <- -log10(data$P)

  starts <- offsets
  ends <- offsets + chr_max
  chr_ang <- cbind(
    start  = 2 * pi * (starts / total),
    center = 2 * pi * ((starts + chr_max / 2) / total),
    end    = 2 * pi * (ends / total)
  )
  rownames(chr_ang) <- chr_levels
  attr(data, "chr_ang") <- chr_ang
  data
}

#' Circular (CMplot-style) plot of GWAS results, with multiple trait rings
#'
#' Draws a circular Manhattan plot: chromosomes are arranged once around the
#' circle and each trait is shown as its own concentric ring, from the outside
#' in. Genome-wide significance rings and top-marker highlighting are supported
#' per trait. This is the multi-ring analogue of [gwas_manhattan()].
#'
#' @param data A GWAS data frame (passed through [validate_gwas()]). For
#'   multiple rings it must contain a trait column, or you can bind several
#'   single-trait frames together and set `trait`.
#' @param trait Column that splits the data into rings (default `"trait"` when
#'   present, otherwise a single ring). Set `NULL` to force a single ring.
#' @param threshold Genome-wide significance p-value drawn as a ring per trait
#'   (default `5e-8`; `NULL` to omit).
#' @param highlight A [highlight_top()] spec, a single number (`top_n`), or
#'   `NULL`. Applied per trait.
#' @param label Logical; label highlighted markers (default `TRUE`).
#' @param label_by Column for labels, `"gene"` (default) or `"SNP"`.
#' @param colors Optional vector of ring colours (one per trait). Recycled /
#'   truncated as needed; defaults to a built-in palette.
#' @param highlight_color Colour for highlighted markers and labels.
#' @param ideogram Logical; draw a central chromosome colour band (default
#'   `TRUE`).
#' @param point_size,point_alpha Size and alpha of points.
#' @param shared_scale Logical; if `TRUE` (default) all rings share one
#'   \eqn{-\log_{10}(P)} scale so ring heights are comparable. If `FALSE` each
#'   ring is scaled to its own maximum.
#' @param r_inner Innermost radius of the ring stack (0-1); the space inside is
#'   used for the ideogram and labels.
#' @param ring_gap Radial gap between adjacent rings (0-1).
#' @param interactive Logical; if `TRUE`, return an interactive `girafe`
#'   widget with per-point hover tooltips (requires \pkg{ggiraph}).
#' @param big_data Logical; enable the large-GWAS pipeline --- rasterise the
#'   rings for a static plot (all points kept, via \pkg{scattermore}) or thin
#'   to `max_points` for an interactive one. See [gwas_manhattan()].
#' @param raster Logical or `NULL`; rasterise the point layer. `NULL` lets
#'   `big_data` decide. Requires \pkg{scattermore}.
#' @param max_points Optional integer; thin to about this many points with
#'   [thin_gwas()] before plotting (all hits kept).
#' @param title,subtitle Optional title and subtitle.
#'
#' @return A [ggplot2::ggplot] object, or a [ggiraph::girafe()] htmlwidget when
#'   `interactive = TRUE`.
#' @seealso [gwas_manhattan()], [gwas_table()], [highlight_top()]
#' @export
#'
#' @examples
#' data(gwas_multi)
#' gwas_circular(gwas_multi)                                   # 3 rings
#' gwas_circular(gwas_multi, highlight = highlight_top(top_n = 1, by = "trait"))
#'
#' data(gwas_example)
#' gwas_circular(gwas_example)                                 # single ring
gwas_circular <- function(data,
                          trait = "trait",
                          threshold = 5e-8,
                          highlight = NULL,
                          label = TRUE,
                          label_by = c("gene", "SNP"),
                          colors = NULL,
                          highlight_color = "#d1422f",
                          ideogram = TRUE,
                          point_size = 0.9,
                          point_alpha = 0.85,
                          shared_scale = TRUE,
                          r_inner = 0.38,
                          ring_gap = 0.035,
                          interactive = FALSE,
                          big_data = FALSE,
                          raster = NULL,
                          max_points = NULL,
                          title = NULL,
                          subtitle = NULL) {
  data <- validate_gwas(data)
  label_by <- match.arg(label_by)

  plan <- .resolve_bigdata(big_data, raster, max_points, interactive)
  if (!is.null(plan$max_points)) {
    data <- .thin_validated(data, max_points = plan$max_points)
  }

  # Resolve the ring/trait grouping.
  if (!is.null(trait) && trait %in% names(data)) {
    data$.trait <- as.character(data[[trait]])
    traits <- unique(data$.trait)
  } else {
    data$.trait <- "trait"
    traits <- "trait"
  }
  n_ring <- length(traits)
  if (n_ring > 6) {
    warning(sprintf(
      "gwas_circular(): %d rings requested; more than ~6 becomes hard to read.",
      n_ring), call. = FALSE)
  }

  prepped <- .prepare_circular(data, fast = plan$fast)
  chr_ang <- attr(prepped, "chr_ang")
  n_chr <- nrow(chr_ang)

  # Ring radial geometry (outermost ring = first trait).
  r_outer <- 1
  avail <- r_outer - r_inner
  ring_h <- (avail - (n_ring - 1) * ring_gap) / n_ring
  ring_geo <- lapply(seq_len(n_ring), function(k) {
    outer <- r_outer - (k - 1) * (ring_h + ring_gap)
    list(trait = traits[k], inner = outer - ring_h, outer = outer)
  })
  names(ring_geo) <- traits

  # -log10(P) scaling per ring.
  thr_y <- if (!is.null(threshold)) -log10(threshold) else NA_real_
  ring_max <- if (shared_scale) {
    m <- max(prepped$neg_log10_p, thr_y, na.rm = TRUE)
    stats::setNames(rep(m, n_ring), traits)
  } else {
    vapply(traits, function(tr) {
      max(prepped$neg_log10_p[prepped$.trait == tr], thr_y, na.rm = TRUE)
    }, numeric(1))
  }
  ring_max <- ring_max * 1.05

  # Per-row radius from its ring band.
  inner_v <- vapply(prepped$.trait, function(t) ring_geo[[t]]$inner, numeric(1))
  h_v <- ring_h
  frac <- prepped$neg_log10_p / ring_max[prepped$.trait]
  prepped$r <- inner_v + pmin(frac, 1) * h_v
  prepped$x <- prepped$r * sin(prepped$theta)
  prepped$y <- prepped$r * cos(prepped$theta)
  prepped$.tooltip <- .tooltip_text(prepped)

  # Ring colours.
  pal <- colors %||% c("#2f5c8f", "#1f9e89", "#b5651d", "#7b3f9e",
                       "#c94c4c", "#4c7bc9")
  ring_cols <- stats::setNames(rep(pal, length.out = n_ring), traits)

  # --- Build the plot -------------------------------------------------------
  p <- ggplot2::ggplot()

  # Alternating chromosome background bands spanning the ring stack.
  band_lo <- r_inner
  band_hi <- r_outer + 0.005
  for (i in seq_len(n_chr)) {
    if (i %% 2L == 1L) next
    poly <- .annulus_sector(chr_ang[i, "start"], chr_ang[i, "end"],
                            band_lo, band_hi)
    p <- p + ggplot2::geom_polygon(
      data = poly, ggplot2::aes(x = .data$x, y = .data$y),
      fill = "grey85", alpha = 0.35, colour = NA
    )
  }

  # Threshold ring(s).
  if (!is.null(threshold)) {
    for (k in seq_len(n_ring)) {
      g <- ring_geo[[k]]
      r_thr <- g$inner + pmin(thr_y / ring_max[traits[k]], 1) * ring_h
      arc <- .arc_path(0, 2 * pi, r_thr)
      p <- p + ggplot2::geom_path(
        data = arc, ggplot2::aes(x = .data$x, y = .data$y),
        colour = "#b03024", linetype = "dashed", linewidth = 0.4
      )
    }
  }

  # Data points, coloured by ring/trait.
  p <- p + .point_geom(
    plan$base_interactive,
    ggplot2::aes(x = .data$x, y = .data$y, colour = .data$.trait,
                 tooltip = .data$.tooltip, data_id = .data$SNP),
    data = prepped,
    size = point_size, alpha = point_alpha, raster = plan$base_raster
  ) +
    ggplot2::scale_colour_manual(values = ring_cols, breaks = traits,
                                 name = NULL)

  # Central chromosome ideogram band.
  if (isTRUE(ideogram)) {
    ideo_lo <- max(r_inner - 0.12, 0.12)
    ideo_hi <- r_inner - 0.02
    chr_fill <- rep(c("#dfe6ee", "#b9c6d8"), length.out = n_chr)
    for (i in seq_len(n_chr)) {
      poly <- .annulus_sector(chr_ang[i, "start"], chr_ang[i, "end"],
                              ideo_lo, ideo_hi)
      p <- p + ggplot2::geom_polygon(
        data = poly, ggplot2::aes(x = .data$x, y = .data$y),
        fill = chr_fill[i], colour = "white", linewidth = 0.2
      )
    }
  }

  # Chromosome labels just outside the outer ring.
  lab_r <- r_outer + 0.07
  chr_lab <- data.frame(
    x = lab_r * sin(chr_ang[, "center"]),
    y = lab_r * cos(chr_ang[, "center"]),
    label = rownames(chr_ang)
  )
  p <- p + ggplot2::geom_text(
    data = chr_lab, ggplot2::aes(x = .data$x, y = .data$y, label = .data$label),
    size = 2.7, colour = "grey30"
  )

  # Highlighted markers + labels.
  spec <- .as_highlight(highlight)
  if (!is.null(spec)) {
    hits <- .apply_highlight(prepped, spec)
    if (nrow(hits) > 0) {
      p <- p + .point_geom(
        plan$highlight_interactive,
        ggplot2::aes(x = .data$x, y = .data$y,
                     tooltip = .data$.tooltip, data_id = .data$SNP),
        data = hits,
        colour = highlight_color, size = point_size * 2.2, alpha = 0.95
      )
      if (isTRUE(label)) {
        lab_col <- if (label_by == "gene" && "gene" %in% names(hits)) "gene" else "SNP"
        hits$.label <- hits[[lab_col]]
        p <- p + .repel_labels(hits, highlight_color, "x", "y")
      }
    }
  }

  p <- p +
    ggplot2::coord_fixed(clip = "off") +
    ggplot2::labs(title = title, subtitle = subtitle) +
    ggplot2::theme_void(base_size = 12) +
    ggplot2::theme(
      legend.position = if (n_ring > 1) "right" else "none",
      plot.title = ggplot2::element_text(face = "bold", hjust = 0.5),
      plot.subtitle = ggplot2::element_text(colour = "grey30", hjust = 0.5),
      plot.margin = ggplot2::margin(6, 6, 6, 6)
    )

  .as_girafe(p, plan$return_girafe, width_svg = 7, height_svg = 6.5)
}
