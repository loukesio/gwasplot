# Example multi-trait GWAS results

A simulated study of three traits sharing the same genome layout, each
with its own injected association peaks. Intended for the multi-ring
circular plot
([`gwas_circular()`](https://loukesio.github.io/gwasplot/reference/gwas_circular.md)).
Generated with
[`simulate_gwas()`](https://loukesio.github.io/gwasplot/reference/simulate_gwas.md);
see `data-raw/make_example_data.R`.

## Usage

``` r
gwas_multi
```

## Format

A [tibble](https://tibble.tidyverse.org/reference/tibble.html) with one
row per SNP-by-trait and columns:

- SNP:

  Marker identifier (character).

- CHR:

  Chromosome, an ordered factor in natural genomic order.

- POS:

  Base-pair position within the chromosome (numeric).

- P:

  Association p-value (numeric, in (0, 1\]).

- gene:

  Nearest-gene label (character).

- trait:

  Trait / phenotype name (character): one of `"height"`, `"bmi"`,
  `"glucose"`.

## Source

Simulated with
[`simulate_gwas()`](https://loukesio.github.io/gwasplot/reference/simulate_gwas.md).
