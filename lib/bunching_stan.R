library(tidyverse)
library(here)
library(rstan)

source(here::here("lib", "bunching_test.R"))
source(here::here("lib", "opp.R"))

bunching_analysis <- function(
  state,
  city
) {
  data <- opp_load_data(state, city)
  data_summary <- summarise_for_stan(data)
  stan_data <- format_for_stan(data_summary)
  stan_data
  fit <- stan_bunching(stan_data, 2000, 5)
  write_rds(here::here("cache", str_c("bunching_fit_", city, "_.rds")))
}

stan_bunching <- function(
  data,
  n_iter = 2000,
  n_cores = min(5, parallel::detectCores() / 2)
) {
  # NOTE: defaults; may expose more of these in the future
  allow_adaptive_step_size <- T
  initialization_method <- "random"
  min_acceptable_divergence_rate <- 0.10
  n_iter_per_progress_update <- 50
  n_iter_warmup <- min(2500, round(n_iter / 2))
  n_markov_chains <- 5
  nuts_max_tree_depth <- 12
  path_to_stan_model <- here::here("stan", "bunching.stan")
  
  rstan::sampling(
    stan_model(path_to_stan_model),
    data,
    chains = n_markov_chains,
    control = list(
      adapt_delta = 1 - min_acceptable_divergence_rate,
      adapt_engaged = allow_adaptive_step_size,
      max_treedepth = nuts_max_tree_depth
    ),
    cores = n_cores,
    init = initialization_method,
    iter = n_iter,
    refresh = n_iter_per_progress_update,
    warmup = n_iter_warmup
  )
}

summarise_for_stan <- function(tbl) {
  tbl %>% 
    filter(!is.na(subject_race)) %>% 
    select(subject_race, officer_id, speed, posted_speed) %>% 
    mutate(
      over_bunch_pt = speed - posted_speed - 10, 
      is_white = subject_race == "white"
    ) %>%
    filter(over_bunch_pt >= 0, over_bunch_pt <= 30) %>%
    inner_join(
      get_eligible_officer_leniency(tbl), 
      by = "officer_id"
    )
}

get_eligible_officer_leniency <- function(tbl) {
  eligible_officers <-
    tbl %>% 
    filter(subject_race == "white") %>% 
    count(officer_id) %>% 
    filter(n > 50) %>% 
    sample_n(100) %>% 
    pull(officer_id) 
  
  d <-
    tbl %>% 
    filter(officer_id %in% eligible_officers, subject_race == "white") %>% 
    mutate(over = speed - posted_speed) %>%
    filter(over >= 10, over <= 40, !is.na(over)) %>% 
    group_by(officer_id) %>% 
    summarise(leniency_raw = mean(over == 10))
  
  d %>% 
    mutate(
      leniency = (leniency_raw - mean(d$leniency_raw) / sd(d$leniency_raw))
    )
}

format_for_stan <- function(data_summary) {
  list(
    n_observations = nrow(data_summary),
    n_races = length(unique(data_summary$is_white)),
    race = as.integer(data_summary$is_white) + 1,
    max_bunching_excess_speed = max(data_summary$over_bunch_pt),
    bunching_excess_speed = data_summary$over_bunch_pt,
    leniency = data_summary$leniency
  )
}

cat("\nStarting OK City\n")
bunching_analysis("ok", "oklahoma city")
cat("\nStarting Plano\n")
bunching_analysis("tx", "plano")
cat("\nStarting Dallas\n")
bunching_analysis("tx", "dallas")

