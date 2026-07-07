# Order chromosome labels in natural genomic order

Numeric chromosomes are sorted ascending, followed by the sex and
mitochondrial chromosomes (`X`, `Y`, `XY`, `MT`/`M`) and finally any
other labels alphabetically. A leading `"chr"` prefix is ignored when
sorting but preserved in the returned levels.

## Usage

``` r
order_chromosomes(x)
```

## Arguments

- x:

  A vector of chromosome labels.

## Value

A character vector of the unique labels in natural order, suitable for
use as factor levels.

## Examples

``` r
order_chromosomes(c("chr2", "chr10", "chrX", "chr1"))
#> [1] "chr1"  "chr2"  "chr10" "chrX" 
```
