# gwasplot <img src="man/figures/logo.png" align="right" height="120" alt="" />

<!-- badges: start -->
<!-- badges: end -->

**gwasplot** is a [ggplot2](https://ggplot2.tidyverse.org)-based toolkit for
visualising genome-wide association study (GWAS) results. It aims to make it
easy to produce publication-ready *and* interactive figures:

- **Linear Manhattan plots** across the genome, with alternating chromosome
  colours and genome-wide / suggestive significance thresholds.
- **Per-chromosome plots** to zoom into a region of interest.
- **Circular (CMplot-style) plots** with support for **multiple concentric
  trait rings**.
- **Easy top-marker highlighting** — by threshold, top-N, or named SNPs/genes,
  with automatic labelling.
- **Interactive versions** via [ggiraph](https://davidgohel.github.io/ggiraph/)
  (hover tooltips showing SNP, gene, chromosome, position and p-value).
- **Companion tables** of the top hits via [gt](https://gt.rstudio.com), in the
  spirit of [ggvolc](https://github.com/loukesio/ggvolc).

> **Status:** early development, but all the core pieces work: the data
> contract (`validate_gwas()`), the Manhattan, single-chromosome and multi-ring
> circular plots, interactive versions via `ggiraph`, and the `gt` top-hits
> table. A vignette and further polish are next.

## Quick start

```r
library(gwasplot)
data(gwas_example)   # single trait
data(gwas_multi)     # three traits, for circular rings

# Manhattan plot, highlighting the top 6 markers
gwas_manhattan(gwas_example, highlight = highlight_top(top_n = 6))

# Zoom into a single chromosome
gwas_chromosome(gwas_example, chr = 1, highlight = highlight_top(top_n = 3))

# Circular plot with one concentric ring per trait
gwas_circular(gwas_multi, highlight = highlight_top(top_n = 1, by = "trait"))
```

## Interactive plots

Any plot becomes an interactive `ggiraph` widget with `interactive = TRUE` —
hover a point to see its SNP, gene, chromosome, position and p-value:

```r
gwas_manhattan(gwas_example, highlight = highlight_top(top_n = 6),
               interactive = TRUE)
gwas_circular(gwas_multi, interactive = TRUE)
```

## Top-markers table

`gwas_table()` builds a publication-ready `gt` table of the top hits (and
`gwas_top()` returns the same selection as a plain tibble). Because it shares
the `highlight_top()` selection logic with the plots, a table and a figure
always agree:

```r
gwas_table(gwas_example, highlight = highlight_top(top_n = 8),
           title = "Top GWAS hits")
```

## Installation

```r
# install.packages("devtools")
devtools::install_github("loukesio/gwasplot")
```

## The data contract

Every plotting function expects a tidy GWAS data frame. `validate_gwas()`
standardises one for you — it auto-detects common column names (e.g. `BP` →
`POS`, `pvalue` → `P`) and returns a clean tibble with `SNP`, `CHR`, `POS`, `P`
(plus optional `gene` and `trait`).

```r
library(gwasplot)

df <- data.frame(
  marker = c("rs1", "rs2", "rs3"),
  chrom  = c(1, 1, 2),
  bp     = c(100, 200, 150),
  pvalue = c(1e-8, 0.2, 3e-3)
)

validate_gwas(df)
```

You can override detection explicitly, e.g. `validate_gwas(df, p = "P_BOLT_LMM")`.

## Example data

Two simulated datasets ship with the package:

```r
data(gwas_example)  # single trait, 22 chromosomes
data(gwas_multi)    # three traits, for multi-ring circular plots
```

## License

MIT © gwasplot authors
