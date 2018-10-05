source("analysis_common.R")

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

  metadata <- list()
  tbl <- prepare(
    tbl,
    !!!control_colqs,
    demographic_col=!!demographic_colq,
    action_col=!!action_colq,
    outcome_col=!!outcome_colq,
    metadata=metadata
  )

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
      := sum(!!outcome_colq) / n(),
    !!str_c("n_", action_colname) := n()
  ) %>% 
  ungroup()

  list(
    results = results,
    metadata = metadata
  )
}
