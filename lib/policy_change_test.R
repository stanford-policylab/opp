source("opp.R")


# test_tbl: <state, city, change_date, violation_regex>
# control_tbl: <state, city>
# eligible_searches: c("<type_1>", "<type_2>", ...) [see standards.R]
policy_change_test <- function(
  test_tbl,
  control_tbl,
  eligible_search_bases
) {
  tbl <-
    bind_rows(select(test_tbl, state, city), control_tbl) %>%
    opp_load_all_data() %>%
    add_violation_indicator(test_tbl) %>%
    add_pre_post_indicator(test_tbl) %>%
    mutate(search_is_eligible = search_basis %in% eligible_search_bases) %>%
    group_by(state, city, subject_race, date) %>%
    summarize(
      n = n(),
      n_target_violations = sum(violation_indicator),
      n_violations = sum(!is.na(violation)),
      n_eligible_searches = sum(search_is_eligible),
      n_searches = sum(search_conducted, na.rm = T)
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
  trendlines <- compute_trendlines(tbl)
  list(data = tbl, trends = trendlines)
}


add_violation_indicator <- function(tbl, test_tbl) {
  tbl <- mutate(tbl, violation_indicator = F)
  for (i in 1:nrow(test_tbl)) {
    tbl <- mutate(tbl, violation_indicator = if_else(
      state == test_tbl[i, "state"]
      & city == test_tbl[i, "city"]
      & str_detect(str_c_to_lower(violation), test_tbl[i, "violation_regex"]),
      T,
      violation_indicator
    ))
  }
}


compute_trendlines <- function(tbl) {
  group_by(tbl, state, city) %>% do(compute_trendline)
}


compute_trendline <- function(tbl) {
  # TODO(danj): try fitting a linear regression rather than logistic
  fit <- function(tbl) {
    glm(
      # NOTE: (n_successes, n_failures) ~ X
      # NOTE: date is interpreted numerically
      cbind(n_eligible_searches, n_searches - n_eligible_searches)
        ~ subject_race + date,
      data = tbl,
      family = binomial
    )
  }
  m_before <- fit(filter(tbl, is_before_change))
  m_after <- fit(filter(tbl, !is_before_change))
  tbl %>%
    group_by(subject_race, is_before_change) %>%
    filter(date == min(date) | date == max(date)) %>%
    distinct() %>%
    mutate(
      predicted_search_rate = if_else(
        is_before_change,
        predict(m_before, ., type = "response"),
        predict(m_after, ., type = "response")
      )
    ) %>%
    select(subject_race, date, predicted_search_rate)
}

