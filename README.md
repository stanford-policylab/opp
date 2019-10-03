# Open Policing Project (OPP)

## Required System Packages

### All Systems
* R

### Fedora
* gdal-devel
* proj-nad
* proj-epsg
* proj-devel
* v8-314-devel (libv8-3.14-dev ubuntu)
* libjpeg-turbo-devel

### Mac

## Getting Started
1. [command line] Clone the repository
```
git clone https://github.com/stanford-policylab/opp.git
```
2. [command line] Change directories
```
cd opp/lib
```
3. [command line] Start R
```
R
```
4. [R] install the required packages
```R
install.packages(c(
  "assertr",
  "broom",
  "digest",
  "fs",
  "functional",
  "getopt",
  "here",
  "housingData",
  "jsonlite",
  "knitr",
  "lubridate",
  "lazyeval",
  "lutz",
  "magrittr",
  "maps",
  "parallel",
  "purrr",
  "rlang",
  "rmarkdown",
  "rgdal",
  "rstan",
  "scales",
  "sp",
  "splines",
  "suncalc",
  "tidyverse",
  "zoo"
))
```
5. [R] load the main library
```R
source("opp.R")
```
6. [R] download some clean data
```R
opp_download_clean_data("wa", "seattle")
```
7. [R] load the clean data
```R
d <- opp_load_clean_data("wa", "seattle")
```

## Recreating Analyses

The easiest way to rerun all analyses is the following:
```
./run.R --paper
```
However, for this to work, all the data must be downloaded and available
locally. To do this we, recommend setting the data directory to a location with
sufficient space and ensuring a healthy internet connection while up to 20Gb
of data are downloaded. From within R, this can be done with the following:
```
source('opp.R')
opp_set_download_directory('/my/data/directory')
opp_download_all_clean_data()
```

Each analysis can also be run independently from command line:
```
./run.R --{disparity,marijuana,veil_of_darkness,prima_facie_stats}
```
They can also be run from within R code:
```
source('opp.R')
opp_run_{paper_analyses,disparity,marijuana_legalization_analysis,veil_of_darkness,prima_facie_stats}
```
Each of these effectively loads and runs the corresponding analysis script(s),
which will be one of `disparity.R`, `veil_of_darkness.R`,
`marijuana_legalization_analysis.R`, and `prima_facie_stats.R`. `disparity.R`
contains both the outcome and threshold tests, which are also available as
independent scripts in `outcome_test.R` and `threshold_test.R`. After running
each of these, the results are saved in the opp/results directory. The analyses
take anywhere from ~20 minutes to several hours to run. To run all the analyses
will take about a day on a modern server.

Each of these analyses requires different subsets of the clean data and loads
them using the `load` function defined in `eligibility.R`. The eligibility
script contains all the filters for the data for each of the analyses. To run
these, you will need access to all of the clean data, which can be obtained
using `opp_download_all_clean_data()`; however, this will require up to 20Gb of
space, so we recommend that you run `opp_set_download_directory(<dir>)` first
and make sure that the directory you select on your harddrive has sufficient
space. By default, the load functions perform all the filters and create the
filtered dataset fresh, but it automatically saves the result to the
`opp/cache` directory. If you run load again, you can run
`load(<analysis_name>, use_cache = T)` to speed up load time, as it will use
the post-filtered dataset from the previous run.

## Reprocessing Data
Each location has it's own processing script, and these are located in
`opp/lib/states/state/city.R`. Each script conforms to a contract that
defines two methods: `load_raw` and `clean`. `load_raw` loads and joins all the data
while making minimal changes to the raw data, while clean processes and
standardizes the data to bring it into compliance with our schema defined in
standards.R.

There are many convenience functions defined which can often be
found in `opp.R`, `utils.R`, `standardize.R`, or `sanitizers.R`. At the end of most of
these cleaning scripts there is a standarize function that adds calculated
columns, selects only those columns in the schema (including those prefixed
with `raw_*`), enforces data types (as defined in `standards.R`), corrects
predicates (i.e. if contraband found was true but search conducted was false,
contraband found is coerced to false, since nothing should be found if a search
wasn't conducted -- all of these choices can be seen at the bottom of
`standards.R` in the `predicated_columns` list).

If given access to the raw data, you should be able to modify the script
associated with that location and run `./run.R --process --state <state> --city
<city>` and it will reprocess that location using the updated script.

Raw data is available upon request.
