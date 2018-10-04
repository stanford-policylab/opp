library(here)
library(parallel)
library(rstan)
library(tidyverse)
library(stringr)

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
#' @return list with \code{data}, \code{results}, and \code{metadata} keys
#'
#' @examples
#' threshold_test(tbl)
#' threshold_test(
#'   tbl,
#'   precinct,
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
  majority_demographic = "white",
  n_iter = 5000,
  n_cores = min(5, parallel::detectCores() / 2)
) {
  
  control_colqs <- enquos(...)
  demographic_colq <- enquo(demographic_col)
  action_colq <- enquo(action_col)
  outcome_colq <- enquo(outcome_col)
  
  metadata <- list()

  tbl <- prepare(
    tbl,
    metadata,
    demographic_colq,
    action_colq,
    outcome_colq,
    control_colqs
  )

  data_summary <- summarize_for_stan(
    tbl,
    metadata,
    demographic_colq,
    action_colq,
    outcome_colq,
    control_colqs
  )

  stan_data <- format_data_summary_for_stan(data_summary, demographic_colq)
  fit <- stan_threshold_test(stan_data, n_iter, n_cores)
  posteriors <- rstan::extract(fit)

  summary_stats <- collect_average_threshold_test_summary_stats(
    data_summary, 
    demographic_colq,
    majority_demographic,
    posteriors
  )

  thresholds_by_group <- collect_thresholds_by_group(data_summary, posteriors)

  list(
    metadata = c(
      metadata,
      list(
        data_summary = data_summary,
        fit = fit
      )
    ),
    results = list(
      thresholds_by_group = thresholds_by_group,
      aggregate_thresholds = summary_stats
    )
  )
}


# Creates a warning indicating that some percent of the data had some property
rate_warning <- function(rate, message) {
  warning(
    str_c(
      formatC(100 * rate, format = "f", digits = 2), 
      "% of the data ",
      message
    ),
    call. = FALSE
  )
}


prepare <- function(
  tbl,
  metadata,
  demographic_colq,
  action_colq,
  outcome_colq,
  control_colqs
) {
  n_before_drop_na <- nrow(tbl)
  tbl <- 
    tbl %>% 
    select(
      !!demographic_colq,
      !!action_colq,
      !!outcome_colq,
      !!!control_colqs
    ) %>%
    drop_na() 
  n_after_drop_na <- nrow(tbl)

  null_rate <- (n_before_drop_na - n_after_drop_na) / n_before_drop_na
  if (null_rate > 0) { rate_warning(null_rate, "was null and removed") }
  metadata['null_rate'] <- null_rate

  # NOTE: remove inconsistent data where an outcome was recorded but there
  # was no action taken
  tbl <- filter(tbl, !(!!outcome_colq & !(!!action_colq)))
  correction_rate <- (n_after_drop_na - nrow(tbl)) / n_before_drop_na
  metadata['outcome_without_action_rate'] <- correction_rate
  if (correction_rate > 0) {
    rate_warning(
      correction_rate,
      "was inconsistent: outcome was recorded but no action was taken"
    )
  }

  tbl
}


summarize_for_stan <- function(
  tbl,
  metadata,
  demographic_colq,
  action_colq,
  outcome_colq,
  control_colqs
) {
  demographic_colname <- quo_name(demographic_colq)

  tbl %>% 
  group_by(!!demographic_colq, !!!control_colqs) %>%
  summarize(
    n = n(),
    n_action = sum(!!action_colq),
    n_outcome = sum(!!outcome_colq)
  ) %>% 
  ungroup() %>% 
  unite(controls, !!!control_colqs) %>% 
  # NOTE: keep original column values to map stan output to values
  mutate(
    original_control = controls,
    original_demographic = !!demographic_colq
  ) %>% 
  mutate_at(
    .vars = c(demographic_colname, "controls"),
    .funs = ~as.integer(as.factor(.x))
  )
}


format_data_summary_for_stan <- function(data_summary, demographic_colq) {
  list(
    n_groups = nrow(data_summary),
    n_control_divisions = n_distinct(pull(data_summary, controls)),
    n_demographic_divisions = n_distinct(pull(data_summary, !!demographic_colq)),
    control_division = pull(data_summary, controls),
    demographic_division = pull(data_summary, !!demographic_colq),
    group_count = pull(data_summary, n),
    action_count = pull(data_summary, n_action),
    outcome_count = pull(data_summary, n_outcome)
  )
}


