load_dime <- function(nrows=5e6) {
    # Retrieve from https://data.stanford.edu/dime
    orig_fn <- './data/dime_contributors_1979_2024.rdata'
    if (!file.exists(orig_fn)) {
        cat(sprintf("WARNING: %s not found\n", orig_fn))
        stop("Must download dime data from https://data.stanford.edu/dime")
    }

    # Create or load the subset data for faster loads
    fast_fn <- './data/dime_contributors.Rds'
    if(!file.exists(fast_fn)) {
        cat("No fast file...creating\n")
        load(orig_fn)
        keep_cols <- c('bonica.cid', 'most.recent.contributor.name')
        out <- na.omit(contribs[, keep_cols])

        set.seed(42)
        samp_idx <- sample(nrow(out), nrows)
        dimedat <- out[samp_idx, ]
        names(dimedat) <- c("id_1", "name")
        saveRDS(dimedat, fast_fn, compress=FALSE)
    } else {
        cat("Loading fast file\n")
        dimedat <- readRDS(fast_fn)
    }

    return(dimedat)
}


