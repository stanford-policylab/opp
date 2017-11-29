#!/usr/bin/env Rscript
library(tibble)

setwd("lib")
source("opp.R")


main <- function() {
  args <- get_args()
  if (not_null(args$process))
    opp_process(args$state, args$city)
  if (not_null(args$report))
    opp_report(args$state, args$city)
  if (not_null(args$plot))
    opp_plot(args$state, args$city)
  if (not_null(args$null_rates))
    print(get_null_rates(opp_load(args$state, args$city)))
  q(status = 0)
}


get_args <- function() {
  usage <- str_c("./run.R",
                 "[--help]",
                 "[--process]",
                 "[--report]",
                 "[--plot]",
                 "[--null_rates]",
                 "-s <state_code>",
                 "-c <city_name>",
                 sep = " ")
  spec <- tribble(
    ~long_name,   ~short_name,  ~argument_type, ~data_type,
    "help",       "h",          "none",         "logical",
    "process",    "o",          "none",         "logical",
    "report",     "r",          "none",         "logical",
    "plot",       "p",          "none",         "logical",
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


if (!interactive()) {
  main()
}
