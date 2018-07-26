#!/usr/bin/env Rscript

setwd("lib")
suppressMessages(source("opp.R"))


main <- function() {
  args <- get_args()
  if (not_null(args$process))
    opp_process(args$state, args$city, args$n_max)
  if (not_null(args$report))
    opp_report(args$state, args$city)
  if (not_null(args$plot))
    opp_plot(args$state, args$city)
  if (not_null(args$coverage))
    opp_coverage()
  if (not_null(args$everything))
    opp_do_everything()
  print("Finished!")
  q(status = 0)
}


get_args <- function() {
  usage <- str_c("./run.R",
                 "[--help]",
                 "[--process]",
                 "[--n_max]",
                 "[--report]",
                 "[--plot]",
                 "--state <state_code>",
                 "--city <city_name>",
                 "[--coverage]",
                 "[--everything]",
                 sep = " ")
  spec <- tribble(
    ~long_name,   ~short_name,  ~argument_type, ~data_type,
    "help",       "h",          "none",         "logical",
    "process",    "o",          "none",         "logical",
    "n_max",      "n",          "none",         "integer",
    "report",     "r",          "none",         "logical",
    "plot",       "p",          "none",         "logical",
    "state",      "s",          "none",         "character",
    "city",       "c",          "none",         "character",
    "coverage",   "v",          "none",         "logical",
    "everything", "e",          "none",         "logical"
  )
  args <- parse_args(spec)

  if (not_null(args$help) || length(args) == 1) {
    print(usage)
    q(status = 0)
  }

  if (
    (not_null(args$process) || not_null(args$report) || not_null(args$plot))
    &&
    (is.null(args$state) || is.null(args$city))
  ) {
    print(usage)
    q(status = 1)
  }

  if (is.null(args$n_max)) {
    args$n_max <- Inf
  }

  args
}


if (!interactive()) {
  main()
}
