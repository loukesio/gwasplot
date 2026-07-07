test_that("interactive Manhattan returns a girafe widget", {
  skip_if_not_installed("ggiraph")
  data(gwas_example)
  g <- gwas_manhattan(gwas_example, highlight = highlight_top(top_n = 5),
                      interactive = TRUE)
  expect_s3_class(g, "girafe")
})

test_that("interactive chromosome and circular return girafe widgets", {
  skip_if_not_installed("ggiraph")
  data(gwas_example); data(gwas_multi)
  expect_s3_class(gwas_chromosome(gwas_example, chr = 1, interactive = TRUE),
                  "girafe")
  expect_s3_class(gwas_circular(gwas_multi, interactive = TRUE), "girafe")
})

test_that("interactive = FALSE keeps a plain ggplot", {
  data(gwas_example)
  expect_s3_class(gwas_manhattan(gwas_example, interactive = FALSE), "ggplot")
})

test_that("tooltip text includes the key fields", {
  data(gwas_example)
  tip <- gwasplot:::.tooltip_text(head(validate_gwas(gwas_example), 1))
  expect_match(tip, "SNP:")
  expect_match(tip, "CHR:")
  expect_match(tip, "P:")
})
