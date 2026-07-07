# Simulate a GWAS summary-statistics data frame

Generates a reproducible, tidy GWAS-style data frame with a uniform
background of null p-values plus a handful of injected association
peaks. It is used to build the package's bundled example datasets and is
handy for examples, tests and quickly trying out the plotting functions.

## Usage

``` r
simulate_gwas(
  n_chr = 22,
  snps_per_chr = 1000,
  n_peaks = 8,
  traits = NULL,
  seed = NULL
)
```

## Arguments

- n_chr:

  Number of chromosomes.

- snps_per_chr:

  Approximate number of SNPs per chromosome. Chromosome lengths (and
  hence SNP counts) taper for higher-numbered chromosomes.

- n_peaks:

  Number of association peaks to inject across the genome.

- traits:

  Optional character vector of trait names. When supplied (length \> 1),
  the returned frame gains a `trait` column with independent peaks per
  trait — suitable for multi-ring circular plots.

- seed:

  Optional integer seed for reproducibility.

## Value

A [tibble](https://tibble.tidyverse.org/reference/tibble.html) with
columns `SNP`, `CHR`, `POS`, `P`, `gene`, and (when `traits` has length
\> 1) `trait`.

## Examples

``` r
head(simulate_gwas(n_chr = 5, snps_per_chr = 200, seed = 1))
#> # A tibble: 6 × 5
#>   SNP     CHR     POS      P gene     
#>   <chr> <int>   <int>  <dbl> <chr>    
#> 1 rs1       1  982457 0.636  GENE01457
#> 2 rs2       1 1188113 0.0654 GENE01113
#> 3 rs3       1 1846862 0.128  GENE01862
#> 4 rs4       1 2007022 0.493  GENE01022
#> 5 rs5       1 2108412 0.663  GENE01412
#> 6 rs6       1 2571948 0.189  GENE01948
```
