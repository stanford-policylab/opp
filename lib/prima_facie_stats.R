library(here)
source(here::here("lib", "opp.R"))



prima_facie_stats <- function() {
  list(
    stop_rates = calculate_stop_rates(),
    search_rates = calculate_rates("search_conducted"),
    # NOTE: example steps for
    # calculate_rates("contraband_found", predicate = "search_conducted"):
    # For each location
    # 1. filter to date range
    # 2. filter to where search_conducted is true
    # 3. filter to where subject_race and contraband_found are not NA
    # 4. return empty tibble if the drop rate is above the maximum null rate
    # 5. calculate counts by subject_race
    # Finally, aggregate and calculate rates
    contraband_rates = calculate_rates(
      "contraband_found",
      predicate = "search_conducted"
    ),
    arrest_rate = calculate_rates("arrest_made"),
    citation_rate = calculate_rates("citation_issued"),
    warning_rate = calculate_rates("warning_issued")
  )
}


calculate_stop_rates <- function() {
  # 1. factfinder.census.gov -> Advanced Search
  # 2. Topics -> Datasets -> ACS 5 year estimate 2017
  # 3. Geographies -> Place -> All places in United States
  # 4. Race and Ethnic groups -> Hispanic or Latino 
  # 5. HISPANIC OR LATINO ORIGIN BY RACE
}


stop_and_population_counts <- function(
  state,
  city,
  start_year = 2012,
  end_year = 2017,
  max_null_rate = 0.1
) {
  tbl <-
    opp_load_clean_data(state, city) %>%
    mutate(year = year(date)) %>%
    filter(year >= start_year, year <= end_year) %>%
    filter_to_complete_years()

  before <- nrow(tbl)
  tbl <- filter(tbl, !is.na(subject_race))
  after <- nrow(tbl)
  null_rate <- (before - after) / before
  if (null_rate > max_null_rate)
    return(tibble(state = state, city = city))

  tbl %>%
  group_by(year, subject_race) %>%
  summarize(stop_count = n()) %>%
  left_join(
    opp_demographics(state, city),
    by = c("year" = "year", "subject_race" = "race")
  ) %>%
  rename(population = total) %>%
  group_by(subject_race) %>%
  summarize(
    stop_count = sum(stop_count),
    population = sum(population)
  ) %>%
  mutate(state = state, city = city)
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


calculate_rates <- function(
  col = "search_conducted",
  start_year = 2012,
  end_year = 2017,
  max_null_rate_per_location = 0.1,
  predicate = NA_character_
) {
  rate_name <- str_c(col, "_rate")
  count_name <- str_c(col, "_count")
  city_counts(
    col,
    start_year,
    end_year,
    max_null_rate_per_location,
    predicate
  ) %>%
  group_by(subject_race, state, city) %>%
  summarize(
    !!rate_name := sum(get(count_name), na.rm = T) / sum(n, na.rm = T),
    annual_n = annual_n
  ) %>% 
  group_by(subject_race) %>% 
  summarize(
    weighted_rate = weighted.mean(get(rate_name), w = annual_n)
  ) %>%
  drop_na()
}


city_counts <- function(
  col = "search_conducted",
  start_year = 2012,
  end_year = 2017,
  max_null_rate = 0.1,
  predicate = NA_character_
) {
  opp_available() %>%
  filter(city != "Statewide") %>%
  mutate(
    col = col,
    start_year = start_year,
    end_year = end_year,
    max_null_rate = max_null_rate,
    predicate = predicate
  ) %>%
  par_pmap(counts_for) %>%
  bind_rows() %>%
  select(state, city, everything())
}


counts_for <- function(
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
  name <- str_c(col, "_count")

  tbl %>%
  group_by(subject_race, year) %>%
  summarize(!!name := sum(get(col)), by_yr_n = n()) %>%
  group_by(subject_race) %>% 
  summarize(
    !!name := sum(get(name)), 
    annual_n = mean(by_yr_n), 
    n = sum(by_yr_n)
  ) %>% 
  mutate(state = state, city = city)
}
