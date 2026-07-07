# Extract the top GWAS markers as a tidy table

Returns the top hits selected by a
[`highlight_top()`](https://loukesio.github.io/gwasplot/reference/highlight_top.md)
specification, ordered by p-value, with a `neg_log10_p` column added.
This is the data behind
[`gwas_table()`](https://loukesio.github.io/gwasplot/reference/gwas_table.md)
and uses the same selection logic as the plots' `highlight` argument, so
a table and a figure can be kept perfectly in sync.

## Usage

``` r
gwas_top(data, highlight = highlight_top(top_n = 10), columns = NULL)
```

## Arguments

- data:

  A GWAS data frame (passed through
  [`validate_gwas()`](https://loukesio.github.io/gwasplot/reference/validate_gwas.md)).

- highlight:

  A
  [`highlight_top()`](https://loukesio.github.io/gwasplot/reference/highlight_top.md)
  spec, or a single number (`top_n`). Defaults to the 10 smallest-p
  markers.

- columns:

  Optional character vector of columns to keep (and order). By default
  keeps `SNP`, `gene`, `trait`, `CHR`, `POS`, `P`, `neg_log10_p` when
  present.

## Value

A [tibble](https://tibble.tidyverse.org/reference/tibble.html) of the
selected markers.

## See also

[`gwas_table()`](https://loukesio.github.io/gwasplot/reference/gwas_table.md),
[`highlight_top()`](https://loukesio.github.io/gwasplot/reference/highlight_top.md)

## Examples

``` r
data(gwas_example)
gwas_top(gwas_example, highlight = highlight_top(top_n = 5))
#> # A tibble: 5 × 6
#>   SNP    gene      CHR        POS        P neg_log10_p
#>   <chr>  <chr>     <fct>    <dbl>    <dbl>       <dbl>
#> 1 rs5486 GENE20370 20     1342370 2.55e-13        12.6
#> 2 rs5485 GENE20950 20      651950 5.50e-13        12.3
#> 3 rs5487 GENE20702 20     1501702 5.50e-13        12.3
#> 4 rs646  GENE02691 2     65881691 7.94e-13        12.1
#> 5 rs5484 GENE20446 20      535446 1.18e-12        11.9
```
