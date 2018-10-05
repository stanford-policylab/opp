library(here)
library(parallel)
library(rstan)
library(tidyverse)
library(stringr)


prepare <- function(
  tbl,
  ...,
  demographic_col = subject_race,
  action_col = search_conducted,
  outcome_col = contraband_found,
  metadata = list()
) {

  control_colqs <- enquos(...)
  demographic_colq <- enquo(demographic_col)
  action_colq <- enquo(action_col)
  outcome_colq <- enquo(outcome_col)

  action_colname <- quo_name(action_colq)
  outcome_colname <- quo_name(outcome_colq)

  # NOTE: if action was FALSE and outcome is NA, propagate FALSE over
  n_outcome_na_before <- sum(is.na(tbl[[outcome_colname]]))
  tbl <- 
    tbl %>%
    mutate(
      !!outcome_colname := if_else_na(
        is.na(!!outcome_colq) & !(!!action_colq),
        F,
        !!outcome_colq
      )
    )
  n_outcome_na_after <- sum(is.na(tbl[[outcome_colname]]))
  n_fill_outcome <- n_outcome_na_before - n_outcome_na_after
  metadata["fill_outcome"] <- n_fill_outcome
  if (n_fill_outcome > 0) {
    msg <- str_c(
      n_fill_outcome,
      " of ",
      outcome_colname,
      " were NA and filled with FALSE because ",
      action_colname,
      " was also FALSE (no action -> no outcome)"
    )
    warning(msg, call. = F)
  }
    

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
  if (null_rate > 0) {
    rate_warning(null_rate, "was null for required columns and removed")
  }
  metadata["null_rate"] <- null_rate

  # NOTE: remove inconsistent data where an outcome was recorded but there
  # was no action taken
  tbl <- filter(tbl, !(!!outcome_colq & !(!!action_colq)))
  correction_rate <- (n_after_drop_na - nrow(tbl)) / n_before_drop_na
  metadata["outcome_without_action_rate"] <- correction_rate
  if (correction_rate > 0) {
    rate_warning(
      correction_rate,
      "was inconsistent: outcome was positive but no action was taken"
    )
  }

  tbl
}


quos_names <- function(quos_var) { sapply(quos_var, quo_name) }


pretty_percent <- function(v) {
  str_c(formatC(100 * v, format = "f", digits = 2), "%")
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


if_else_na <- function(pred, pred_true, pred_false_or_na) {
  if_else(!is.na(pred) & pred, pred_true, pred_false_or_na)
}
