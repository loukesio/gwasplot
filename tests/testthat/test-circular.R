test_that("gwas_circular returns a ggplot for multi-trait data", {
  data(gwas_multi)
  p <- gwas_circular(gwas_multi)
  expect_s3_class(p, "ggplot")
})

test_that("gwas_circular collapses to a single ring without a trait column", {
  data(gwas_example)
  p <- gwas_circular(gwas_example)
  expect_s3_class(p, "ggplot")
  # single ring -> legend suppressed
  expect_equal(p$theme$legend.position, "none")
})

test_that("multi-trait keeps the legend", {
  data(gwas_multi)
  p <- gwas_circular(gwas_multi)
  expect_equal(p$theme$legend.position, "right")
})

test_that("forcing trait = NULL yields a single ring", {
  data(gwas_multi)
  p <- gwas_circular(gwas_multi, trait = NULL)
  expect_equal(p$theme$legend.position, "none")
})

test_that("more than six rings warns", {
  set.seed(1)
  df <- simulate_gwas(n_chr = 3, snps_per_chr = 40, n_peaks = 1,
                      traits = paste0("t", 1:7), seed = 3)
  expect_warning(gwas_circular(df), "hard to read")
})

test_that("ideogram can be switched off", {
  data(gwas_example)
  expect_s3_class(gwas_circular(gwas_example, ideogram = FALSE), "ggplot")
})

test_that("highlight adds layers to the circular plot", {
  data(gwas_multi)
  p0 <- gwas_circular(gwas_multi, highlight = NULL)
  p1 <- gwas_circular(gwas_multi, highlight = highlight_top(top_n = 1, by = "trait"))
  expect_gt(length(p1$layers), length(p0$layers))
})

test_that("polar geometry helpers produce finite coordinates", {
  arc <- gwasplot:::.arc_path(0, pi, 1)
  expect_true(all(is.finite(arc$x)) && all(is.finite(arc$y)))
  sec <- gwasplot:::.annulus_sector(0, pi / 2, 0.5, 1)
  expect_true(all(is.finite(sec$x)) && all(is.finite(sec$y)))
})
