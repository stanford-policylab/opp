#!/usr/bin/env Rscript

suppressPackageStartupMessages(source("lib/utils.R"))
source("lib/schema.R")


main <- function() {
  args <- get_args()
  process(args$state, args$city)
  q(status = 0)
}


get_args <- function() {
  usage <- "./process.R [-h] -s <state_name> -c <city_name>"
  spec <- tribble(
    ~long_name, ~short_name,  ~argument_type, ~data_type,
    "help",     "h",          "none",         "logical",
    "state",    "s",          "required",     "character",
    "city",     "c",          "required",     "character"
  )
  args <- parse_args(spec)

  if (not_null(args$help)) {
    print(usage)
    q(status = 0)
  }

  if (is.null(args$state) || is.null(args$city)) {
    print(usage)
    q(status = 1)
  }

  args
}


process <- function(state, city) {
  source_opp_funcs_for(state, city)
  print("loading data...")
  raw_data <- opp_load_raw()
  print("cleaning data...")
  clean_data <- opp_clean(raw_data)
  print("verifying schema...")
  verify_schema(clean_data)
  print("saving data...")
  opp_save(clean_data)
}


main()
