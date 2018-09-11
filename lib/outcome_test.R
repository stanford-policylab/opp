source('opp.R')


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
#' outcome_test(tbl, precinct, subject_race, search_conducted, contraband_found)
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

  demographic_colq <- enquo(demographic_col)
  action_colq <- enquo(action_col)
  outcome_colq <- enquo(outcome_col)

  n <- nrow(tbl)
  tbl <- select(
    tbl,
    !!demographic_colq,
    !!action_colq,
    !!outcome_colq,
    ...
  ) %>%
  drop_na()

  null_rate <- (n - nrow(tbl)) / n
  metadata <- list()
  metadata['null_rate'] <- null_rate
  if (null_rate > 0) {
    warning(
      pretty_percent(null_rate),
      " of the data was null and removed"
    )
  }

  demographic_colname <- quo_name(demographic_colq)
  action_colname <- quo_name(action_colq)
  outcome_colname <- quo_name(outcome_colq)
  # NOTE: any other columns passed in are assumed to be additional variables
  # to control for variation; i.e. precinct, crime_rate, etc..
  control_colnames <- setdiff(
    colnames(tbl),
    c(demographic_colname, action_colname, outcome_colname)
  )
  print(colnames(tbl))
  print(control_colnames)

  results <- filter(
    tbl,
    !!action_colq
  ) %>%
  group_by_(
    .dots = c(demographic_colname, control_colnames)
  ) %>%
  summarize(
    outcome__ = sum(!!outcome_colq) / n()
  ) %>%
  rename_with_str(
    "outcome__",
    str_c(outcome_colname, " where ", action_colname)
  )

  list(
    results = results,
    metadata = metadata
  )
}
