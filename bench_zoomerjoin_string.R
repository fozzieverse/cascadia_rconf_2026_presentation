# bench_zoomerjoin_jaccard.R
# 6/1/2026
# Performs benchmarks of string distance in zoomerjoin vs. fozziejoin
# Uses bench package for benchamrks. This is somewhat flawed because it does
# not track memory utilization in Rust. However, peak memory utilization
# happens on the R side of both packages, so this problem should be ignorable.

# Global parameters
NTIMES <- 10
NUM_THREADS <- 16

# Zoomerjoin parameters
BANDWIDTH <- 11
NUM_BANDS <- 350

# Join-specific parameters
MAX_DISTANCE_JACCARD <- 0.3 # Jaccard max distance
SAMP_SIZES_JACCARD <- seq(1e6, 2e6, 5e5) # Sample sizes for Jaccard
MAX_DISTANCE_HAMMING <- 2 # Hamming max distance
SAMP_SIZES_HAMMING <- seq(5e4, 1e5, 2.5e4) # Sample sizes for Hamming

# Load libraries
library(fozziejoin)
library(zoomerjoin)
library(bench)
library(tibble)
source("helpers.R")

# Load DIME data
dimedat <- load_dime()
dimedat <- tibble(dimedat)

# Jaccard string: begin benchmark loop
results <- data.frame()
for (nsamp in SAMP_SIZES_JACCARD) {
  cat(sprintf("Running Jaccard with %d samples\n", nsamp))
  sampdf <- dimedat[1:nsamp, ]

  res <- bench::mark(
    zoomer = jaccard_inner_join(
      sampdf, sampdf,
      by = 'name',
      n_bands = NUM_BANDS,
      band_width = BANDWIDTH,
      threshold = 1 - MAX_DISTANCE_JACCARD,
      nthread = NUM_THREADS,
      n_gram_width = 4,
    ),
    fozzie = fozzie_string_join(
      sampdf, sampdf,
      by = 'name',
      method = 'jaccard', how = 'inner',
      max_distance = MAX_DISTANCE_JACCARD,
      nthread = NUM_THREADS,
      q = 4
    ),
    iterations = NTIMES,
    check = FALSE
  )
  print(res)

  # Add join method and row data points
  res$method <- 'Jaccard'
  res$samp_size <- nrow(sampdf)

  # Type conversions
  res$median <- as.numeric(res$median)
  res$mem_alloc <- as.numeric(res$mem_alloc)
  res$expression <- as.character(res$expression)

  # Add subset of columns to running results target
  keep_cols <- c('expression', 'method', 'samp_size', 'median', 'mem_alloc')
  results <- rbind(results, res[, keep_cols])
}

# Hamming string: begin benchmark loop
for (nsamp in SAMP_SIZES_HAMMING) {
  cat(sprintf("Running Hamming with %d samples\n", nsamp))
  sampdf <- dimedat[1:nsamp, ]

  res <- bench::mark(
    zoomer = hamming_inner_join(
      sampdf, sampdf,
      by = 'name',
      n_bands = NUM_BANDS,
      band_width = BANDWIDTH,
      threshold =  MAX_DISTANCE_HAMMING,
      nthread = NUM_THREADS,
    ),
    fozzie = fozzie_string_join(
      sampdf, sampdf,
      by = 'name',
      method = 'hamming', how = 'inner',
      max_distance = MAX_DISTANCE_HAMMING,
      nthread = NUM_THREADS,
    ),
    iterations = NTIMES,
    check = FALSE
  )
  print(res)

  # Add join method and row data points
  res$method <- 'Hamming'
  res$samp_size <- nrow(sampdf)

  # Type conversions
  res$median <- as.numeric(res$median)
  res$mem_alloc <- as.numeric(res$mem_alloc)
  res$expression <- as.character(res$expression)

  # Add subset of columns to running results target
  keep_cols <- c('expression', 'method', 'samp_size', 'median', 'mem_alloc')
  results <- rbind(results, res[, keep_cols])
}

# Write to file
vroom::vroom_write(results, './results/zoomer_fozzie_string.csv')
