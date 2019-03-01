library(here)
library(lubridate)
source(here::here("lib", "opp.R"))
source(here::here("lib", "analysis_common.R"))



coverage_for_paper <- function(use_cache = T) {
  coverage(use_cache) %>%
  inner_join(locations_used_in_analyses()) %>%
  mutate_if(
    function(v) all(is.numeric(v) & v <= 1.0, na.rm = T), 
    # NOTE: put dot if coverage above 70%
    function(v) if_else(v < 0.7 | is.na(v), "", "dot")
  ) %>%
  mutate(
    order = if_else(city == "Statewide", 1, 0),
    city = if_else(city == "Statewide", "--", city),
    nrows = comma_num(nrows),
    years = str_c(year(start_date), "-", year(end_date))
  ) %>%
  select(
    order,
    state,
    city,
    nrows,
    years,
    date,
    time,
    geodivision,
    subject_race,
    subject_age,
    subject_sex,
    search_conducted,
    contraband_found
  ) %>%
  rename(
    State = state,
    City = city,
    Stops = nrows,
    `Date Range` = years,
    `Date` = date,
    `Time` = time,
    `Geographic Division` = geodivision,
    `Subject Race` = subject_race,
    `Subject Age` = subject_age,
    `Subject Sex` = subject_sex,
    `Search Conducted` = search_conducted,
    `Contraband Found` = contraband_found
  ) %>%
  arrange(
    order,
    State,
    City
  ) %>%
  select(
    -order
  )
}


coverage <- function(use_cache = T) {
  cache_path <- here::here("cache", "coverage.rds")
  if (use_cache & file.exists(cache_path)) {
    cvg <- readRDS(cache_path)
  } else {
    cvg <-
      opp_apply(calculate_coverage) %>%
      bind_rows() %>%
      arrange(state, city)
    saveRDS(cvg, here::here("cache", "coverage.rds"))
  }
  cvg
}


calculate_coverage <- function(state, city) {
  # NOTE: for coverage we filter to vehicular stops
  tbl <- load_coverage_data(state, city) %>%
    filter(
      # TODO: total
      veh_or_ped == "vehicular"
      # NOTE: filter only for paper
      year(date) >= 2011,
      year(date) <= 2017
    )

  date_range = range(tbl$date, na.rm = TRUE)
  c(
    list(
      state = state,
      city = city,
      nrows = nrow(tbl),
      population = if (city != "Statewide") opp_population(state, city) else NA,
      start_date = date_range[1],
      end_date = date_range[2]
    ),
    bind_cols(
      select(tbl, -contraband_found) %>% summarize_all(coverage_rate),
      select(tbl, search_conducted, contraband_found) %>%
        filter(search_conducted) %>%
        summarize(contraband_found = coverage_rate(contraband_found))
    )
  )
}


load_coverage_data <- function(state, city) {
  tbl <- opp_load_clean_data(state, city)

  coverage <- select_or_add_as_na(
    tbl,
    c(
      "date",
      "time",
      "lat",
      "lng",
      "subject_race",
      "subject_sex",
      "type",
      "warning_issued",
      "citation_issued",
      "arrest_made",
      "contraband_found",
      "frisk_performed",
      "search_conducted",
      "speed"
    )
  ) %>%
  rename(
    veh_or_ped = type
  ) %>%
  mutate(
    geolocation = !is.na(lat) & !is.na(lng)
  ) %>%
  select(
    -lat,
    -lng
  )

  vehicle_desc <- select_least_na(
    tbl,
    c(
      "vehicle_color",
      "vehicle_make",
      "vehicle_model",
      "vehicle_type"
    ),
    rename = "vehicle_desc"
  )

  subject_age <- select_least_na(
    tbl,
    c(
      "subject_age",
      "subject_dob",
      "subject_yob"
    ),
    rename = "subject_age"
  )

  violation_desc <- select_least_na(
    tbl,
    c(
      "disposition",
      "violation"
    ),
    rename = "violation_desc"
  )

  geodivision <- select_least_na(
    tbl,
    c(
      "beat",
      "district",
      "subdistrict",
      "division",
      "subdivision",
      "police_grid_number",
      "precinct",
      "region",
      "reporting_area",
      "sector",
      "subsector",
      "service_area",
      "zone",
      # NOTE: this is the only one that isn't police related
      "county_name"
    ),
    rename = "geodivision"
  )

  bind_cols(
    coverage,
    vehicle_desc,
    subject_age,
    violation_desc,
    geodivision
  )
}
