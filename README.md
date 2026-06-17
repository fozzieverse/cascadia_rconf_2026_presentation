# Efficient Fuzzy Joins: Introducing `fozziejoin`

This repository contains code and quarto files for the 2026 Cascadia R Conference
presentation of `fozziejoin`. The published presentation is accessible [here](https://fozzieverse.github.io/cascadia_rconf_2026_presentation/#/title-slide). This repo describes how to run the benchmarking scripts, update parameters, and render the quarto presentation.

## Running reproducible examples

The presentation uses benchmarks from a local machine. Some users may
wish to replicate benchmarks on other hardware. The following steps will get
the examples running.

### Clone repo and change working directory

Some scripts rely on relative paths to load helper functions (`helpers.R`). So
clone the repo and ensure you change the working directory. Also, create
a `data/` subdirectory to store the input datafile from DIME.

```sh
git clone https://github.com/fozzieverse/cascadia_rconf_2026_presentation
cd cascadia_rconf_2026_presentation
mkdir data/
```

### Install packages

The presentation relies on `fozziejoin` 0.0.14, which is not published on CRAN
at time of writing. This development version includes some performance
optimizations to `jaccard` string distances that are relevant to benchmarks

If installing packages yourself, the following packages are required:

```r
install.packages('remotes')
install.packages('fuzzyjoin')
install.packages('zoomerjoin')
install.packages('bench')
install.packages('tibble')
install.packages('tidyr')
install.packages('dplyr')
install.packages('ggplot2')
install.packages('vroom')
install.packages('remotes')

# Recommend installing latest development fozziejoin.
remotes::install_github("fozzieverse/fozziejoin")
```

Alternatively, use `renv` if you have R 4.6.0:

```r
renv::restore()
```

### Download data

Download the [DIME dataset](https://data.stanford.edu/dime). Place the 
`dime_contributors_1879_2024.rdata` file in the `./data/` subfolder.

### Run `fuzzyjoin` benchmark and plot

Run the benchmark scripts to refresh the CSV files and charts in `./results/`.
Users may wish to update the following parameters:

- `NUM_THREADS`: number of threads to use in all tests
- `NTIMES`: number of times to run each benchmark iteration
- `SAMP_SIZES`: number of rows to sample for each benchmark

Advanced users may wish to tweak the `params` object, which sets many of the
join-specific parameters. Note that some parameters (e.g. `q`) are not
applicable in some iterations. In such cases, that parameter is simply ignored.

```sh
Rscript bench_fuzzyjoin_string.R
Rscript plot_fuzzyjoin_string.R
```

### Run `zoomerjoin` benchmark and plot

Note that the `bench_zoomerjoin_string.R` script will take several minutes to run 
and will use >1 GB of RAM in its current configuration. Additionally, users may
update the following parameters:

- `NTIMES`: number of times to repeat each function in benchmarks
- `NUM_THREADS`: number of threads to use across all tests
- `BANDWIDTH` and `NUM_BANDS`: `zoomerjoin` LSH hyperparamters
- `MAX_DISTANCE_JACCARD`: maximum allowable distance metric for Jaccard join
- `SAMP_SIZES_JACCARD`: How large of a subset to take at each iteration for Jaccard join
- `MAX_DISTANCE_HAMMING`: maximum allowable distance metric for Hamming join
- `SAMP_SIZES_HAMMING`: How large of a subset to take at each iteration for Hamming join

```sh
Rscript bench_zoomerjoin_string.R
Rscript plot_zoomerjoin_string.R
```

### Re-render slide deck

After the benchmarks have been refreshed, users can refresh the slide deck.

```sh
quarto render fozziejoin.qmd
```

