#!/usr/bin/env Rscript
source("opp.R")


marijuana_legalization_analysis <- function() {
  tbl <- load() %>% add_legalization_info()
  list(
    tables = (
      difference_in_difference_coefficients =
        calculate_difference_in_difference_coefficients(tbl)
    )
    # plots = (
    #   co_wa_misdemeanor_and_search_rates = 
    #     compose_co_wa_misdemeanor_and_search_rates_plot(tbl),
    #   control_search_rates = 
    #     compose_control_search_rates_plot(tbl),
    #   inferred_threshold_changes =
    #     compose_inferred_threshold_changes_plot(tbl)
    # )
  )
}


load <- function() {
  tribble(
    ~state, ~city,
    # treatment
    "CO", "Statewide",
    "WA", "Statewide",
    # control
    "AZ", "Statewide",
    "CA", "Statewide",
    "FL", "Statewide",
    "MA", "Statewide",
    "MT", "Statewide",
    "NC", "Statewide",
    "OH", "Statewide",
    "RI", "Statewide",
    "SC", "Statewide",
    "TX", "Statewide",
    "VT", "Statewide",
    "WI", "Statewide"
  ) %>%
  opp_load_all_data()
}


add_legalization_info <- function(tbl) {
  tbl %>%
    mutate(
      # NOTE: default is WA's legalization date, which is 1 day earlier than CO
      legalization_date = as.Date("2012-12-09"),
      legalization_date = if_else(
        state == "CO",
        as.Date("2012-12-10"),
        legalization_date
      ),
      is_before_legalization = date < legalization_date,
      is_test = state %in% c("CA", "CO"),
      is_treatment = is_test & !is_before_legalization
    )
}


calculate_difference_in_difference_coefficients <- function(tbl) {
  tbl <- 
    # TODO(danj): difference due to probable cause search?
    tbl %>%
    filter(
      type == "vehicular",
      !is.na(date),
      !is.na(subject_race),
      # NOTE: search_basis = NA is an ineligible search, don't filter out
      !is.na(search_conducted)
    ) %>%
    select(
      is_treatment,
      state,
      date,
      legalization_date,
      subject_race,
      search_basis,
      search_conducted
    ) %>%
    mutate(
      is_eligible_search =
        # NOTE: excludes consent and other (non-discretionary)
        search_basis %in% c("k9", "plain view", "probable cause")
    ) %>%
    group_by(
      is_treatment,
      state,
      date,
      legalization_date,
      subject_race
    ) %>%
    summarize(
      n_eligible_searches = sum(is_eligible_search, na.rm = T),
      n_stops_with_search_data = n()
    ) %>%
    ungroup(
    ) %>%
    mutate(
      years_since_legalization = as.numeric(date - legalization_date) / 365
    )

  m <- glm(
    cbind(n_eligible_searches, n_stops_with_search_data - n_eligible_searches)
      ~ state + years_since_legalization + subject_race +
        is_treatment:subject_race,
    binomial,
    tbl
  )
  coefs <- summary(m)$coefficients[, c("Estimate", "Std. Error")]
  as_tibble(coefs) %>%
    mutate(coefficient = rownames(coefs)) %>%
    rename(estimate = Estimate, std_error = `Std. Error`) %>%
    select(coefficient, estimate, std_error)
}

# marijuana_legalization <- function() {
#   results <- policy_change_test(
#     test_tbl = tribble(
#       ~state, ~city, ~change_date, ~violation_regex,
#       "CO", "Statewide", "2012-12-10", "marijuana",
#       # TODO(danj): WA also has Drugs Paraphernalia - Misdemeanor
#       "WA", "Statewide", "2012-12-09", "drugs - misdemeanor"
#     ),


if (!interactive()) {
  marijuana_legalization_analysis()
}
