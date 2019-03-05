library(here)
library(lubridate)
source(here::here("lib", "opp.R"))
source(here::here("lib", "analysis_common.R"))
source(here::here("lib", "standards.R"))


coverage_for_paper <- function(use_cache = T) {
  coverage(
    locations_used_in_analyses(),
    start_year = 2011,
    end_year = 2017,
    use_cache = use_cache,
    cache_path = here::here("cache", "paper_coverage.rds")
  ) %>%
  mutate(
    order = if_else(city == "Statewide", 1, 0),
    city = if_else(city == "Statewide", "--", city),
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
    subgeography,
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
    Subgeography = subgeography,
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
  ) %>%
  mutate_if(
    function(v) all(is.numeric(v) & v <= 1.0, na.rm = T),
    # NOTE: put dot if coverage above 70%
    function(v) if_else(v < 0.7 | is.na(v), "", "dot")
  )
}


coverage_for_website <- function(use_cache = T) {
  coverage(
    use_cache = use_cache,
    cache_path = here::here("cache", "website_coverage.rds")
  ) %>%
  left_join(
    opp_apply(
      function(state, city) {
        tibble(
          state = state,
          city = city,
          shapefiles = has_files(opp_shapefiles_dir(state, city))
        )
      }
    )
  )
}


coverage <- function(
  locations = opp_available(),
  start_year = 2000,
  end_year = year(Sys.Date()),
  use_cache = T,
  cache_path = here::here("cache", "coverage.rds")
) {
  if (use_cache & !is.null(cache_path) & file.exists(cache_path))
    return(inner_join(readRDS(cache_path)))

  cvg <-
    opp_apply(
      function(state, city) {
        calculate_coverage(state, city, start_year, end_year)
      },
      locations
    ) %>%
    bind_rows()

  saveRDS(cvg, cache_path)
  cvg
}


calculate_coverage <- function(
  state,
  city,
  start_year = 2011,
  end_year = 2017
) {
  # NOTE: for coverage we filter to vehicular stops
  tbl <-
    load_coverage_data(state, city) %>%
    filter(
      veh_or_ped == "vehicular",
      year(date) >= start_year,
      year(date) <= end_year
    )

  date_range = range(tbl$date, na.rm = TRUE)
  c(
    list(
      state = state,
      city = city,
      nrows = nrow(tbl),
      population = if (city != "Statewide") opp_city_population(state, city) else NA,
      start_date = date_range[1],
      end_date = date_range[2]
    ),
    predicated_coverage_rates(tbl, reporting_predicated_columns) %>%
      spread(feature, `coverage rate`)
  )
}


load_coverage_data <- function(state, city) {
  tbl <-
    opp_load_clean_data(state, city) %>%
    mutate(state = state, city = city) %>%
    filter_out_non_highway_patrol_stops_from_states() %>%
    select(-state, -city)

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


  subgeography <- select_least_na(
    tbl,
    if (city == "Statewide")
      quos_names(state_subgeographies)
    else
      quos_names(city_subgeographies),
    rename = "subgeography"
  )

  bind_cols(
    coverage,
    vehicle_desc,
    subject_age,
    violation_desc,
    subgeography
  )
}
