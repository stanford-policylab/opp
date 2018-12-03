#!/usr/bin/env Rscript
library(tidyverse)
library(here)
library(fs)
library(boot)


generate <- function(
  n_officers = 100,
  n_stops_per_officer = 100,
  # NOTE: used for generating what proportion of stops are miniorities
  mean_proportion_minority = 0.4,
  sd_proportion_minority = 0.1,
  mean_leniency = 0.0,
  sd_leniency = 0.5,
  # NOTE: lambda is center of distribution above bunching speed
  majority_lambda = 5,
  minority_lambda = 6,
  base_discount_rate = ,
  beta_bunching_excess_speed = -0.02,
  beta_leniency = 1.0,
  beta_majority = 0.05,
  seed = 0
) {
  set.seed(seed)

  pr_discount <- function(bunching_excess_speed, leniency, is_majority) {
    inv.logit(
      intercept
      + beta_bunching_excess_speed * bunching_excess_speed
      + beta_leniency * leniency
      + beta_majority * is_majority
    )
  }

  discount <- function(
    leniency,
    excess_bunching_speed,
    is_majority,
    majority_bias
  ) {
    if_else(
      leniency * (
        1 
        + 1 / (1 + excess_bunching_speed)
        + majority_bias * is_majority
      ) < runif(length(leniency)),
      TRUE,
      FALSE
    )
  }
  
  tibble(
    officer_id = seq(1:n_officers),
    leniency = positive_normal(
      n_officers,
      mean_leniency,
      sd_leniency
    ),
    p_minority = positive_normal(
      n_officers,
      mean_proportion_minority,
      sd_proportion_minority
    )
  ) %>%
  repeat_rows(
    n_stops_per_officer
  ) %>%
  mutate(
    is_majority = if_else(runif(nrow(.)) > p_minority, 1, 0),
    bunching_excess_speed = if_else(
      is_majority > 0,
      rpois(nrow(.), majority_lambda),
      rpois(nrow(.), minority_lambda)
    ),
    recorded_excess_speed = if_else(
      runif(nrow(.)) < pr_discount(
        bunching_excess_speed,
        leniency,
        is_majority
      ),
      as.integer(0),
      bunching_excess_speed
    )
  )
}


repeat_rows <- function(tbl, n_each) {
  tbl[rep(seq_len(nrow(tbl)), each=n_each), ]
}


positive_normal <- function(n, mean, sd) {
  v <- rnorm(n, mean, sd)
  if_else(v < 0, 0, v)
}


if (!interactive()) {
  tbl <- generate()
  output_dir <- dir_create(here::here("synthetic_data"))
  write_csv(tbl, path(output_dir, "bunching.csv"))
}
