library(here)
source(here::here("lib", "opp.R"))



prima_facie_stats <- function() {
  list(
    stop_rates = aggregate_city_stop_stats_all_combined(),
    search_rates = aggregate_city_stats_all_combined("search_conducted"),
    # NOTE: example steps for
    # calculate_rates("contraband_found", predicate = "search_conducted"):
    # For each location
    # 1. filter to date range
    # 2. filter to where search_conducted is true
    # 3. filter to where subject_race and contraband_found are not NA
    # 4. return empty tibble if the drop rate is above the maximum null rate
    # 5. calculate counts by subject_race
    # Finally, aggregate and calculate rates
    contraband_rates = aggregate_city_stats_all_combined(
      "contraband_found",
      predicate = "search_conducted"
    ),
    arrest_rates = aggregate_stats_all_combined("arrest_made"),
    citation_rates = aggregate_stats_all_combined("citation_issued"),
    warning_rates = aggregate_stats_all_combined("warning_issued")
  )
}


aggregate_city_stop_stats_all_combined <- function(
  start_year = 2012,
  end_year = 2017,
  max_null_rate = 0.1
) {
  aggregate_city_stop_stats_all(
    start_year,
    end_year,
    max_null_rate
  ) %>%
  group_by(subject_race) %>%
  # NOTE: weighted average rate for each race where the weighting is average
  # number of stops per year for that race and city
  summarize(stop_rate = weighted.mean(stop_rate, w = stop_average)) %>%
  drop_na()
}


aggregate_city_stop_stats_all <- function(
  start_year = 2012,
  end_year = 2017,
  max_null_rate = 0.1
) {
  par_pmap(
    opp_available() %>% filter(city != "Statewide"),
    function(state, city) {
      aggregate_city_stop_stats(
        state,
        city,
        start_year,
        end_year,
        max_null_rate
      )
    }
  ) %>%
  bind_rows()
}


aggregate_city_stop_stats <- function(
  state,
  city,
  start_year = 2012,
  end_year = 2017,
  max_null_rate = 0.1
) {
  tbl <- city_stop_stats(
    state,
    city,
    start_year,
    end_year,
    max_null_rate
  )

  if (nrow(tbl) <= 1)
    return(tbl)

  tbl %>%
  group_by(state, city, subject_race) %>% 
  summarize(
    stop_total = sum(stop_count), 
    stop_average = mean(stop_count), 
    population_total = sum(population),
    population_average = mean(population),
    stop_rate = stop_total / population_total
  )
}


city_stop_stats_all <- function(
  start_year = 2012,
  end_year = 2017,
  max_null_rate = 0.1
) {
  opp_available() %>%
  filter(city != "Statewide") %>%
  par_pmap(function(state, city) {
    city_stop_stats(
      state,
      city,
      start_year,
      end_year,
      max_null_rate
    )
  }) %>%
  bind_rows()
}


city_stop_stats <- function(
  state,
  city,
  start_year = 2012,
  end_year = 2017,
  max_null_rate = 0.1
) {
  empty <- tibble(state = state, city = city)
  tbl <-
    opp_load_clean_data(state, city) %>%
    mutate(state = state, city = city, year = year(date)) %>%
    filter(year >= start_year, year <= end_year) %>%
    filter_to_complete_years()

  if (nrow(tbl) == 0 | !("subject_race" %in% colnames(tbl)))
    return(empty)

  before <- nrow(tbl)
  tbl <- drop_na(tbl, subject_race)
  after <- nrow(tbl)
  null_rate <- (before - after) / before
  if (null_rate > max_null_rate)
    return(empty)

  tbl %>%
  group_by(state, city, year, subject_race) %>%
  summarize(stop_count = n()) %>%
  left_join(
    opp_demographics(state, city) %>% select(-state),
    c("subject_race" = "race")
  )
}


filter_to_complete_years <- function(tbl, min_monthly_stops = 100) {
  # NOTE: years where at least one month had fewer than 3 standard deviations
  # below the yearly mean stop count or fewer than min_monthly_stops are
  # removed

  year_month_counts <-
    tbl %>%
    mutate(year = year(date), year_month = format(date, "%Y-%m")) %>%
    group_by(year, year_month) %>%
    count()

  year_stats <-
    year_month_counts %>%
    group_by(year) %>%
    summarize(
      mu = mean(n),
      sd = sd(n),
      mu_less_3_sd = mu - 3 * sd
    )

  valid_years <-
    year_month_counts %>%
    left_join(year_stats) %>%
    mutate(is_valid = n > max(min_monthly_stops, mu_less_3_sd)) %>%
    group_by(year) %>%
    summarize(valid_total = sum(is_valid)) %>%
    ungroup() %>%
    filter(valid_total == 12)

  res <- tibble()
  if (nrow(valid_years) > 0)
    res <- filter(tbl, year(date) %in% pull(valid_years, year))
  res
}