collect_average_threshold_test_summary_stats <- function(
  summary,
  demographic_colq,
  majority_demographic,
  posteriors
) {
  avg_thresh <- accumulateRowMeans(
    t(signal_to_percent(
      posteriors$threshold,
      posteriors$phi,
      posteriors$lambda
    )),
    pull(summary, !!demographic_colq), 
    summary$n
  )
  format_summary_stats(
    summary, 
    demographic_colq,
    majority_demographic, 
    avg_thresh
  )
} 


# converts the threshold signal into a percent value (0, 1)
signal_to_percent <- function(x, phi, lambda){
  phi * dnorm(x, lambda, 1) / 
    (phi * dnorm(x, lambda, 1) + (1 - phi) * dnorm(x, 0, 1))
}


# Matrix operation to perfrom accumulated row means over some sub-category i
# @pre: length(i) == nrow(M)
# @pre: length(w) == nrow(M)
# e.g., 
## if rows of @M represent race-district thresholds, and
## if @i gives integer representation of which race each row in @M corresponds to,
## then @output will be a matrix with by-race thresholds averaged across districts
## averages are weighted according to @w (or, default is unweighted avg)
# @post: ncol(output) == ncol(M)
# @post: nrow(output) == n_distinct(i)
accumulateRowMeans <- function(
  M, # matrix to perform accumulated row means on
  i, # lists which sub-category value each row in M corresponds to
  w = rep(1, nrow(M)), # values used to create weightings for averaging
  i_max = max(i)
) {
  weighted_indexer <- t(sapply(
    1:i_max, 
    function(j) { (i == j) * na_replace(w / sum(w[i == j]), 0) }
  ))
  weighted_indexer %*% M
}


na_replace <- function(x, r) if_else(is.finite(x), x, r)


format_summary_stats <- function(
  summary,
  demographic_colq,
  majority_demographic,
  avg_thresh
) {
  majority_idx <-
    summary %>% 
    filter(original_demographic == majority_demographic) %>% 
    pull(!!demographic_colq) %>% 
    # extracts a single value
    unique() 
  
  avg_diffs <- 
    avg_thresh[-majority_idx,] -
    matrix(
      rep(avg_thresh[majority_idx,], nrow(avg_thresh) - 1),
      nrow = nrow(avg_thresh) - 1
    ) 
  
  tibble(
    demographic = levels(summary$original_demographic),
    avg_threshold = pretty_percent(rowMeans(avg_thresh)),
    threshold_ci = format_confidence_interval(avg_thresh),
    threshold_diff = append(
      pretty_percent(rowMeans(avg_diffs)), 
      "", 
      after = majority_idx - 1
    ),
    diff_ci = append(
      format_confidence_interval(avg_diffs), 
      "", 
      after = majority_idx - 1
    )
  )
}


pretty_percent <- function(v) {
  str_c(formatC(100 * v, format = "f", digits = 2), "%")
}


format_confidence_interval <- function(
  # matrix over which confidence intervals are taken
  M,
  # dimension for which we're calculating CIs (defaults to rows; 2 = columns)
  keep_dim = 1,
  lower = 0.025, 
  upper = 0.975
) {
  apply(
    matrixStats::rowQuantiles(M, probs = c(lower, upper)), 
    keep_dim,
    function(v) { 
      v <- pretty_percent(v)
      vs <- str_c(v, collapse = ', ')
      str_c('(', vs, ')')
    }
  )
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
  path_to_stan_model <- here::here("stan", "threshold_test.stan")
  
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


collect_thresholds_by_group <- function(data_summary, posteriors) {
  data_summary %>%
  mutate(
    thresholds = colMeans(signal_to_percent(
      posteriors$threshold, 
      posteriors$phi, 
      posteriors$lambda
    ))
  ) %>%
  group_by(controls) %>%
  # e.g., number of stops across all races in each district
  mutate(total_group_count = sum(n)) %>%
  ungroup() %>% 
  select(
    original_demographic, 
    original_control,
    n_action,
    thresholds
  )
}
