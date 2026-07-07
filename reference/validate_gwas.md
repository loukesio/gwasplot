# Validate and standardise a GWAS data frame

Checks that a data frame contains the columns required by gwasplot and
returns a tidy, type-coerced
[tibble](https://tibble.tidyverse.org/reference/tibble.html) with
canonical column names. Column names are auto-detected from a set of
common aliases (for example `BP` or `position` map to `POS`; `pvalue`
maps to `P`) or can be supplied explicitly.

## Usage

``` r
validate_gwas(
  data,
  snp = NULL,
  chr = NULL,
  pos = NULL,
  p = NULL,
  gene = NULL,
  trait = NULL,
  na.rm = TRUE
)
```

## Arguments

- data:

  A data frame of GWAS summary statistics.

- snp, chr, pos, p:

  Optional strings giving the column names to use for each role,
  overriding auto-detection.

- gene, trait:

  Optional strings giving the column names to use for the (optional)
  gene and trait roles.

- na.rm:

  Logical; drop rows with a missing `CHR`, `POS` or `P` (default
  `TRUE`).

## Value

A [tibble](https://tibble.tidyverse.org/reference/tibble.html) with
columns `SNP`, `CHR` (ordered factor), `POS` (numeric), `P` (numeric)
first, followed by `gene` and/or `trait` when present, and then any
remaining columns from `data`.

## Details

The canonical contract is four required columns — `SNP` (marker id),
`CHR` (chromosome), `POS` (base-pair position) and `P` (p-value) — plus
two optional columns, `gene` and `trait`. `CHR` is returned as an
ordered factor in natural genomic order (see
[`order_chromosomes()`](https://loukesio.github.io/gwasplot/reference/order_chromosomes.md)).
Any additional columns in `data` are preserved, which is convenient for
interactive tooltips.

## Examples

``` r
df <- data.frame(
  marker = c("rs1", "rs2", "rs3"),
  chrom  = c(1, 1, 2),
  bp     = c(100, 200, 150),
  pvalue = c(1e-8, 0.2, 3e-3)
)
validate_gwas(df)
#> # A tibble: 3 × 4
#>   SNP   CHR     POS          P
#>   <chr> <fct> <dbl>      <dbl>
#> 1 rs1   1       100 0.00000001
#> 2 rs2   1       200 0.2       
#> 3 rs3   2       150 0.003     
```
