#!/usr/bin/env Rscript

setwd("lib")
suppressMessages(source("opp.R"))

main <- function() {
  args <- get_args()
  if (not_null(args$process) & is.null(args$process_all))
    opp_process(args$state, args$city, args$n_max)
  if (not_null(args$report))
    opp_report(args$state, args$city)
  if (not_null(args$bunching))
    opp_bunching_report()
  if (not_null(args$plot))
    opp_plot(args$state, args$city)
  if (not_null(args$coverage))
    opp_coverage()
  if (not_null(args$prima_facie))
    opp_prima_facie_stats()
  if (not_null(args$process_all)) {
    v <- opp_process_all()
    print(v)
  }
  if (not_null(args$report_all)) {
    v <- opp_report_all()
    print(v)
  }
  if (not_null(args$marijuana))
    opp_run_marijuana_legalization_analysis()
  if (not_null(args$vod))
    opp_run_veil_of_darkness()
  if (not_null(args$disparity))
    opp_run_disparity()
  if (not_null(args$paper))
    opp_recreate_results_for_paper()
  print("Finished!")
  q(status = 0)
}


get_args <- function() {
  usage <- str_c("./run.R",
                 "[--help]",
                 "[--process]",
                 "[--n_max]",
                 "[--report]",
                 "[--prima_facie]",
                 "[--bunching]",
                 "[--plot]",
                 "--state <state_code>",
                 "--city <city_name>",
                 "[--coverage]",
                 "[--process_all]",
                 "[--report_all]",
                 "[--paper]"
                 sep = " ")

  spec <- tribble(
    ~long_name,   ~short_name,  ~argument_type, ~data_type,
    "help",        "h",         "none",         "logical",
    "process",     "o",         "none",         "logical",
    "n_max",       "n",         "none",         "integer",
    "report",      "r",         "none",         "logical",
    "prima_facie", "f",         "none",         "logical",
    "bunching",    "b",         "none",         "logical",
    "plot",        "pl",        "none",         "logical",
    "state",       "s",         "none",         "character",
    "city",        "c",         "none",         "character",
    "coverage",    "v",         "none",         "logical",
    "process_all", "pa",        "none",         "logical",
    "report_all",  "ra",        "none",         "logical",
    "marijuana",   "m",         "none",         "logical",
    "vod",         "vod",       "none",         "logical",
    "disparity",   "d",         "none",         "logical",
    "paper",       "p",         "none",         "logical"
  )

  args <- parse_args(spec)

  if (not_null(args$help) | length(args) == 1) {
    print(usage)
    q(status = 0)
  }

  if (
    (
      not_null(args$process) & is.null(args$process_all)
      | not_null(args$report)
      | not_null(args$plot)
    )
    &
    (is.null(args$state) | is.null(args$city))
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
