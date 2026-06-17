library(fozziejoin)
library(fuzzyjoin)
library(bench)
library(tibble)
source("helpers.R")

# Load DIME data
dimedat <- load_dime()

NUM_THREADS <- 16
NTIMES <- 10
SAMP_SIZES <- seq(3000, 5000, 1000)

params <- list(
  list(method = "osa", max_dist = 1, q = 0),
  list(method = "lv", max_dist = 1, q = 0),
  list(method = "dl", max_dist = 1, q = 0),
  list(method = "hamming", max_dist = 1, q = 0),
  list(method = "lcs", max_dist = 1, q = 0),
  list(method = "qgram", max_dist = 2, q = 2),
  list(method = "cosine", max_dist = 0.5, q = 2),
  list(method = "jaccard", max_dist = 0.5, q = 2),
  list(method = "jw", max_dist = 0.5, q = 0),
  list(method = "soundex", max_dist = 0.5, q = 0)
)

args <- commandArgs(trailingOnly = TRUE)
if (length(args) > 0) {
  params <- Filter(function(p) p$method %in% args, params)
}

results <- data.frame()

for (p in params) {
  for (nsamp in SAMP_SIZES) {
    sampdf <- head(dimedat, nsamp)
    res <- bench::mark(
      fuzzyjoin = stringdist_join(
        sampdf, sampdf,
        method = p$method,
        by = 'name',
        max_dist = p$max_dist,
        q = p$q,
        nthread = NUM_THREADS,
      ),
      fozziejoin = fozzie_string_join(
        sampdf, sampdf,
        by = 'name',
        method = p$method, how = 'inner',
        max_distance = p$max_dist,
        nthread = NUM_THREADS,
        q = p$q
      ),
      iterations = NTIMES,
      check = FALSE
    )

    # Add join method and row data points
    res$method <- p$method
    res$samp_size <- nrow(sampdf)

    # Type conversions
    res$median <- as.numeric(res$median)
    res$mem_alloc <- as.numeric(res$mem_alloc)
    res$expression <- as.character(res$expression)

    # Add subset of columns to running results target
    keep_cols <- c('expression', 'method', 'samp_size', 'median', 'mem_alloc')
    print(res[, keep_cols])
    results <- rbind(results, res[, keep_cols])
  }
}

vroom::vroom_write(results, 'results/fuzzy_fozzie_string.csv')
