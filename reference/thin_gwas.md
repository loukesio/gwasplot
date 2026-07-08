# Thin a large GWAS data frame for plotting

Reduces a very large GWAS table to a manageable number of points while
preserving its appearance and *every* interesting association. All
markers with `P <= keep_below` are kept unconditionally; the dense null
background is grid-thinned — the genome (x) by \\-\log\_{10}(P)\\ (y)
plane is divided into cells and one representative point is kept per
cell — and, if still above budget, randomly sub-sampled down to
`max_points`. The number of dropped markers is reported with a message
(never silently).

## Usage

``` r
thin_gwas(
  data,
  max_points = 2e+05,
  keep_below = 0.01,
  n_pos_bins = 1500,
  n_p_bins = 300,
  seed = NULL
)
```

## Arguments

- data:

  A GWAS data frame (passed through
  [`validate_gwas()`](https://loukesio.github.io/gwasplot/reference/validate_gwas.md)).

- max_points:

  Approximate upper bound on the number of retained markers.

- keep_below:

  Keep every marker with `P` at or below this value, regardless of
  budget (default `1e-2`).

- n_pos_bins, n_p_bins:

  Grid resolution for thinning the background: the number of position
  bins along the genome and \\-\log\_{10}(P)\\ bins.

- seed:

  Optional integer seed for the random sub-sampling step.

## Value

A [tibble](https://tibble.tidyverse.org/reference/tibble.html) — the
thinned subset of `data`, with an attribute `"thinned_from"` recording
the original row count.

## Details

This is what `big_data = TRUE` uses for interactive plots, where the
whole data cannot become SVG nodes. For static plots, rasterisation
(`raster = TRUE`) is usually preferable because it keeps all points.

## See also

[`gwas_manhattan()`](https://loukesio.github.io/gwasplot/reference/gwas_manhattan.md)
(`big_data` argument)

## Examples

``` r
big <- simulate_gwas(n_chr = 22, snps_per_chr = 5000, seed = 1)
nrow(big)
#> [1] 74250
small <- thin_gwas(big, max_points = 5000)
#> thin_gwas(): kept 5,000 of 74,250 markers (844 hits at P<=0.01 + 4,156 background); dropped 69,250.
nrow(small)
#> [1] 5000
```
