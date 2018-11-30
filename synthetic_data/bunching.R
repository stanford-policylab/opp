#!/usr/bin/env Rscript
library(tidyverse)
library(here)
library(fs)


main <- function() {
  set.seed(0)
  n_majority <- 500
  n_minority <- 500
  n <- n_majority + n_minority
  majority_lambda <- 5
  minority_lambda <- 6
  discount <- function(true_excess_bunching_speed, is_majority, leniency) {
    if_else(
      rnorm(1) <= 1 / true_excess_bunching_speed + 0.1 * is_majority
    )
  }
  tbl <- tibble(
    is_majority = c(
      rep(T, n_majority),
      rep(F, n_minority),
    ),
    true_excess_bunching_speed = c(
      dpois(n_majority, majority_lambda),
      dpois(n_minority, minority_lambda)
    )
    leniency = dnorm(n, mean = 0, sd = 0.5),
    leniency = if_else(leniency < 0, 0, leniency),
    recorded_excess_bunching_speed <- discount(
      true_excess_bunching_speed,
      is_majority,
      leniency 
    )
  )
    
  output_dir <- dir_create(here::here("synthetic_data"))
  write_csv(tbl, path(output_dir, "bunching.csv"))
}


if (!interactive()) {
  main()
}
