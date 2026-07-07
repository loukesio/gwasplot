# Example single-trait GWAS results

A simulated genome-wide association study over 22 chromosomes with a
uniform null background and several injected association peaks.
Generated with
[`simulate_gwas()`](https://loukesio.github.io/gwasplot/reference/simulate_gwas.md)
using a fixed seed; see `data-raw/make_example_data.R`.

## Usage

``` r
gwas_example
```

## Format

A [tibble](https://tibble.tidyverse.org/reference/tibble.html) with one
row per SNP and columns:

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

## Source

Simulated with
[`simulate_gwas()`](https://loukesio.github.io/gwasplot/reference/simulate_gwas.md).
