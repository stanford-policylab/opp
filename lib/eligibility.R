source("opp.R")


eligiblity <- function() {
  data <- opp_load_all_data()
  # uni <- full_universe_of_stops_represented(data)
  # bse <- basic_stats_eligibility(data)
  # ote <- outcome_test_elibility(data)
  system.time(s <- group_by(
    d,
    state,
    city
  ) %>%
  summarize(
    universe = n_distinct(outcome) >= 3,  # arrest, citation, warning
    frisk = sum(!is.na(frisk_performed)) / n(),
    search = sum(!is.na(search_conducted)) / n(),
    contraband = sum(!is.na(contraband_found)) / n(),
    search_and_contraband =
      sum(!is.na(search_conducted) & !is.na(contraband_found)) / n()
  ))
}


full_universe_of_stops_represented <- function(data) {
  group_by(
    data,
    state,
    city
  ) %>%
  summarize(
    universe = n_distinct(outcome) >= 3  # arrest, citation, warning
  )
}

basic_stats_eligibility <- function(data) {
  group_by(
    data,
    state,
    city
  ) %>%
  summarize(
    frisk = sum(!is.na(frisk_performed)) / n(),
    search = sum(!is.na(search_conducted)) / n()
  )
}

outcome_test_eligibility <- function() {
  group_by(
    data,
    state,
    city
  ) %>%
  summarize(
    search_and_contraband =
      sum(!is.na(search_conducted) & !is.na(contraband_found)) / n()
  )
}

threshold_test_eligibility <- function() {
}

veil_of_darkness_eligibility <- function() {
}


