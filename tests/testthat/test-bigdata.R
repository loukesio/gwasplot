geom1 <- function(p) class(p$layers[[1]]$geom)[1]

test_that("normal plots are NOT rasterised (big_data must be opt-in)", {
  data(gwas_example)
  expect_equal(geom1(gwas_manhattan(gwas_example)), "GeomPoint")
  expect_equal(geom1(gwas_manhattan(gwas_example, interactive = FALSE)), "GeomPoint")
})

test_that("big_data = TRUE rasterises the background", {
  skip_if_not_installed("scattermore")
  data(gwas_example)
  expect_equal(geom1(gwas_manhattan(gwas_example, big_data = TRUE)),
               "GeomScattermore")
})

test_that("explicit raster = TRUE rasterises even without big_data", {
  skip_if_not_installed("scattermore")
  data(gwas_example)
  expect_equal(geom1(gwas_manhattan(gwas_example, raster = TRUE)),
               "GeomScattermore")
})

test_that("big_data + interactive is a hybrid: raster base, girafe result", {
  skip_if_not_installed("scattermore")
  skip_if_not_installed("ggiraph")
  data(gwas_example)
  p <- gwas_manhattan(gwas_example, big_data = TRUE, interactive = TRUE,
                      highlight = highlight_top(top_n = 5))
  expect_s3_class(p, "girafe")
})

test_that("thin_gwas keeps every significant hit and reports the drop", {
  big <- simulate_gwas(n_chr = 10, snps_per_chr = 2000, n_peaks = 6, seed = 3)
  n_hits <- sum(big$P < 5e-8)
  expect_message(th <- thin_gwas(big, max_points = 3000), "dropped")
  expect_lte(nrow(th), nrow(big))
  expect_equal(sum(th$P < 5e-8), n_hits)  # no hit is ever dropped
})

test_that("thin_gwas is a no-op below the budget", {
  data(gwas_example)
  th <- thin_gwas(gwas_example, max_points = nrow(gwas_example) + 1)
  expect_equal(nrow(th), nrow(gwas_example))
})

test_that("gwas_circular gains a raster layer under big_data", {
  skip_if_not_installed("scattermore")
  data(gwas_multi)
  p <- gwas_circular(gwas_multi, big_data = TRUE)
  expect_true(any(vapply(p$layers,
    function(l) grepl("Scattermore", class(l$geom)[1]), logical(1))))
})
