# Manhattan plot of GWAS results

Draws a classic linear Manhattan plot: \\-\log\_{10}(P)\\ against genome
position, with chromosomes laid end-to-end and coloured in alternating
bands. Genome-wide and suggestive significance lines are drawn by
default, and top markers can be highlighted and labelled.

## Usage

``` r
gwas_manhattan(
  data,
  threshold = 5e-08,
  suggestive = 1e-05,
  highlight = NULL,
  label = TRUE,
  label_by = c("gene", "SNP"),
  colors = c("#2f5c8f", "#a7bcd6"),
  highlight_color = "#d1422f",
  point_size = 1,
  point_alpha = 0.8,
  ylim = NULL,
  interactive = FALSE,
  big_data = FALSE,
  raster = NULL,
  max_points = NULL,
  title = NULL,
  subtitle = NULL
)
```

## Arguments

- data:

  A GWAS data frame. It is passed through
  [`validate_gwas()`](https://loukesio.github.io/gwasplot/reference/validate_gwas.md),
  so raw column names (e.g. `BP`, `pvalue`) are accepted.

- threshold:

  Genome-wide significance p-value drawn as a solid line (default
  `5e-8`). Use `NULL` to omit.

- suggestive:

  Suggestive significance p-value drawn as a dashed line (default
  `1e-5`). Use `NULL` to omit.

- highlight:

  A
  [`highlight_top()`](https://loukesio.github.io/gwasplot/reference/highlight_top.md)
  specification, a single number (shorthand for `top_n`), or `NULL` for
  no highlighting. Highlighted markers are drawn in `highlight_color`.

- label:

  Logical; label the highlighted markers (default `TRUE` when
  `highlight` is given). Requires the highlighted set to be non-empty.

- label_by:

  Column used for labels, `"gene"` (default, falls back to `"SNP"` if
  absent) or `"SNP"`.

- colors:

  Length-2 vector of alternating chromosome-band colours.

- highlight_color:

  Colour for highlighted markers and their labels.

- point_size, point_alpha:

  Size and alpha of the non-highlighted points.

- ylim:

  Optional numeric length-2 y-axis limit on the \\-\log\_{10}(P)\\
  scale.

- interactive:

  Logical; if `TRUE`, points carry hover tooltips (SNP, gene,
  chromosome, position, p-value) and the plot is returned as an
  interactive `girafe` widget. Requires the ggiraph package.

- big_data:

  Logical; enable the large-GWAS pipeline (millions of SNPs). The dense
  background is drawn as a rasterised bitmap layer — all points kept,
  via scattermore — instead of one grob per point. When combined with
  `interactive = TRUE`, only the highlighted markers become an
  interactive layer (they are the only points worth hovering), so the
  widget stays light. Leaving `big_data = FALSE` uses the ordinary
  vector point layer and changes nothing.

- raster:

  Logical or `NULL`; draw the points as a rasterised bitmap layer (keeps
  all points, bounded render cost). `NULL` lets `big_data` decide.
  Requires scattermore.

- max_points:

  Optional integer; if set, the data is thinned to about this many
  points with
  [`thin_gwas()`](https://loukesio.github.io/gwasplot/reference/thin_gwas.md)
  before plotting (all hits kept).

- title, subtitle:

  Optional plot title and subtitle.

## Value

A [ggplot2::ggplot](https://ggplot2.tidyverse.org/reference/ggplot.html)
object, or a
[`ggiraph::girafe()`](https://davidgohel.github.io/ggiraph/reference/girafe.html)
htmlwidget when `interactive = TRUE`.

## See also

[`highlight_top()`](https://loukesio.github.io/gwasplot/reference/highlight_top.md),
[`gwas_chromosome()`](https://loukesio.github.io/gwasplot/reference/gwas_chromosome.md),
[`gwas_table()`](https://loukesio.github.io/gwasplot/reference/gwas_table.md),
[`theme_gwasplot()`](https://loukesio.github.io/gwasplot/reference/theme_gwasplot.md)

## Examples

``` r
data(gwas_example)
gwas_manhattan(gwas_example)

gwas_manhattan(gwas_example, highlight = highlight_top(top_n = 5))
```
