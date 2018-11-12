source("opp.R")


# test_tbl: <tibble<state, city, change_date, violation_regex>>
# control_tbl: <tibble<state, city>>
# eligible_search_bases: c("<type_1>", "<type_2>", ...) [see standards.R]
policy_change_test <- function(
  test_tbl,
  control_tbl,
  eligible_search_bases
) {
  tbl <-
    bind_rows(select(test_tbl, state, city), control_tbl) %>%
    opp_load_all_data() %>%
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
    left_join(select(test_tbl, state, city, change_date)) %>%
    mutate(
      change_date = if_else(
        is.na(change_date),
        # NOTE: for control states, use minimum change date
        min(change_date, na.rm = T),
        change_date
      ),
      is_before_change = date < change_date
    )
  list(
    data = tbl,
    trendlines = compute_trendlines(tbl)
  )
}


add_violation_indicator <- function(tbl, test_tbl) {
  tbl <- mutate(tbl, violation_indicator = F)
  for (i in 1:nrow(test_tbl)) {
    tbl <- mutate(tbl, violation_indicator = if_else(
      state == test_tbl[[i, "state"]]
      & city == test_tbl[[i, "city"]]
      & str_detect(str_to_lower(violation), test_tbl[[i, "violation_regex"]]),
      T,
      violation_indicator
    ))
  }
  tbl
}


compute_trendlines <- function(tbl) {
  group_by(tbl, state, city) %>% do(compute_trendline(.))
}


compute_trendline <- function(tbl) {
  fit <- function(tbl) {
    glm(
      # NOTE: (n_successes, n_failures) ~ X
      # NOTE: date is interpreted numerically
      cbind(n_eligible_searches, n_eligible - n_eligible_searches)
        ~ subject_race + date,
      data = tbl,
      family = binomial
    )
    # TODO(danj): why not use a linear model to predict rates? These numbers
    # are slightly different
    # lm(
    #   eligible_search_rate ~ subject_race + date,
    #   mutate(tbl, eligible_search_rate = n_eligible_searches / n_eligible)
    # )
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


plot_timeseries <- function(tbl, trendlines_tbl) {
}
