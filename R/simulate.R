#' Simulate a GWAS summary-statistics data frame
#'
#' Generates a reproducible, tidy GWAS-style data frame with a uniform
#' background of null p-values plus a handful of injected association peaks.
#' It is used to build the package's bundled example datasets and is handy for
#' examples, tests and quickly trying out the plotting functions.
#'
#' @param n_chr Number of chromosomes.
#' @param snps_per_chr Approximate number of SNPs per chromosome. Chromosome
#'   lengths (and hence SNP counts) taper for higher-numbered chromosomes.
#' @param n_peaks Number of association peaks to inject across the genome.
#' @param traits Optional character vector of trait names. When supplied
#'   (length > 1), the returned frame gains a `trait` column with independent
#'   peaks per trait --- suitable for multi-ring circular plots.
#' @param seed Optional integer seed for reproducibility.
#'
#' @return A [tibble][tibble::tibble] with columns `SNP`, `CHR`, `POS`, `P`,
#'   `gene`, and (when `traits` has length > 1) `trait`.
#' @export
#'
#' @examples
#' head(simulate_gwas(n_chr = 5, snps_per_chr = 200, seed = 1))
simulate_gwas <- function(n_chr = 22,
                          snps_per_chr = 1000,
                          n_peaks = 8,
                          traits = NULL,
                          seed = NULL) {
  if (!is.null(seed)) set.seed(seed)

  # Chromosome lengths taper roughly like real genomes.
  chr_len <- round(snps_per_chr * seq(1, 0.35, length.out = n_chr))
  chr_len[chr_len < 50] <- 50

  make_one <- function() {
    chr <- rep(seq_len(n_chr), times = chr_len)
    pos <- unlist(lapply(chr_len, function(k) sort(sample.int(1e8, k))),
                  use.names = FALSE)
    n <- length(chr)
    # Null background: p-values uniform on (0, 1].
    p <- stats::runif(n)

    # Inject peaks: pick random SNPs and give them (and near neighbours)
    # strong signals.
    peak_idx <- sample.int(n, n_peaks)
    for (i in peak_idx) {
      lead <- 10^(-stats::runif(1, 7.5, 14))
      p[i] <- lead
      # Shoulder SNPs around the lead marker.
      window <- intersect((i - 8):(i + 8), seq_len(n))
      window <- window[chr[window] == chr[i]]
      decay <- 10^(-abs(window - i) / 3)
      p[window] <- pmin(p[window], lead / decay)
    }
    p <- pmin(pmax(p, .Machine$double.xmin), 1)

    tibble::tibble(
      SNP = paste0("rs", seq_len(n)),
      CHR = chr,
      POS = pos,
      P   = p,
      gene = paste0("GENE", formatC(as.integer(chr * 1000L + (pos %% 1000)),
                                     width = 5, flag = "0", format = "d"))
    )
  }

  if (is.null(traits) || length(traits) <= 1) {
    out <- make_one()
    if (!is.null(traits)) out$trait <- traits[1]
    return(out)
  }

  parts <- lapply(traits, function(tr) {
    df <- make_one()
    df$trait <- tr
    df
  })
  do.call(rbind, parts)
}
