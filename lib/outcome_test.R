library(tidyverse)


#' Outcome Test
#'
#' @param tbl a tibble containing the following data
#' @param ... additional attributes to control for when conducting outcome test
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
#' outcome_test(tbl, precinct)
#' outcome_test(tbl, precinct, subject_race, frisk_performed)
#' outcome_test(
#'   tbl,
#'   demographic_col = subject_race,
#'   action_col = search_conducted,
#'   outcome_col = contraband_found
#' )
outcome_test <- function(
  tbl,
  ...,
  demographic_col = subject_race,
  action_col = search_conducted,
  outcome_col = contraband_found
) {
  
  control_colqs <- enquos(...)
  demographic_colq <- enquo(demographic_col)
  action_colq <- enquo(action_col)
  action_colname <- quo_name(action_colq)
  outcome_colq <- enquo(outcome_col)
  outcome_colname <- quo_name(outcome_colq)

  n <- nrow(tbl)
  tbl <- select(
    tbl,
    !!! control_colqs,
    !!demographic_colq,
    !!action_colq,
    !!outcome_colq
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

  results <- filter(
    tbl,
    !!action_colq
  ) %>%
  group_by(
    !!demographic_colq,
    !!!control_colqs
  ) %>%
  summarize(
    !!str_c(outcome_colname, " where ", action_colname)
      := sum(!!outcome_colq) / n()
  )

  list(
    results = results,
    metadata = metadata
  )
}
