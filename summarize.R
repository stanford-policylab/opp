#!/usr/bin/env Rscript

suppressPackageStartupMessages(source("lib/utils.R"))
source("lib/schema.R")


main <- function() {
  args <- get_args()
  opp_summarize(args$state, args$city)
  q(status = 0)
}


get_args <- function() {
  usage <- "./summarize.R [-h] -s <state_name> -c <city_name>"
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


opp_summarize <- function(state, city) {
  source_opp_funcs_for(state, city)
  raw_data <- opp_load()
  clean_data <- opp_clean(raw_data)
  plots <- lapply(colnames(clean_data),
                  function (colname) { plot_col(clean_data, colname) })
  pdf(str_c(state, city, "plots.pdf", sep = "_"), onefile = TRUE)
  lapply(plots, print)
  dev.off()
}


plot_col <- function(tbl, col) {
  print(str_c(col, get_primary_class(tbl[[col]]), sep=", "))
  plot_map <- c(
    "logical"   = plot_factor,
    "integer"   = plot_numeric,
    "numeric"   = plot_numeric,
    "factor"    = plot_factor,
    "character" = plot_character,
    "Date"      = plot_date,
    "POSIXct"   = plot_date,
    "POSIXlt"   = plot_date,
    "hms"       = plot_time
  )
  plot_map[[get_primary_class(tbl[[col]])]](tbl, col)
}


plot_numeric <- function (tbl, col) {
  ggplot(tbl) + geom_histogram(aes(tbl[[col]])) + xlab(col)
}


plot_factor <- function (tbl, col) {
  ggplot(tbl) + geom_bar(aes(tbl[[col]])) +
    xlab(col) +
    theme(axis.text.x = element_text(angle = 90, hjust = 1))
}


plot_character <- function (tbl, col) {
  n <- n_distinct(tbl[[col]])
  if (n <= 100) {
    plot_factor(tbl, col)
  } else {
    ggplot(tbl) +
      geom_bar(aes(sapply(tbl[[col]], function (v) { v == "" || is.na(v) }))) +
      xlab(paste(col, "is empty"))
  }
}


plot_date <- function(tbl, col) {
  plot_factor(tbl, col)
}


plot_time <- function(tbl, col) {
  plot_numeric(tbl, col)
}


main()
