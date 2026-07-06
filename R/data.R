#' Example single-trait GWAS results
#'
#' A simulated genome-wide association study over 22 chromosomes with a uniform
#' null background and several injected association peaks. Generated with
#' [simulate_gwas()] using a fixed seed; see `data-raw/make_example_data.R`.
#'
#' @format A [tibble][tibble::tibble] with one row per SNP and columns:
#' \describe{
#'   \item{SNP}{Marker identifier (character).}
#'   \item{CHR}{Chromosome, an ordered factor in natural genomic order.}
#'   \item{POS}{Base-pair position within the chromosome (numeric).}
#'   \item{P}{Association p-value (numeric, in (0, 1]).}
#'   \item{gene}{Nearest-gene label (character).}
#' }
#' @source Simulated with [simulate_gwas()].
"gwas_example"

#' Example multi-trait GWAS results
#'
#' A simulated study of three traits sharing the same genome layout, each with
#' its own injected association peaks. Intended for the multi-ring circular
#' plot (`gwas_circular()`). Generated with [simulate_gwas()]; see
#' `data-raw/make_example_data.R`.
#'
#' @format A [tibble][tibble::tibble] with one row per SNP-by-trait and columns:
#' \describe{
#'   \item{SNP}{Marker identifier (character).}
#'   \item{CHR}{Chromosome, an ordered factor in natural genomic order.}
#'   \item{POS}{Base-pair position within the chromosome (numeric).}
#'   \item{P}{Association p-value (numeric, in (0, 1]).}
#'   \item{gene}{Nearest-gene label (character).}
#'   \item{trait}{Trait / phenotype name (character): one of `"height"`,
#'     `"bmi"`, `"glucose"`.}
#' }
#' @source Simulated with [simulate_gwas()].
"gwas_multi"
