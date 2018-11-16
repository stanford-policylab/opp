#!/usr/bin/env Rscript
source("opp.R")


marijuana_legalization_analysis <- function() {
  tbl <- load() %>% add_legalization_info()
  list(
    tables = (
      # TODO(danj): directionally, the coefficients are the same, but they
      # differ non-trivially; one reason may be that in reprocessing
      # the data, if search_conducted was true but search_basis was
      # undefined, we assumed the officer had "probable cause"; since
      # the original analysis leaves these as NA, their eligible
      # search_counts are lower; another reason could be predication
      # correction; if search_conducted is NA, search_basis is coerced
      # to also be NA, since if search_basis has a value, but
      # search_conducted is NA, one of the them has to be wrong, so we
      # uniformly chose the most general, i.e. search_conducted to
      # take precedence; lastly, there could be new data that was processed
      search_rate_difference_in_difference_coefficients =
        calculate_search_rate_difference_in_difference_coefficients(tbl)
    )
    # plots = (
    #   co_wa_misdemeanor_and_search_rates = 
    #     compose_test_misdemeanor_and_search_rates_plot(tbl),
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


calculate_search_rate_difference_in_difference_coefficients <- function(tbl) {
  tbl <- 
    tbl %>%
    filter(
      type == "vehicular",
      !is.na(date),
      !is.na(subject_race),
      # NOTE: search_basis = NA is interpreted as an ineligible search,
      # so don't filter out
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


compose_test_misdemeanor_and_search_rates_plot <- function(tbl) {

  tbl %>%
    filter(
      type == "vehicular",
      subject_race %in% c("black", "hispanic", "white"),
      is_test,
      !is.na(date),
      !is.na(subject_race)
    ) %>%
    select(
      state,
      date,
      legalization_date,
      subject_race,
      violation,
      search_basis,
      search_conducted
    ) %>%
    mutate(
      violation = str_to_lower(violation),
      is_marijuana_violation = if_else(
        state == "CO",
        str_detect(violation, "marijuana"),
        is_marijuana_violation
      ),
      is_marijuana_violation = if_else(
        state == "WA",
        str_detect(violation, "drugs - misdemeanor"),
        is_marijuana_violation,
      is_eligible_search =
        # NOTE: excludes consent and other (non-discretionary)
        search_basis %in% c("k9", "plain view", "probable cause")
      )
    ) %>%
    group_by(
      state,
      date,
      legalization_date,
      is_before_legalization,
      subject_race
    ) %>%
    summarize(
      n_stops_with_search_data = sum(!is.na(search_conducted)),
      n_eligible_searches = sum(is_eligible_search, na.rm = T),
      n_stops_with_violation_data = sum(!is.na(violation)),
      n_marijuana_violations = sum(is_marijuana_violation, na.rm = T)
    )

  trendlines <- group_by(tbl, state) %>% do(compute_search_trendline)

  # NOTE: roll up to quarters and remove data around legalization quarter
  # to reduce noise
  tbl <-
    tbl %>%
    mutate(
      quarter = as.Date(str_c(
        c("02", "05", "08", "11")[quarter(date)],
        "-15-",
        year(date)
      ))
    ) %>%
    filter(
      # NOTE: this quarter includes the legalization dates for both CO and WA
      quarter != as.Date("2012-11-15")
    ) %>%
    group_by(
      state,
      subject_race,
      quarter
    ) %>%
    summarize(
      n_stops_with_search_data = sum(n_stops_with_search_data),
      n_eligible_searches = sum(n_eligible_searches),
      eligible_search_rate = n_eligible_searches / n_stops_with_search_data,
      n_stops_with_violation_data = sum(n_stops_with_violation_data),
      n_marijuana_violations = sum(n_marijuana_violations),
      marijuana_violation_rate =
        n_marijuana_violations / n_stops_with_violation_data
    )

  ggplot(tbl, aes(x = quarter, y = ))



}


compute_search_trendline <- function(tbl) {
  # TODO(danj): why not use a linear model to predict rates? These numbers
  # are slightly different
  # lm(
  #   eligible_search_rate ~ subject_race + date,
  #   mutate(tbl, eligible_search_rate = n_eligible_searches / n_eligible)
  # )

  # # NOTE: (n_successes, n_failures) ~ X
  # # NOTE: date is interpreted numerically
  fit <- function(tbl) {
    glm(
      cbind(n_eligible_searches, n_stops_with_search_data - n_eligible_searches)
        ~ subject_race + date,
      binomial,
      tbl
    )
  }
  m_before <- fit(filter(tbl, is_before_change))
  m_after <- fit(filter(tbl, !is_before_change))
  score <- function(model, tbl) { predict(model, tbl, type = "response") }
  tbl %>%
    group_by(state, city, subject_race, is_before_change) %>%
    filter(date == min(date) | date == max(date)) %>%
    distinct() %>%
    ungroup() %>%
    mutate(predicted_search_rate = if_else(
      is_before_change,
      score(m_before, .),
      score(m_after, .)
    )) %>%
    select(
      state,
      city,
      subject_race,
      date,
      is_before_change,
      predicted_search_rate
    )
  }


if (!interactive()) {
  marijuana_legalization_analysis()
}
