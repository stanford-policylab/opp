library(here)
library(parallel)
library(rstan)
library(tidyverse)


#' Threshold Test
#'
#' Infer and compare thresholds used for determining whether to execute
#' an action, i.e. thresholds used by officers to determine whether to search
#' someone based on race
#'
#' @param tbl tibble containing the following data
#' @param ... additional attributes to control for when inferring thresholds
#' @param demographic_col contains a population division of interest, i.e. race,
#'        age group, sex, etc...
#' @param action_col identifies the risk population, i.e. those who were
#'        searched, frisked, summoned, etc...
#' @param outcome_col contains the results of action specified by
#'        \code{action_col}, i.e. if a search was conducted, an outcome
#'        might be whether contraband was found
#' @param n_iter maximum number of iterations
#' @param n_cores number of cores to use
#' 
#' 
#' @return list with \code{results} and \code{metadata} keys
#'
#' @examples
#' threshold_test(tbl)
#' threshold_test(
#'   tbl,
#'   geographic_col = precinct,
#'   demographic_col = subject_race,
#'   action_col = search_conducted,
#'   outcome_col = contraband_found
#' )
threshold_test <- function(
  tbl,
  ...,
  demographic_col = subject_race,
  action_col = search_conducted,
  outcome_col = contraband_found,
  n_iter = 5000,
  n_cores = min(5, parallel::detectCores() / 2)
) {

  control_colqs <- enquos(...)
  demographic_colq <- enquo(demographic_col)
  demographic_colname <- quo_name(demographic_colq)
  action_colq <- enquo(action_col)
  outcome_colq <- enquo(outcome_col)
  
  n <- nrow(tbl)
  tbl <- select(
    tbl,
    !!demographic_colq,
    !!action_colq,
    !!outcome_colq,
    !!!control_colqs
  ) %>%
  drop_na() 
  
  n_no_nas <- nrow(tbl)
  tbl <- filter(
    tbl,
    # drop rows with true outcome but false action
    !(!!outcome_colq & !(!!action_colq))
  )
  
  metadata <- list()
  
  null_rate <- (n - n_no_nas) / n
  metadata['null_rate'] <- null_rate
  if (null_rate > 0) {
    warning(
      str_c(formatC(100 * null_rate, format = "f", digits = 2), "%"),
      " of the data was null and removed"
    )
  }
  
  outcome_without_action_rate <- (n_no_nas - nrow(tbl)) / n
  metadata['outcome_without_action_rate'] <- outcome_without_action_rate
  if (outcome_without_action_rate > 0) {
    warning(
      str_c(formatC(100 * outcome_without_action_rate, format = "f", digits = 2), "%"),
      " of the data removed due to true outcome but false action"
    )
  }

  summary <- group_by(
    tbl,
    !!demographic_colq,
    !!!control_colqs
  ) %>%
  summarize(
    n = n(),
    n_action = sum(!!action_colq),
    n_outcome = sum(!!outcome_colq)
  ) %>% 
  ungroup() %>% 
  unite(controls, !!!control_colqs) %>% 
  mutate_at(
    .vars = c(demographic_colname, "controls"),
    .funs = as.factor
  )

  stan_data <- list(
    n_groups = nrow(summary),
    n_control_divisions = n_distinct(pull(summary, controls)),
    n_demographic_divisions = n_distinct(pull(summary, !!demographic_colq)),
    control_division = as.integer(pull(summary, controls)),
    demographic_division = as.integer(pull(summary, !!demographic_colq)),
    group_count = pull(summary, n),
    action_count = pull(summary, n_action),
    outcome_count = pull(summary, n_outcome)
  )

  stan_threshold_test(stan_data, n_iter, n_cores)
}


stan_threshold_test <- function(
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
  path_to_stan_model <- here::here("stan", "threshold_test_2.stan")
  
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
