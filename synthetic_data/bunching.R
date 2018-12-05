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
  majority_lambda = 7,
  minority_lambda = 7,
  # NOTE: exp(-1.5) ~ 0.22, meaning that conditional on nothing, the odds
  # of being discounted are roughly 1 in 5
  intercept = -1.5,
  # NOTE: exp(-0.2) ~ 0.82, which means each unit increase in excess buncing
  # speed decreases the odds of discount by ~18%; exp(-0.2 * 5) ~ 0.37,
  # representing a decrease in odds of ~63%
  beta_bunching_excess_speed = -0.2,
  # NOTE: exp(1.0) ~ e ~ 2.7, so if the officer is fully lenient, the odds
  # of being discounted increase by ~3x; similarly, if the officer leniency
  # increases by 0.1, exp(0.1) ~ 1.11, meaning odds increase by ~11%
  beta_leniency = 2.0,
  # NOTE: exp(0.05) ~ 1.05, so if the driver is in the majority class,
  # the odds of being discounted increase by 5%
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

  # TODO(danj): what decision points create reasonable betas?
  # discount <- function(
  #   leniency,
  #   excess_bunching_speed,
  #   is_majority,
  #   majority_bias
  # ) {
  #   if_else(
  #     leniency * (
  #       1 
  #       + 1 / (1 + excess_bunching_speed)
  #       + majority_bias * is_majority
  #     ) < runif(length(leniency)),
  #     TRUE,
  #     FALSE
  #   )
  # }
  
  tbl <-
    tibble(
      officer_id = seq(1:n_officers),
      leniency = positive_normal_truncate_to_zero(
        n_officers,
        mean_leniency,
        sd_leniency
      ),
      p_minority = positive_normal_truncate_to_zero(
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
      p_discount = pr_discount(bunching_excess_speed, leniency, is_majority),
      recorded_excess_speed = if_else(
        runif(nrow(.)) < p_discount,
        as.integer(0),
        bunching_excess_speed
      )
    )

}


format_for_stan_bunching_aggregate <- function(tbl) {
  tbl %>%
    group_by(officer_id, leniency) %>%
    summarize(leniency_estimate = mean(recorded_excess_speed == 0)) %>%
    ungroup()
  # TODO(danj): finish
}


repeat_rows <- function(tbl, n_each) {
  tbl[rep(seq_len(nrow(tbl)), each=n_each), ]
}


positive_normal_truncate_to_zero <- function(n, mean, sd) {
  v <- rnorm(n, mean, sd)
  if_else(v < 0 | v > 1, 0, v)
}


if (!interactive()) {
  tbl <- generate()
  output_dir <- dir_create(here::here("synthetic_data"))
  write_csv(tbl, path(output_dir, "bunching.csv"))
}
