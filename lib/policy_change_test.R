library(tidyverse)
source("analysis_common.R")

# NOTE: treatment is defined as after change date and in test group
timeseries_policy_change_plots <- function(
  tbl,
  ...,
  date_col = date,
  change_date_col = change_date,
  test_indicator_col = is_test,
  measurement_col = search_rate
) {
  control_colqs <- enquos(...)
  date_colq <- enquo(date_col)
  change_date_colq <- enquo(change_date_col)
  test_indicator_colq <- enquo(test_indicator_col)
  measurement_colq <- enquo(measurement_col)

  d <- select_and_filter_missing(
    !!!control_colqs,
    !!date_colq,
    !!change_date_colq,
    !!test_indicator_colq,
    !!measurement_colq
  )

  list(
    data = d$data,
    metadata = d$metadata,
    plots = compose_plots(mutate(d$data, date = date_plot_func(date)))
    diff_in_diff =
      compute_diff_in_diff(mutate(d$data, date date_diff_in_diff_func)
  )
}

policy_change_test <- function(
  test_tbl,
  control_tbl,
  eligible_search_bases
) {
  tbl <-
    bind_rows(select(test_tbl, state, city), control_tbl) %>%
    opp_load_all_clean_data() %>%
    filter(!is.na(subject_race), !is.na(date), !is.na(violation)) %>%
    add_violation_indicator(test_tbl) %>%
    mutate(search_is_eligible = search_basis %in% eligible_search_bases) %>%
    group_by(state, city, subject_race, date) %>%
    summarize(
      n_violations = sum(!is.na(violation)),
      n_target_violations = sum(violation_indicator),
      n_eligible = sum(!is.na(search_conducted)),
      n_eligible_searches = sum(search_is_eligible)
    ) %>%
    ungroup() %>%
    left_join(
      select(test_tbl, state, city, change_date) %>%
      mutate(is_test = T)
    ) %>%
    mutate(
      change_date = as.Date(if_else(
        is.na(change_date),
        # NOTE: for control states, use minimum change date
        min(change_date, na.rm = T),
        change_date
      )),
      is_before_change = date < change_date,
      years_since_legalization = (date - change_date) / 365,
      is_test = if_else(is.na(is_test), F, is_test),
      # NOTE: treatment is test city + after policy change
      is_treatment = if_else(!is_test, F, is_test & !is_before_change)
    )
  list(
    data = tbl,
    difference_in_difference = compute_difference_in_difference(tbl),
    plots = compose_plots(tbl)
    # TODO(danj): threshold test
    # TODO(danj): coverage
  )
}


add_violation_indicator <- function(tbl, test_tbl) {
  tbl <- mutate(tbl, violation_indicator = F)
  for (i in 1:nrow(test_tbl)) {
    tbl <- mutate(tbl, violation_indicator = if_else(
      state == test_tbl[[i, "state"]]
      & city == test_tbl[[i, "city"]]
      & str_detect(
        str_to_lower(violation),
        test_tbl[[i, "violation_regex"]]
      ),
      T,
      violation_indicator
    ))
  }
  tbl
}


compute_difference_in_difference <- function(tbl, date_func) {
  # TODO(danj): interact state + city?
  fmla <- as.formula(str_c(
    "cbind(n_eligible_searches, n_eligible - n_eligible_searches)",
    " ~ state", if_else(n_distinct(tbl$city) == 1, "", " + city"),
    " + years_since_legalization + subject_race + is_treatment:subject_race"
  ))
  m <- glm(fmla, binomial, tbl)
  coefs <- summary(m)$coefficients[, c("Estimate", "Std. Error")]
  as_tibble(coefs) %>%
    mutate(coefficient = rownames(coefs)) %>%
    rename(estimate = Estimate, std_error = `Std. Error`) %>%
    select(coefficient, estimate, std_error)
}


compose_plots <- function(
  tbl,
  target_col,
  add_trendlines = T,
  # NOTE: default is to convert dates to mid-quarter dates
  date_func = function(date) {
    str_c(c("02-15-", "05-15-", "08-15-", "11-15-")[quarter(date)], year(date))
  }
) {
  
}


compute_trendlines <- function(tbl, fmla) {
  group_by(tbl, state, city) %>% do(compute_trendline(., fmla))
}


compute_trendline <- function(tbl, fmla) {
  # # NOTE: (n_successes, n_failures) ~ X
  # # NOTE: date is interpreted numerically
  # cbind(n_eligible_searches, n_eligible - n_eligible_searches)
  # ~ subject_race + date,

  # TODO(danj): why not use a linear model to predict rates? These numbers
  # are slightly different
  # lm(
  #   eligible_search_rate ~ subject_race + date,
  #   mutate(tbl, eligible_search_rate = n_eligible_searches / n_eligible)
  # )
  fit <- function(tbl) { glm(fmla, binomial, tbl) }
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
