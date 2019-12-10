library(here)
source(here::here("lib", "opp.R"))

#' Outcome Test
#'
#' @param tbl a tibble containing the following data
#' @param subgeography_col geographic subdivision for calculating hit rates
#'        (e.g., police district when testing cities, or county when
#'        testing states, etc.)
#' @param demographic_col contains a population division of interest, i.e. race,
#'        age group, sex, etc...
#' @param action_col identifies the risk population, i.e. those who were
#'        searched, frisked, summoned, etc...
#' @param outcome_col contains the results of action specified by
#'        \code{action_col}, i.e. if a search was conducted, an outcome
#'        might be whether contraband was found
#' 
#' @return list with \code{results} and \code{metadata} keys
#'
#' @examples
#' outcome_test(tbl, precinct, city)
#' outcome_test(tbl, precinct, city, subject_race, frisk_performed)
#' outcome_test(
#'   tbl,
#'   precinct,
#'   city,
#'   demographic_col = subject_race,
#'   action_col = search_conducted,
#'   outcome_col = contraband_found
#' )
outcome_test <- function(
  tbl,
  subgeography_col,
  geography_col,
  demographic_col = subject_race,
  action_col = search_conducted,
  outcome_col = contraband_found
) {
  
  subgeography_colq <- enquo(subgeography_col)
  geography_colq <- enquo(geography_col)
  demographic_colq <- enquo(demographic_col)
  action_colq <- enquo(action_col)
  action_colname <- quo_name(action_colq)
  outcome_colq <- enquo(outcome_col)
  outcome_colname <- quo_name(outcome_colq)

  metadata <- list()
  tbl <- opp_prepare_for_disparity(
    tbl,
    !!subgeography_colq,
    !!geography_colq,
    demographic_col = !!demographic_colq,
    action_col = !!action_colq,
    outcome_col = !!outcome_colq,
    metadata = metadata
  )

  results <- list()
  results$hit_rates <- compute_hit_rates(
    tbl,
    subgeography_col = !!subgeography_colq,
    geography_col = !!geography_colq,
    demographic_col = !!demographic_colq,
    action_col = !!action_colq,
    outcome_col = !!outcome_colq
  )
  results$aggregate_hit_rates <- 
    collect_aggregate_hit_rates(
      results$hit_rates,
      geography_col = !!geography_colq,
      demographic_col = !!demographic_colq,
      action_colname = action_colname,
      outcome_colname = outcome_colname
    )
  
  list(
    results = results,
    metadata = metadata
  )
}

compute_hit_rates <- function(
  tbl,
  subgeography_col,
  geography_col,
  demographic_col,
  action_col,
  outcome_col
) {
  
  subgeography_colq <- enquo(subeography_col)
  geography_colq <- enquo(geography_col)
  demographic_colq <- enquo(demographic_col)
  action_colq <- enquo(action_col)
  action_colname <- quo_name(action_colq)
  outcome_colq <- enquo(outcome_col)
  outcome_colname <- quo_name(outcome_colq)
  
  tbl %>% 
    filter(!!action_colq) %>%
    group_by(
      !!demographic_colq,
      !!geography_colq,
      !!subgeography_colq
    ) %>%
    summarize(
      !!str_c(outcome_colname, " where ", action_colname)
        := sum(!!outcome_colq) / n(),
      !!str_c("n_", action_colname) := n()
    ) %>% 
    ungroup()
}

collect_aggregate_hit_rates <- function(
  tbl,
  geography_col,
  demographic_col,
  action_colname,
  outcome_colname
) {
  geography_colq <- enquo(geography_col)
  demographic_colq <- enquo(demographic_col)
  tbl %>% 
    group_by(
      !!demographic_colq, 
      !!geography_colq
    ) %>% 
    summarize(
      # i.e. average hit rate by subject_race-geography, weighted by the number
      # of searches in each subeography
      hit_rate = weighted.mean(
        get(str_c(outcome_colname, " where ", action_colname)),
        w = get(str_c("n_", action_colname))
      ),
      n = sum(get(str_c("n_", action_colname)))
    ) %>% 
    group_by(!!demographic_colq) %>% 
    summarize(
      hit_rate = mean(hit_rate),
      n = sum(n)
    )
}
