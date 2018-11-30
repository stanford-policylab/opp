#!/usr/bin/env Rscript
source("opp.R")
source("analysis_common.R")


marijuana_legalization_analysis <- function() {
  tbl <- load()
  srp <- compose_search_rates_plots(tbl)
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
    # TODO(amyshoe): something is off in Florida, almost no eligible black and white
    # searches
    # "FL", "Statewide",
    "MA", "Statewide",
    # TODO(amyshoe): something wrong here too, values are very small
    # "MT", "Statewide",
    "NC", "Statewide",
    "OH", "Statewide",
    "RI", "Statewide",
    # TODO(amyshoe): something wrong here too, glm doesn't converge, values are very
    # small
    # "SC", "Statewide",
    "TX", "Statewide",
    "VT", "Statewide",
    "WI", "Statewide"
  ) %>%
  opp_load_all_data() %>%
  # TODO(danj): should these be updated with new data?
  filter(year(date) >= 2011 & year(date) <= 2015) %>%
  add_legalization_info()
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


compose_search_rate_plots <- function(tbl) {

  tbl <- tbl %>%
    filter(
      type == "vehicular",
      subject_race %in% c("black", "hispanic", "white"),
      !is.na(date),
      !is.na(subject_race)
    ) %>%
    select(
      state,
      date,
      legalization_date,
      is_before_legalization,
      subject_race,
      search_basis,
      search_conducted
    ) %>%
    mutate(
      subject_race = droplevels(subject_race),
      is_eligible_search =
        # NOTE: excludes consent and other (non-discretionary)
        search_basis %in% c("k9", "plain view", "probable cause")
    ) %>%
    group_by(
      state,
      date,
      legalization_date,
      is_before_legalization,
      subject_race
    ) %>%
    summarize(
      n_eligible_searches = sum(is_eligible_search, na.rm = T),
      n_stops_with_search_data = sum(!is.na(search_conducted))
    ) %>%
    ungroup()

  trendlines <- group_by(tbl, state) %>% do(compute_search_trendline(.))

  # NOTE: roll up to quarters and remove data around legalization quarter
  # to reduce noise
  tbl <- tbl %>%
    to_rates_by_quarter(n_eligible_searches, n_stops_with_search_data) %>%
    filter(quarter != as.Date("2012-11-15"))

  list(t = trendlines, tbl = tbl)
}


to_rates_by_quarter <- function(tbl, numerator_col, denominator_col) {
  nq <- enquo(numerator_col)
  dq <- enquo(denominator_col)
  n_name <- quo_name(nq)
  d_name <- quo_name(dq)
  group_by_colnames <- c(
    setdiff(
      colnames(tbl),
      c(n_name, d_name, "date")
    ),
    "quarter"
  )
  tbl <-
    tbl %>%
    mutate(
      quarter = as.Date(str_c(
        year(date),
        c("-02-", "-05-", "-08-", "-11-")[quarter(date)],
        "15"
      ))
    ) %>%
    group_by(.dots = group_by_colnames) %>%
    summarize(rate = sum(!!nq) / sum(!!dq)) %>%
    ungroup()
}


compute_search_trendline <- function(tbl) {
  # TODO(danj): why not use a linear model to predict rates? These numbers
  # are slightly different
  # lm(
  #   eligible_search_rate ~ subject_race + date,
  #   mutate(tbl, eligible_search_rate = n_eligible_searches / n_eligible)
  # )
  fit <- function(tbl) {
    glm(
      # NOTE: (n_successes, n_failures) ~ X
      # NOTE: date is interpreted numerically
      cbind(n_eligible_searches, n_stops_with_search_data - n_eligible_searches)
        ~ subject_race + date,
      binomial,
      tbl
    )
  }
  m_before <- fit(filter(tbl, is_before_legalization))
  m_after <- fit(filter(tbl, !is_before_legalization))
  score <- function(model, tbl) { predict(model, tbl, type = "response") }
  tbl %>%
    group_by(state, subject_race, is_before_legalization) %>%
    filter(date == min(date) | date == max(date)) %>%
    distinct() %>%
    ungroup() %>%
    mutate(
      predicted_search_rate = if_else(
        is_before_legalization,
        score(m_before, .),
        score(m_after, .)
      )
    ) %>%
    select(
      state,
      subject_race,
      date,
      is_before_legalization,
      predicted_search_rate
    )
}


compose_timeseries_rate_plot <- function(tbl, y_axis_label) {
  ggplot(
    tbl,
    aes(
      x = quarter,
      y = rate,
      color = subject_race,
      group = interaction(subject_race, is_before_legalization)
    )
  ) +
  geom_line() +
  scale_color_manual(values = c(
    "white" = "blue",
    "black" = "black",
    "hispanic" = "red"
  )) +
  scale_y_continuous(y_axis_label, labels = scales::percent, expand = c(0, 0)) +
  expand_limits(y = -0.0001) +
  facet_wrap(~ state, scales = "free_y") +
  geom_vline(aes(xintercept = legalization_date), linetype = "longdash") +
  base_theme() +
  theme(
    # NOTE: default for control states
    legend.position = c(0.96, 0.95),
    axis.title.x = element_blank(),
    panel.margin = unit(0.5, "lines"),
    plot.margin = unit(c(0.1, 0.2, 0.1, 0.1), "in")
  )
  # TODO(danj): change legend position for CO/WA
  # TODO(danj): add geom_segment trendlines for those with trendlines
}


compose_test_misdemeanor_plots <- function(tbl) {

  tbl <- tbl %>%
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
      violation
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
        is_marijuana_violation
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
      n_marijuana_violations = sum(is_marijuana_violation, na.rm = T),
      n_stops_with_violation_data = sum(!is.na(violation))
    ) %>%
    ungroup(
    ) %>%
    # NOTE: roll up to quarters and remove data around legalization quarter
    # to reduce noise
    to_rates_by_quarter(
      n_eligible_searches,
      n_stops_with_search_data
    ) %>%
    filter(
      quarter != as.Date("2012-11-15")
    )

}


if (!interactive()) {
  marijuana_legalization_analysis()
}
