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
