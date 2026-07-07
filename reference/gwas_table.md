# A formatted table of the top GWAS markers

Builds a publication-ready
[gt](https://gt.rstudio.com/reference/gt.html) table of the top hits,
mirroring the top-markers table in the ggvolc package. Positions are
shown with thousands separators, p-values in scientific notation, and
\\-\log\_{10}(P)\\ is optionally colour-scaled.

## Usage

``` r
gwas_table(
  data,
  highlight = highlight_top(top_n = 10),
  columns = NULL,
  color = TRUE,
  title = NULL,
  subtitle = NULL
)
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

- color:

  Logical; colour the `neg_log10_p` column by value (default `TRUE`).

- title, subtitle:

  Optional table title and subtitle.

## Value

A `gt` table object (class `gt_tbl`, see
[`gt::gt()`](https://gt.rstudio.com/reference/gt.html)). Requires the gt
package.

## See also

[`gwas_top()`](https://loukesio.github.io/gwasplot/reference/gwas_top.md),
[`gwas_manhattan()`](https://loukesio.github.io/gwasplot/reference/gwas_manhattan.md),
[`gwas_circular()`](https://loukesio.github.io/gwasplot/reference/gwas_circular.md)

## Examples

``` r
if (requireNamespace("gt", quietly = TRUE)) {
  data(gwas_example)
  gwas_table(gwas_example, highlight = highlight_top(top_n = 8))
}


  

SNP
```
