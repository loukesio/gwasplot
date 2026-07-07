test_that("gwas_top returns the requested number of markers, ordered by P", {
  data(gwas_example)
  tp <- gwas_top(gwas_example, highlight = highlight_top(top_n = 5))
  expect_s3_class(tp, "tbl_df")
  expect_equal(nrow(tp), 5)
  expect_true(!is.unsorted(tp$P))
  expect_true("neg_log10_p" %in% names(tp))
})

test_that("gwas_top numeric shorthand works and columns can be chosen", {
  data(gwas_example)
  tp <- gwas_top(gwas_example, highlight = 3, columns = c("SNP", "P"))
  expect_equal(nrow(tp), 3)
  expect_equal(names(tp), c("SNP", "P"))
})

test_that("gwas_top keeps the trait column for multi-trait data", {
  data(gwas_multi)
  tp <- gwas_top(gwas_multi, highlight = highlight_top(top_n = 1, by = "trait"))
  expect_true("trait" %in% names(tp))
  expect_setequal(unique(tp$trait), c("height", "bmi", "glucose"))
})

test_that("gwas_table returns a gt object when gt is available", {
  skip_if_not_installed("gt")
  data(gwas_example)
  g <- gwas_table(gwas_example, highlight = highlight_top(top_n = 6))
  expect_s3_class(g, "gt_tbl")
})

test_that("gwas_table title/subtitle do not error", {
  skip_if_not_installed("gt")
  data(gwas_example)
  expect_s3_class(
    gwas_table(gwas_example, highlight = 4, title = "T", subtitle = "S"),
    "gt_tbl"
  )
})
