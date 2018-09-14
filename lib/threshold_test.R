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
  geographic_col = precinct,
  demographic_col = subject_race,
  action_col = search_conducted,
  outcome_col = contraband_found,
  n_iter = 5000,
  n_cores = parallel::detectCores() / 2,
) {

  geographic_colq <- enquo(geographic_col)
  demographic_colq <- enquo(demographic_col)
  action_colq <- enquo(action_col)
  outcome_colq <- enquo(outcome_col)

  n <- nrow(tbl)
  tbl <- select(
    tbl,
    !!geographic_colq,
    !!demographic_colq,
    !!action_colq,
    !!outcome_colq,
  ) %>%
  drop_na()

  null_rate <- (n - nrow(tbl)) / n
  metadata <- list()
  metadata['null_rate'] <- null_rate
  if (null_rate > 0) {
    warning(
      str_c(formatC(100 * null_rate, format = "f", digits = 2), "%"),
      " of the data was null and removed"
    )
  }

  summary <- group_by(
    tbl,
    !!geographic_colq,
    !!demographic_colq
  ) %>%
  mutate(
    as.factor(!!geographic_colq),
    as.factor(!!demographic_colq)
  ) %>%
  summarize(
    n = n(),
    n_action = sum(!!action_colq),
    n_outcome = sum(!!outcome_colq)
  )

  stan_data <- list(
    n_groups = nrow(summary),
    n_geographic_divisions = n_distinct(pull(summary, !!geographic_colq)),
    n_demographic_divisions = n_distinct(pull(summary, !!demographic_colq)),
    geographic_division = pull(summary, !!geographic_colq),
    demographic_division = pull(summary, !!demographic_colq),
    group = pull(summary, !!n)
    action = pull(summary, !!n_action)
    outcome = pull(summary, !!n_outcome)
  )

  stan_threshold_test(stan_data, n_iter, n_cores)
}


stan_threshold_test <- function(
  data,
  n_iter = 5000,
  n_cores = parallel::detectCores() / 2
) {

  # NOTE: defaults; may expose more of these in the future
  allow_adaptive_step_size <- T
  initialization_method <- "random"
  min_acceptable_divergence_rate <- 0.05
  n_iter_per_progress_update <- 50
  n_iter_warmup <- min(2500, round(n_iter / 2))
  n_markov_chains = 5,
  nuts_max_tree_depth <- 12
  path_to_stan_model <- here::here("stan", "threshold_test.stan")

  rstan::sampling(
    stan_model(here::here("stan", "threshold_test.stan")),
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
