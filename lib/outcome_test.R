source('opp.R')


outcome_test <- function(
  state,
  city,
  race_col = "subject_race",
  search_col = "search_conducted",
  contraband_col = "contraband_found",
  control_for = c()
) {
  d <- opp_load_data(state, city)
  metadata <- list()

  outcome_by <- c(race_col, control_for)
  required_cols <- c(outcome_by, search_col, contraband_col)
  missing_cols <- setdiff(required_cols, colnames(d))
  if (length(missing_cols) > 0) {
    warning(str_c("missing columns: ", str_c(missing_cols, collapse = ", ")))
    return(NA)
  }

  n <- nrow(d)
  d <- select_(d, .dots=required_cols) %>% drop_na()
  null_rate <- (n - nrow(d)) / n
  metadata['null_rate'] <- null_rate
  if (null_rate > 0) {
    warning("at least one column null rate: ", pretty_percent(null_rate))
  }

  results <- filter(
    d,
    search_conducted
  ) %>%
  group_by_(
    .dots = outcome_by
  ) %>%
  summarize(
    contraband_found_rate = sum(contraband_found) / n()
  )

  list(
    results = results,
    metadata = metadata
  )
}
