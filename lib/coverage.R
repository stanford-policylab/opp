library(here)
source(here::here("lib", "opp.R"))


coverage <- function(use_cache = TRUE) {
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
  tbl <- load_coverage_data(state, city)
  date_range = range(tbl$date, na.rm = TRUE)
  c(
    list(
      state = state,
      city = city,
      nrows = nrow(tbl),
      population = opp_population(state, city),
      start_date = date_range[1],
      end_date = date_range[2]
    ),
    lapply(lapply(tbl, coverage_rate), pretty_percent)
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
      "zone"
    ),
    rename = "police_geodivision"
  )

  bind_cols(
    coverage,
    vehicle_desc,
    subject_age,
    violation_desc,
    geodivision
  )
}
