# Specify which top markers to highlight

A small constructor that bundles a highlight specification for reuse
across the plotting functions and the top-hits table. Criteria are
combined as a union: a marker is highlighted if it satisfies *any* of
the supplied rules.

## Usage

``` r
highlight_top(
  top_n = NULL,
  threshold = NULL,
  snps = NULL,
  genes = NULL,
  by = NULL
)
```

## Arguments

- top_n:

  Integer; highlight the `top_n` markers with the smallest p-values (per
  group when `by` is set).

- threshold:

  Numeric p-value; highlight markers with `P <= threshold`.

- snps, genes:

  Character vectors of `SNP` ids / `gene` names to highlight.

- by:

  Optional grouping column applied before `top_n` (e.g. `"CHR"` for the
  top hit on each chromosome, or `"trait"`).

## Value

An object of class `"gwas_highlight"` (a list of the criteria).

## Examples

``` r
highlight_top(top_n = 10)
#> $top_n
#> [1] 10
#> 
#> $threshold
#> NULL
#> 
#> $snps
#> NULL
#> 
#> $genes
#> NULL
#> 
#> $by
#> NULL
#> 
#> attr(,"class")
#> [1] "gwas_highlight"
highlight_top(threshold = 5e-8, genes = c("GENE01000"))
#> $top_n
#> NULL
#> 
#> $threshold
#> [1] 5e-08
#> 
#> $snps
#> NULL
#> 
#> $genes
#> [1] "GENE01000"
#> 
#> $by
#> NULL
#> 
#> attr(,"class")
#> [1] "gwas_highlight"
highlight_top(top_n = 1, by = "CHR")  # lead SNP per chromosome
#> $top_n
#> [1] 1
#> 
#> $threshold
#> NULL
#> 
#> $snps
#> NULL
#> 
#> $genes
#> NULL
#> 
#> $by
#> [1] "CHR"
#> 
#> attr(,"class")
#> [1] "gwas_highlight"
```
