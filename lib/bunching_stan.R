library(tidyverse)
library(here)
library(rstan)
rstan_options(auto_write = TRUE)

source(here::here("lib", "bunching_test.R"))
source(here::here("lib", "opp.R"))

bunching_analysis <- function(
  state = NULL,
  city = "florida",
  fl = NULL
) {
  if(!is.null(fl)) {
    data <- haven::read_dta(here::here("data", "bunching", "Cite_05_15_Use.dta"))
    data_summary <- summarise_fl_for_stan(data)
  } else { 
    data <- opp_load_data(state, city)
    data_summary <- summarise_for_stan(data)
  }
  stan_data <- format_for_stan(data_summary)
  fit <- stan_bunching(stan_data, 2000, 5)
  write_rds(fit, here::here("cache", str_c("agg_bunching_fit_", str_replace(city, " ", "_"), ".rds")))
}

agg_bunching_analysis <- function(
  state = NULL,
  city = "florida",
  fl = NULL
) {
  if(!is.null(fl)) {
    data <- haven::read_dta(here::here("data", "bunching", "Cite_05_15_Use.dta"))
    data_summary <- agg_fl_for_stan(data)
  } else { 
    data <- opp_load_data(state, city)
    data_summary <- agg_for_stan(data)
  }
  stan_data <- format_for_stan(data_summary, agg = TRUE)
  fit <- stan_bunching(stan_data, 2000, 5, here::here("stan", "bunching_aggregate.stan"))
  write_rds(fit, here::here("cache", str_c("agg_bunching_fit_", str_replace(city, " ", "_"), ".rds")))
}

stan_bunching <- function(
  data,
  n_iter = 2000,
  n_cores = min(5, parallel::detectCores() / 2),
  path_to_stan_model = here::here("stan", "bunching.stan")
) {
  # NOTE: defaults; may expose more of these in the future
  allow_adaptive_step_size <- T
  initialization_method <- "random"
  min_acceptable_divergence_rate <- 0.10
  n_iter_per_progress_update <- 50
  n_iter_warmup <- min(2500, round(n_iter / 2))
  n_markov_chains <- 5
  nuts_max_tree_depth <- 12
  
  
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

summarise_fl_for_stan <- function(tbl) {
  tbl %>% 
    rename(
      subject_race = Race, 
      officer_id = OfficerId, 
      speed = ActualSpeed, 
      posted_speed = PostedSpeed
    ) %>% 
    filter(!is.na(subject_race)) %>% 
    select(subject_race, officer_id, speed, posted_speed) %>% 
    mutate(
      over_bunch_pt = speed - posted_speed - 9, # 9 is bunching in fl 
      is_white = subject_race == "W"
    ) %>%
    filter(
      over_bunch_pt >= 0, over_bunch_pt <= 30,
      subject_race %in% c("W", "B")
    ) %>%
    inner_join(
      get_eligible_officer_leniency(., downsample = T), 
      by = "officer_id"
    )
}

agg_fl_for_stan <- function(tbl) {
  d <-
    tbl %>% 
    rename(
      subject_race = Race, 
      officer_id = OfficerId, 
      speed = ActualSpeed, 
      posted_speed = PostedSpeed
    ) %>% 
    filter(!is.na(subject_race)) %>% 
    select(subject_race, officer_id, speed, posted_speed) %>% 
    mutate(
      over_bunch_pt = speed - posted_speed - 9, # 9 is bunching in fl
      is_white = subject_race == "W"
    ) %>%
    filter(
      over_bunch_pt >= 0, over_bunch_pt <= 30,
      subject_race %in% c("B", "W")
    ) %>%
    inner_join(
      get_eligible_officer_leniency(.), 
      by = "officer_id"
    )
  q <- d$leniency %>% quantile(seq(0,1,0.2))
  d %>% 
    mutate(leniency_bin = case_when(
      leniency < q[[2]] ~ mean(c(q[[1]], q[[2]])),
      leniency < q[[3]] ~ mean(c(q[[2]], q[[3]])),
      leniency < q[[4]] ~ mean(c(q[[3]], q[[4]])),
      leniency < q[[5]] ~ mean(c(q[[4]], q[[5]])),
      leniency <= q[[6]] ~ mean(c(q[[5]], q[[6]]))
    )) %>% 
    count(is_white, leniency_bin, over_bunch_pt)
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
      get_eligible_officer_leniency(., downsample = T), 
      by = "officer_id"
    )
}

agg_for_stan <- function(tbl) {
  d <-
    tbl %>% 
    filter(!is.na(subject_race)) %>% 
    select(subject_race, officer_id, speed, posted_speed) %>% 
    mutate(
      over_bunch_pt = speed - posted_speed - 10, 
      is_white = subject_race == "white"
    ) %>%
    filter(over_bunch_pt >= 0, over_bunch_pt <= 30) %>%
    inner_join(
      get_eligible_officer_leniency(.), 
      by = "officer_id"
    )
  q <- d$leniency %>% quantile(seq(0,1,0.2))
  d %>% 
    mutate(leniency_bin = case_when(
      leniency < q[[2]] ~ mean(c(q[[1]], q[[2]])),
      leniency < q[[3]] ~ mean(c(q[[2]], q[[3]])),
      leniency < q[[4]] ~ mean(c(q[[3]], q[[4]])),
      leniency < q[[5]] ~ mean(c(q[[4]], q[[5]])),
      leniency <= q[[6]] ~ mean(c(q[[5]], q[[6]]))
    )) %>% 
    count(is_white, leniency_bin, over_bunch_pt)
}

get_eligible_officer_leniency <- function(tbl, downsample=FALSE) {
  eligible_officers <-
    tbl %>% 
    count(officer_id, is_white) %>% 
    filter(n > 50) %>% 
    group_by(officer_id) %>% 
    filter(n() == 2)
  if(downsample) {
    set.seed(4747)
    eligible_officers <- eligible_officers %>% sample_n(50)
  }
  eligible_officers <-
    eligible_officers %>% 
    pull(officer_id) %>% 
    unique()
  
  tbl %>% 
    filter(officer_id %in% eligible_officers, is_white) %>% 
    mutate(over = speed - posted_speed) %>%
    filter(over >= 10, over <= 40, !is.na(over)) %>% 
    group_by(officer_id) %>% 
    summarise(
      leniency_p = (sum(over == 10) + 1) / (length(over) + 10),
      # leniency_p = mean(over == 10) + 1e-6
      leniency = log(leniency_p / (1 - leniency_p))
      # leniency_bin = quantile(leniency, seq(0, 1, 0.1))
    )
  
  #d %>% mutate(leniency = (leniency_p - mean(d$leniency_p)) / sd(d$leniency_p))
}

format_for_stan <- function(data_summary, agg = FALSE) {
  if(!agg) {
    list(
      n_observations = nrow(data_summary),
      n_races = length(unique(data_summary$is_white)),
      race = as.integer(data_summary$is_white) + 1,
      max_bunching_excess_speed = max(data_summary$over_bunch_pt),
      bunching_excess_speed = data_summary$over_bunch_pt,
      leniency = data_summary$leniency
    )
  } else {
    list(
      n_groups = nrow(data_summary),
      max_bunching_excess_speed = max(data_summary$over_bunch_pt),
      count = data_summary$n,
      bunching_excess_speed = data_summary$over_bunch_pt,
      leniency = data_summary$leniency_bin,
      is_majority = as.integer(data_summary$is_white)
    )
  }
}

cat("\nStarting FL\n")
agg_bunching_analysis(fl = TRUE)
# cat("\nStarting Plano\n")
# agg_bunching_analysis("tx", "plano")

