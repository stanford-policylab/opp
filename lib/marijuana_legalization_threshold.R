#!/usr/bin/env Rscript
source(here::here("lib", "opp.R"))
source(here::here("lib", "threshold_test.R"))
library(rstan)

marijuana_legalization_threshold_test <- function() {
  state <- get_marijuana_state_arg()
  tbl <- load_mj_state(state)
  data_summary <- summarise_for_stan(tbl) 
  stan_data <- format_data_summary_for_stan(data_summary)
  fit <- stan_marijuana_threshold_test(stan_data)
  metadata["stan_warnings"] <- summary(warnings())
  posteriors <- rstan::extract(fit)
  data_with_thresholds <- add_thresholds(data_summary, posteriors)
  summary_stats <- summary_stats(data_with_thresholds, posteriors)

  list(
    metadata = c(
      metadata,
      list(
        fit = fit,
        data = data_summary,
        input_tbl = stan_data
      )
    ),
    results = list(
      thresholds = data_with_thresholds,
      aggregate_thresholds = summary_stats
    )
  ) %>%
  write_rds(here::here("cache", str_c("mj_threshold_results_", state, ".rds")))

}

get_marijuana_state_arg <- function() {
  spec <- tribble(
    ~long_name,   ~short_name,  ~argument_type, ~data_type,
    "state",       "s",         "none",         "character"
  )
  parse_args(spec)$state
}

# small helper method to get legalization date for a state. 
# the two legalization dates for CO + WA are essentially the same 
#(2012-12-10 vs 2012-12-09). 
# for control states, which of course have no legalization date, 
#we return Washington's by default. 
get_legalization_date_for_state = function(state){
  return(ifelse(
    state == 'CO', ymd("2012-12-10"), 
    ymd("2012-12-09"))
  )
}


load_mj_state <- function(state) {
  tribble(
    ~state, ~city,
    state, "Statewide"
  ) %>%
    opp_load_all_clean_data() %>%
    filter(
      if_else(
        state == "CO",
        # NOTE: remove the stops for which a search was conducted but we don't have
        # contraband recovery info
        !(search_conducted & is.na(contraband_found)),
        T
      ),
      # WA is fine
      # NOTE: compare only blacks/hispanics with whites; remove pedestrian stops
      subject_race %in% c("black", "white", "hispanic"),
      type == "vehicular",
      !is.na(date),
      !is.na(subject_race),
      !is.na(county_name),
      # NOTE: search_basis = NA is interpreted as an eligible search,
      # so don't filter out
      !is.na(search_conducted),
      # TODO(amyshoe): should these be updated with new data?
      year(date) >= 2011 & year(date) <= 2015
    ) %>%
    add_legalization_info() %>% 
    select(
      geography = state,
      sub_geography = county_name,
      date,
      legal,
      legalization_date,
      subject_race,
      search_basis,
      search_conducted,
      contraband_found
    ) %>%
    mutate(
      # NOTE: excludes consent and other (non-discretionary)
      eligible_search_conducted = search_conducted 
        & (is.na(search_basis)|search_basis %in% c("k9", "consent", "plain view", "probable cause")),
      years_since_legalization = as.numeric(date - legalization_date) / 365
    ) 
}

add_legalization_info <- function(tbl) {
  mutate(
    tbl,
    # NOTE: default for control and WA is WA's legalization date
    legalization_date = as.Date("2012-12-09"),
    legalization_date = if_else(
      state == "CO",
      as.Date("2012-12-10"),
      legalization_date
    ),
    legal = date >= legalization_date
  )
}

summarise_for_stan <- function(tbl) {
  tbl%>%
    mutate(
      race_cd = as.integer(fct_drop(subject_race)),
      sub_geography_cd = as.integer(as.factor(sub_geography))
    ) %>% 
    group_by(
      geography, sub_geography, sub_geography_cd,
      race_cd, subject_race, legal
    ) %>%
    summarize(num_stops = n(),
              num_searches = sum(eligible_search_conducted, na.rm=T),
              num_hits = sum(eligible_search_conducted & contraband_found, na.rm=T)) %>% 
    ungroup()
}

format_data_summary_for_stan <- function(d) {
  list(
    n_groups = nrow(d),
    n_sub_geographies = n_distinct(pull(d, sub_geography)),
    n_races = n_distinct(pull(d, subject_race)),
    sub_geography = pull(d, sub_geography_cd),
    legal = pull(d, as.integer(legal)),
    race = pull(d, race_cd),
    stop_count = pull(d, num_stops),
    search_count = pull(d, num_searches),
    hit_count = pull(d, num_hits)
  )
}

stan_marijuana_threshold_test <- function(
  data,
  n_iter = 5000,
  n_cores = min(5, parallel::detectCores() / 2)
) {
  # NOTE: defaults; may expose more of these in the future
  allow_adaptive_step_size <- T
  initialization_method <- "random"
  min_acceptable_divergence_rate <- 0.05
  n_iter_per_progress_update <- 50
  n_iter_warmup <- min(2500, round(n_iter / 2))
  n_markov_chains <- 5
  nuts_max_tree_depth <- 12
  path_to_stan_model <- here::here("stan", "threshold_test_marijuana.stan")
  
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


### post processing

add_thresholds <- function(
  data_summary,
  posteriors
) {
  data_summary %>%
    mutate(
      threshold = colMeans(signal_to_percent(
        posteriors$threshold, 
        posteriors$phi, 
        posteriors$delta
      ))
    )
}

summary_stats <- function(obs, post) {
  threshold_cis(
    obs, post,
    groups = c('legal', 'subject_race'),
    weights = obs %>% 
      group_by(sub_geography, legal) %>%
      mutate(w=sum(num_stops)) %>%
      with(w)
  ) 
}

threshold_cis = function(obs, post,
                         groups = 'subject_race',
                         weights = NULL,
                         probs = c(0.025,0.5,0.975)) {
  if (is.null(weights)) {
    weights = obs %>% group_by(sub_geography) %>%
      mutate(w = sum(num_stops)) %>%
      with(w)
  }
  
  obs = obs %>% mutate(idx = 1:nrow(.))
  
  t = t(signal_to_percent(
    post$threshold,
    post$phi,
    post$delta
  ))
  
  
  obs %>% 
    group_by_(.dots = groups) %>%
    do(
      as.data.frame(t(quantile(
        colSums(weights[.$idx] * t[.$idx,])/sum(weights[.$idx]), 
        probs = probs
      )))
    ) %>% 
    left_join(
      obs %>% 
        group_by_(.dots = groups) %>% 
        summarize(mean = mean(threshold)),
      by = groups
    )
    
}

# converts the threshold signal into a percent value (0, 1)
signal_to_percent <- function(x, phi, delta){
  phi * dnorm(x, delta, 1) / 
    (phi * dnorm(x, delta, 1) + (1 - phi) * dnorm(x, 0, 1))
}

if (!interactive()) {
  marijuana_legalization_threshold_test()
}