aggregate_stats_all_combined <- function(
  col = "search_conducted",
  start_year = 2012,
  end_year = 2017,
  max_null_rate_per_location = 0.1,
  predicate = NA_character_
) {
  rate_name = str_c(col, "_rate")
  aggregate_city_stats_all(
    col,
    start_year,
    end_year,
    max_null_rate_per_location,
    predicate
  ) %>%
  mutate(
    is_state = city == "Statewide"
  ) %>%
  group_by(is_state, subject_race) %>%
  # NOTE: weighted average rate for each race where the weighting is average
  # eligible number of stops per year for that race and city
  summarize(
    !!rate_name := weighted.mean(get(rate_name), w = average_eligible)
  ) %>%
  drop_na()
}


aggregate_stats_all <- function(
  col = "search_conducted",
  start_year = 2012,
  end_year = 2017,
  max_null_rate_per_location = 0.1,
  predicate = NA_character_
) {
  rate_name <- str_c(col, "_rate")
  par_pmap(
    opp_available() %>%
    function(state, city) {
      aggregate_city_stats(
        state,
        city,
        col,
        start_year,
        end_year,
        max_null_rate_per_location,
        predicate
      )
    }
  ) %>%
  bind_rows()
}


aggregate_stats <- function(
  state,
  city,
  col = "search_conducted",
  start_year = 2012,
  end_year = 2017,
  max_null_rate_per_location = 0.1,
  predicate = NA_character_
) {
  tbl <- city_stats(
    state,
    city,
    col,
    start_year,
    end_year,
    max_null_rate_per_location,
    predicate
  )

  if (nrow(tbl) <= 1)
    return(tbl)

  rate_name <- str_c(col, "_rate")
  count_name <- str_c(col, "_count")
  total_name <- str_c(col, "_total")

  tbl %>%
  group_by(state, city, subject_race) %>% 
  summarize(
    !!total_name := sum(get(count_name)), 
    average_eligible = mean(eligible_count), 
    total_eligible = sum(eligible_count),
    !!rate_name := get(total_name) / total_eligible 
  )
}


stats_all <- function(
  col = "search_conducted",
  start_year = 2012,
  end_year = 2017,
  max_null_rate = 0.1,
  predicate = NA_character_
) {
  opp_available() %>%
  par_pmap(function(state, city) {
    city_stats(
      state,
      city,
      col,
      start_year,
      end_year,
      max_null_rate,
      predicate
    )
  }) %>%
  bind_rows()
}


stats <- function(
  state,
  city,
  col = "search_conducted",
  start_year = 2012,
  end_year = 2017,
  max_null_rate = 0.1,
  predicate = NA_character_
) {
  empty <- tibble(state = state, city = city)
  tbl <-
    opp_load_clean_data(state, city) %>%
    mutate(state = state, city = city, year = year(date)) %>%
    filter(year >= start_year, year <= end_year)
  # NOTE: filters to predicate if present, i.e. search_conducted for
  # contraband_found, otherwise returns an empty tibble
  if (!is.na(predicate)) {
    if (!(predicate %in% colnames(tbl)))
      return(empty)
    tbl <- filter(tbl, get(predicate))
  }
  # NOTE: returns an empty tibble if subject_race and target col not in data
  if (!all(c("subject_race", col) %in% colnames(tbl)))
    return(empty)
  # NOTE: drop rows where subject_race and target column are NA, return an
  # empty tibble is the null rate is greater than the specified threshold
  before <- nrow(tbl)
  tbl <- drop_na(tbl, subject_race, !!col)
  after <- nrow(tbl)
  null_rate <- (before - after) / before
  if (null_rate > max_null_rate)
    return(empty)

  count_name <- str_c(col, "_count")
  rate_name <- str_c(col, "_rate")
  tbl %>%
  group_by(state, city, year, subject_race) %>%
  summarize(
    !!count_name := sum(get(col)),
    eligible_count = n(),
    !!rate_name := get(count_name) / eligible_count
  )
}
