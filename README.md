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

The easiest way is to run the following command from within the opp
   directory
```
./run.R --paper
```
Each analysis can actually be run independently, as well:
```
./run.R --{disparity,marijuana,veil_of_darkness,prima_facie_stats}
```
