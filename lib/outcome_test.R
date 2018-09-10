source('opp.R')

outcome_test <- function(state, city, control_for = c()) {
  null_rate_warning_level = 0.05

  d <- opp_load_data(state, city)
  n <- nrow(d)

  if (!is.element("subject_race", control_for)) {
    control_for <- c("subject_race", control_for)
  }
  required_cols <- c(
    control_for,
    "search_conducted",
    "contraband_found"
  )
  missing_cols <- setdiff(required_cols, colnames(d))
  if (length(missing_cols) > 0) {
    warning(str_c("missing columns: ", str_c(missing_cols, collapse = ", ")))
    return(NA)
  }

  d <- select_(d, .dots=required_cols) %>% drop_na()
  null_rate <- (n - nrow(d)) / n
  if (null_rate > null_rate_warning_level) {
    warning("at least one column null rate: ", pretty_percent(null_rate))
  }

  filter(
    d,
    search_conducted
  ) %>%
  group_by_(
    .dots = control_for
  ) %>%
  summarize(
    contraband_found_rate = sum(contraband_found) / n()
  )
}
