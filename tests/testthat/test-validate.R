test_that("validate_gwas detects common column aliases", {
  df <- data.frame(
    marker = c("rs1", "rs2", "rs3"),
    chrom  = c(1, 1, 2),
    bp     = c(100, 200, 150),
    pvalue = c(1e-8, 0.2, 3e-3)
  )
  out <- validate_gwas(df)
  expect_s3_class(out, "tbl_df")
  expect_true(all(c("SNP", "CHR", "POS", "P") %in% names(out)))
  expect_s3_class(out$CHR, "factor")
  expect_type(out$POS, "double")
  expect_type(out$P, "double")
})

test_that("validate_gwas errors on missing required columns", {
  df <- data.frame(chrom = 1, bp = 100)  # no p-value column
  expect_error(validate_gwas(df), "required column")
})

test_that("explicit column mapping overrides auto-detection", {
  df <- data.frame(m = "rs1", c = 1, position = 10, my_p = 0.01)
  out <- validate_gwas(df, snp = "m", chr = "c", p = "my_p")
  expect_equal(out$SNP, "rs1")
  expect_equal(as.character(out$CHR), "1")
  expect_equal(out$P, 0.01)
})

test_that("SNP ids are synthesised when absent", {
  df <- data.frame(chr = c(1, 2), pos = c(100, 200), p = c(0.1, 0.2))
  out <- validate_gwas(df)
  expect_equal(out$SNP, c("1:100", "2:200"))
})

test_that("out-of-range p-values are rejected", {
  df <- data.frame(chr = 1, pos = 1, p = 1.5)
  expect_error(validate_gwas(df), "outside")

  df2 <- data.frame(chr = 1, pos = 1, p = -0.1)
  expect_error(validate_gwas(df2), "outside")
})

test_that("negative positions are rejected", {
  df <- data.frame(chr = 1, pos = -5, p = 0.1)
  expect_error(validate_gwas(df), "negative position")
})

test_that("zero p-values are floored with a warning", {
  df <- data.frame(chr = 1, pos = 1, p = 0)
  expect_warning(out <- validate_gwas(df), "flooring")
  expect_true(all(out$P > 0))
  expect_true(all(is.finite(-log10(out$P))))
})

test_that("gene and trait columns are preserved and ordered first", {
  df <- data.frame(
    snp = "rs1", chr = 1, pos = 1, p = 0.1,
    gene = "G1", trait = "height", extra = 99
  )
  out <- validate_gwas(df)
  expect_true(all(c("gene", "trait", "extra") %in% names(out)))
  # canonical + optional roles lead the column order
  expect_equal(names(out)[1:6], c("SNP", "CHR", "POS", "P", "gene", "trait"))
})

test_that("order_chromosomes sorts numerically then X/Y/MT", {
  lev <- order_chromosomes(c("chr2", "chr10", "chrX", "chr1", "chrMT", "chrY"))
  expect_equal(lev, c("chr1", "chr2", "chr10", "chrX", "chrY", "chrMT"))
})

test_that("missing CHR/POS/P rows are dropped with a message", {
  df <- data.frame(chr = c(1, NA, 2), pos = c(1, 2, NA), p = c(0.1, 0.2, 0.3))
  expect_message(out <- validate_gwas(df), "dropped")
  expect_equal(nrow(out), 1)
})
