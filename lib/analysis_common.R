library(here)
library(parallel)
library(tidyverse)
library(stringr)
source(here::here("lib", "utils.R"))


locations_used_in_analyses <- function() {
  bind_rows(
    locations_in_analysis("veil_of_darkness"),
    locations_in_analysis("marijuana_legalization"),
    locations_in_analysis("disparity")
  ) %>%
  distinct()
}


locations_in_analysis <- function(analysis_name) {
  source_non_interactive(here::here("lib", str_c(analysis_name, ".R")))
  states <- tibble()
  cities <- tibble()
  if (exists("ELIGIBLE_STATES"))
    states <- ELIGIBLE_STATES
  if (exists("ELIGIBLE_CITIES"))
    cities <- ELIGIBLE_CITIES
  bind_rows(states, cities)
}


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

  stopifnot(length(quos_names(control_colqs)) > 0)

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
    pct_warning(null_rate, "of data was null for required columns and removed")
  }
  metadata["null_rate"] <- null_rate

  # NOTE: remove inconsistent data where an outcome was recorded but there
  # was no action taken
  tbl <- filter(tbl, !(!!outcome_colq & !(!!action_colq)))
  correction_rate <- (n_after_drop_na - nrow(tbl)) / n_before_drop_na
  metadata["outcome_without_action_rate"] <- correction_rate
  if (correction_rate > 0) {
    pct_warning(
      correction_rate,
      "of data was inconsistent: outcome was positive but no action was taken"
    )
  }

  tbl
}


quos_names <- function(quos_var) { sapply(quos_var, quo_name) }


pretty_percent <- function(v) {
  str_c(formatC(100 * v, format = "f", digits = 2), "%")
}


select_and_filter_missing <- function(d, ...) {
  colqs <- enquos(...)
  before_drop_na <- nrow(d$data)
  d$data <- select(d$data, !!!colqs) %>% drop_na
  after_drop_na <- nrow(d$data)
  null_percent <- (before_drop_na - after_drop_na) / before_drop_na
  d$metadata["null_rate"] <- null_percent
  if (null_percent > 0) {
    pct_warning(
      null_percent,
      "of data dropped due to missing values in required columns"
    )
  }
  d
}



pct_warning <- function(rate, message) {
  warning(
    str_c(
      formatC(100 * rate, format = "f", digits = 2), 
      "% ",
      message
    ),
    call. = FALSE
  )
}


if_else_na <- function(pred, pred_true, pred_false_or_na) {
  if_else(!is.na(pred) & pred, pred_true, pred_false_or_na)
}


base_theme <- function() {
  theme_bw(base_size = 15) +
    theme(
      # NOTE: remove the title
      plot.title = element_blank(),
      # NOTE: make the background white
      panel.background = element_rect(fill = "white", color = "white"),
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank(),
      # NOTE: minimize margins
      plot.margin = unit(rep(0.2, 4), "cm"),
      panel.margin = unit(0.25, "lines"),
      # NOTE: tiny space between axis labels and tick marks
      axis.title.x = element_text(margin = ggplot2::margin(t = 6.0)),
      axis.title.y = element_text(margin = ggplot2::margin(t = 6.0)),
      # NOTE: simplify legend
      legend.key = element_blank(),
      legend.background = element_rect(fill = "transparent"),
      legend.title = element_blank()
    )
}
