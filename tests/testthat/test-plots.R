test_that("gwas_manhattan returns a ggplot with expected layers", {
  data(gwas_example)
  p <- gwas_manhattan(gwas_example)
  expect_s3_class(p, "ggplot")
  # points + suggestive line + genome-wide line
  expect_gte(length(p$layers), 3)
})

test_that("gwas_manhattan accepts raw (unvalidated) input", {
  df <- data.frame(
    marker = paste0("rs", 1:50),
    chrom  = rep(1:2, each = 25),
    bp     = c(1:25, 1:25) * 1000,
    pvalue = runif(50)
  )
  expect_s3_class(gwas_manhattan(df), "ggplot")
})

test_that("highlight adds highlight + label layers", {
  data(gwas_example)
  p0 <- gwas_manhattan(gwas_example, highlight = NULL)
  p1 <- gwas_manhattan(gwas_example, highlight = highlight_top(top_n = 5))
  expect_gt(length(p1$layers), length(p0$layers))
})

test_that("highlight numeric shorthand equals top_n", {
  data(gwas_example)
  p1 <- gwas_manhattan(gwas_example, highlight = 5)
  p2 <- gwas_manhattan(gwas_example, highlight = highlight_top(top_n = 5))
  expect_equal(length(p1$layers), length(p2$layers))
})

test_that("gwas_chromosome subsets to one chromosome", {
  data(gwas_example)
  p <- gwas_chromosome(gwas_example, chr = 1)
  expect_s3_class(p, "ggplot")
  expect_true(all(as.character(p$data$CHR) == "1"))
})

test_that("gwas_chromosome errors on an absent chromosome", {
  data(gwas_example)
  expect_error(gwas_chromosome(gwas_example, chr = 999), "not found")
})

test_that("gwas_chromosome respects a base-pair window", {
  data(gwas_example)
  rng <- range(gwas_example$POS[gwas_example$CHR == "1"])
  mid <- mean(rng)
  p <- gwas_chromosome(gwas_example, chr = 1, xlim = c(rng[1], mid))
  expect_true(max(p$data$POS) <= mid)
})

test_that("highlight_top validates its input", {
  expect_error(highlight_top(), "at least one")
  expect_s3_class(highlight_top(top_n = 3), "gwas_highlight")
})

test_that(".select_top with by = 'CHR' picks one lead per chromosome", {
  data(gwas_example)
  v <- validate_gwas(gwas_example)
  sel <- gwasplot:::.select_top(v, top_n = 1, by = "CHR")
  expect_equal(nrow(sel), nlevels(droplevels(v$CHR)))
})
