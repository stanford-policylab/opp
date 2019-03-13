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

## Required R Packages
```R
install.packages(c(
  "digest",
  "fs",
  "functional",
  "getopt",
  "glue",
  "here",
  "jsonlite",
  "knitr",
  "lubridate",
  "lutz",
  "maps",
  "purrr",
  "rgdal",
  "rlang",
  "rmarkdown",
  "rstan",
  "sp",
  "stringr",
  "suncalc",
  "tidyverse"
))
```

## Getting Started
- Clone the repository
```
git clone https://github.com/stanford-policylab/opp.git
```
- Change directories
```
cd opp/lib
```
- Start R
```
R
```
- from R, load the main library
```R
source("opp.R")
```
- from R, download some clean data
```R
opp_download_clean_data("wa", "seattle")
```
- from R, load the clean data
```R
d <- opp_load_clean_data("wa", "seattle")
```
