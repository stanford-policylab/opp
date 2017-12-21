#!/usr/bin/env Rscript

setwd("lib")
suppressMessages(source("opp.R"))


main <- function() {
  args <- get_args()
  if (not_null(args$process))
    opp_process(args$state, args$city, args$sample_n)
  if (not_null(args$report))
    opp_report(args$state, args$city)
  if (not_null(args$plot))
    opp_plot(args$state, args$city)
  print("Finished!")
  q(status = 0)
}


get_args <- function() {
  usage <- str_c("./run.R",
                 "[--help]",
                 "[--process]",
                 "[--sample]",
                 "[--report]",
                 "[--plot]",
                 "-s <state_code>",
                 "-c <city_name>",
                 sep = " ")
  spec <- tribble(
    ~long_name,   ~short_name,  ~argument_type, ~data_type,
    "help",       "h",          "none",         "logical",
    "process",    "o",          "none",         "logical",
    "sample_n",   "n",          "none",         "integer",
    "report",     "r",          "none",         "logical",
    "plot",       "p",          "none",         "logical",
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
