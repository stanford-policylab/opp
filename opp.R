#!/usr/bin/env Rscript
library(stringr)
library(tibble)

source("lib/utils.R")


main <- function() {
  args <- get_args()
  if (not_null(args$process))
    opp_process(args$state, args$city)
  if (not_null(args$plot))
    opp_plot(args$state, args$city)
  if (not_null(args$null_rates))
    print(get_null_rates(opp_load(args$state, args$city)))
  q(status = 0)
}


get_args <- function() {
  usage <- str_c("./opp.R",
                 "[--help|-h]",
                 "[--process|-r]",
                 "[--plot|-l]",
                 "[--null_rates|-n]",
                 "-s <state_code>",
                 "-c <city_name>",
                 sep = " ")
  spec <- tribble(
    ~long_name,   ~short_name,  ~argument_type, ~data_type,
    "help",       "h",          "none",         "logical",
    "process",    "r",          "none",         "logical",
    "plot",       "l",          "none",         "logical",
    "null_rates", "n",          "none",         "logical",
    "state",      "s",          "required",     "character",
    "city",       "c",          "required",     "character"
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


opp_load <- function(state, city) {
  readRDS(opp_clean_data_path(state, city))
}


opp_clean_data_path <- function(state, city) {
  # NOTE: all clean data is stored and loaded in RDS format to
  # maintain data types
  data_dir = opp_data_dir(state, city)
  str_c(data_dir, "clean/", str_to_lower(city), ".rds")
}


opp_data_dir <- function(state, city) {
  str_c("data/states/",
        str_to_lower(state), "/",
        str_to_lower(city), "/")
}


opp_load_raw <- function(state, city) {
  source(opp_processor_path(state, city), local = TRUE)
  load_raw(opp_raw_data_dir(state, city),
           opp_geocodes_path(state, city))
}


opp_processor_path <- function(state, city) {
  str_c("lib/states/", str_to_lower(state), "/", str_to_lower(city), ".R")
}


opp_raw_data_dir <- function(state, city) {
  data_dir = opp_data_dir(state, city)
  str_c(data_dir, "raw_csv/")
}


opp_geocodes_path <- function(state, city) {
  data_dir = opp_data_dir(state, city)
  str_c(data_dir, "geocodes/geocoded_locations.csv")
}


opp_clean <- function(tbl, state, city) {
  source(opp_processor_path(state, city), local = TRUE)
  clean(tbl)
}


opp_save <- function(tbl, state, city) {
  saveRDS(tbl, opp_clean_data_path(state, city))
}


opp_process <- function(state, city) {
  source(opp_processor_path(state, city), local = TRUE)
  d <- load_raw(opp_raw_data_dir(state, city),
                opp_geocodes_path(state, city))
  dc <- clean(d)
  opp_save(dc, state, city)
}


opp_plot <- function(state, city) {
  source("lib/plot.R", local = TRUE)
  plot_cols(opp_load(state, city), str_c(state, city, "plots.pdf", sep = "_"))
}


if (!interactive()) {
  main()
}
