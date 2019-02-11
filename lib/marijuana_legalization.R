#!/usr/bin/env Rscript
source(here::here("lib", "opp.R"))
source(here::here("lib", "analysis_common.R"))


marijuana_legalization_analysis <- function() {
  tbl <- load()
  test <- filter(tbl, state %in% c("CO", "WA"))
  control <- fitler(tbl, !(state %in% c("CO", "WA")))
  output <- list(
    data = tbl,
    tables = list(
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
    ),
    plots = list(
      # TODO(danj): change legend position for CO/WA
      test_search_rates = compose_search_rate_plots(test),
      control_search_rates = compose_search_rate_plots(control, is_test = F),
      test_misdemeanor_rates = compose_misdemeanor_rate_plots(test)
      # inferred_threshold_changes =
      #   compose_inferred_threshold_changes_plot(tbl)
    )
  )
  write_rds(output, here::here("cache", "marijuana_results.rds"))
}


load <- function() {
  tribble(
    ~state, ~city,
    # test
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
  opp_load_all_clean_data() %>%
  # TODO(danj): should these be updated with new data?
  filter(year(date) >= 2011 & year(date) <= 2015) %>%
  add_legalization_info()
}


add_legalization_info <- function(tbl) {
  mutate(
    tbl,
    # NOTE: default for control and WA is WA's legalization date
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
      # NOTE: excludes consent and other (non-discretionary)
      is_eligible_search = search_conducted & (is.na(search_basis)
        | search_basis %in% c("k9", "plain view", "probable cause"))
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


compose_search_rate_plots <- function(tbl, is_test = T) {
  tbl <-
    tbl %>%
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
      is_eligible_search = search_conducted & (is.na(search_basis)
        # NOTE: excludes consent and other (non-discretionary)
        | search_basis %in% c("k9", "plain view", "probable cause"))
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

  trends <- compute_trendlines(tbl)

  tbl <-
    tbl %>%
    # NOTE: roll up to quarters to reduce noisiness
    to_rates_by_quarter(n_eligible_searches, n_stops_with_search_data) %>%
    # NOTE: remove data around legalization quarter since it will be mixed
    filter(quarter != as.Date("2012-11-15"))

  compose_timeseries_rate_plot(tbl, "Search Rate", trends, is_test)
}


compute_trendlines <- function(tbl) {
  trendlines <- group_by(tbl, state) %>% do(compute_search_trendline(.))
  endpoints <-
    trendlines %>%
    group_by(state, subject_race, is_before_legalization) %>%
    filter(date == min(date) | date == max(date)) %>%
    mutate(position = if_else(date == min(date), "start", "end"))
  dt <- select(endpoints, -predicted_search_rate) %>% spread(position, date)
  rt <- select(endpoints, -date) %>% spread(position, predicted_search_rate)
  left_join(
    rename(dt, start_date = start, end_date = end),
    rename(rt, start_rate = start, end_rate = end)
  )
}


compute_search_trendline <- function(tbl) {
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


compose_timeseries_rate_plot <- function(
  tbl,
  y_axis_label,
  trends = NULL,
  is_test = T
) {
  p <-
    ggplot(
      tbl,
      aes(
        x = quarter,
        y = rate,
        color = subject_race,
        group = interaction(subject_race, is_before_legalization)
      )
    ) +
    geom_line(
    ) +
    geom_vline(
      xintercept = tbl$legalization_date,
      linetype = "longdash"
    ) +
    facet_wrap(
      state ~ .,
      scales = "free_y"
    ) +
    scale_color_manual(
      values = c("black", "red", "blue"),
      labels = c("Black", "Hispanic", "White")
    ) +
    scale_y_continuous(
      y_axis_label,
      labels = scales::percent,
      expand = c(0, 0)
    ) +
    expand_limits(
      y = -0.0001
    ) +
    theme(
      # NOTE: default for control states
      legend.position = if_else(
        is_test,
        c(0.96, 0.95),
        c(0.88, 0.88)
      ),
      axis.title.x = element_blank(),
      panel.spacing = unit(0.5, "lines"),
      plot.margin = unit(c(0.1, 0.2, 0.1, 0.1), "in")
    )

  if (!is.null(trends)) {
    p <-
      p +
      geom_segment(
        data = trends,
        aes(
          x = start_date,
          xend = end_date,
          y = start_rate,
          yend = end_rate,
          color = subject_race,
          group = interaction(subject_race, is_before_legalization)
        ),
        linetype = "longdash",
        size = 0.8
      )
  }

  p
}


compose_misdemeanor_rate_plots <- function(tbl, is_test = T) {
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
    violation
  ) %>%
  mutate(
    violation = str_to_lower(violation),
    is_misdemeanor_drugs_violation = if_else(
      state == "CO",
      str_detect(violation, "marijuana"),
      is_misdemeanor_drugs_violation
    ),
    is_misdemeanor_drugs_violation = if_else(
      state == "WA",
      str_detect(violation, "drugs - misdemeanor"),
      is_misdemeanor_drugs_violation
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
    n_misdemeanor_drugs_violations =
      sum(is_misdemeanor_drugs_violation, na.rm = T),
    n_stops_with_violation_data = sum(!is.na(violation))
  ) %>%
  ungroup(
  ) %>%
  # NOTE: roll up to quarters to reduce noisiness
  to_rates_by_quarter(
    n_misdemeanor_drugs_violations,
    n_stops_with_violation_data
  ) %>%
  # NOTE: remove data around legalization quarter since it will be mixed
  filter(
    quarter != as.Date("2012-11-15")
  ) %>%
  compose_timeseries_rate_plot(
    "Drugs Misdemeanor Rate",
    is_test
  )
}


if (!interactive()) {
  marijuana_legalization_analysis()
}
