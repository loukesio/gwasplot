# Generates the bundled example datasets for gwasplot.
# Run with: source("data-raw/make_example_data.R")
# (or `R CMD BATCH`), then rebuild/reinstall the package.

library(gwasplot)  # or: devtools::load_all()

# Single-trait example: 22 chromosomes, ~ modest size to keep the .rda small.
gwas_example <- validate_gwas(
  simulate_gwas(n_chr = 22, snps_per_chr = 400, n_peaks = 10, seed = 42)
)

# Multi-trait example for the multi-ring circular plot.
gwas_multi <- validate_gwas(
  simulate_gwas(
    n_chr = 22, snps_per_chr = 300, n_peaks = 6,
    traits = c("height", "bmi", "glucose"), seed = 7
  )
)

usethis::use_data(gwas_example, overwrite = TRUE, compress = "xz")
usethis::use_data(gwas_multi, overwrite = TRUE, compress = "xz")
