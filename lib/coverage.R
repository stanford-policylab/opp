library(here)
source(here::here("lib", "opp.R"))


coverage_for_paper <- function() {
  target_years <- 2011:2017
  target_threshold <- 0.65
  target_races <- c("black", "white", "hispanic")
  # target_columns <- c("date", "time", "subject_race")
  coverage(
    # opp_analysis_eligible_locations(
    #   years = target_years,
    #   threshold = target_threshold,
    #   columns = target_columns
    # ),
    opp_locations_used_in_analyses(),
    years = target_years,
    races = target_races,
    vehicular_only = T,
    exclude_non_highway_patrol_from_states = T,
    only_analysis_demographics = T
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
    function(v) if_else(v < target_threshold | is.na(v), "", "dot")
  ) %>%
  mutate(
    # NOTE: contraband_found data from AZ and MA is messy and unreliable
    `Contraband Found` = if_else(
      State %in% c("AZ", "MA") & City == "--",
      "",
      `Contraband Found`
    )
  )

}


coverage_for_website <- function() {
  left_join(
    coverage(),
    opp_apply(
      function(state, city) {
        tibble(
          state = state,
          city = city,
          shapefiles = has_files(opp_shapefiles_dir(state, city))
        )
      }
    ) %>% bind_rows()
  ) %>%
  mutate(
    state_with_local_data = city == "Statewide" & state %in% c(
      "CT",
      "IL",
      "MD",
      "MO",
      "MS",
      "NC"
    )
  )
  # TODO(danj): add pedestrian column
}


coverage <- function(
  locations = opp_available(),
  years = 2000:year(Sys.Date()),
  races = c("asian/pacific islander", "black", "hispanic", "other", "white"),
  vehicular_only = F,
  exclude_non_highway_patrol_from_states = F,
  only_analysis_demographics = F
) {
  opp_apply(
    function(state, city) {
      calculate_coverage(
        state,
        city,
        years,
        races,
        vehicular_only,
        exclude_non_highway_patrol_from_states,
        only_analysis_demographics
      )
    },
    locations
  ) %>%
  bind_rows() %>%
  select(
    state,
    city,
    nrows,
    population,
    start_date,
    end_date,
    date,
    time,
    type,
    geolocation,
    subgeography,
    subject_age,
    subject_race,
    subject_sex,
    reason_for_stop,
    warning_issued,
    citation_issued,
    arrest_made,
    violation,
    search_conducted,
    search_basis,
    frisk_performed,
    contraband_found
  )
}


calculate_coverage <- function(
  state,
  city,
  years = 2000:year(Sys.Date()),
  races = c("asian/pacific islander", "black", "hispanic", "other", "white"),
  vehicular_only = F,
  exclude_non_highway_patrol_from_states = F,
  only_analysis_demographics = F
) {
  # NOTE: for coverage we filter to vehicular stops
  tbl <- load_coverage_data(
    state,
    city,
    years,
    races,
    vehicular_only,
    exclude_non_highway_patrol_from_states,
    only_analysis_demographics
  )
  date_range = range(tbl$date, na.rm = TRUE)
  if (city == "Statewide")
    population <- opp_state_population(state)
  else
    population <- opp_city_population(state, city)
  c(
    list(
      state = state,
      city = city,
      nrows = nrow(tbl),
      population = population,
      start_date = date_range[1],
      end_date = date_range[2]
    ),
    predicated_coverage_rates(tbl, reporting_predicated_columns) %>%
      spread(feature, `coverage rate`)
  )
}


load_coverage_data <- function(
  state,
  city,
  years = 2000:year(Sys.Date()),
  races = c("asian/pacific islander", "black", "hispanic", "other", "white"),
  vehicular_only = F,
  exclude_non_highway_patrol_from_states = F,
  only_analysis_demographics = F
) {
  tbl <-
    opp_load_clean_data(state, city) %>%
    filter(
      year(date) %in% years,
      subject_race %in% races
    ) 

  if (vehicular_only)
    tbl <- filter(tbl, type == "vehicular")

  if (exclude_non_highway_patrol_from_states)
    tbl <-
      mutate(tbl, state = state, city = city) %>%
      opp_filter_out_non_highway_patrol_stops_from_states() %>%
      select(-state, -city)

  if (only_analysis_demographics)
    tbl <- filter(tbl, subject_race %in% c("black", "white", "hispanic"))

  base <- select_or_add_as_na(
    tbl,
    c(
      "date",
      "time",
      "lat",
      "lng",
      "subject_age",
      "subject_race",
      "subject_sex",
      "type",
      "reason_for_stop",
      "warning_issued",
      "citation_issued",
      "arrest_made",
      "violation",
      "contraband_found",
      "frisk_performed",
      "search_conducted",
      "search_basis"
    )
  ) %>%
  mutate(
    geolocation = !is.na(lat) & !is.na(lng)
  ) %>%
  select(
    -lat,
    -lng
  )

  subgeography <- select_least_na(
    tbl,
    if (city == "Statewide")
      quos_names(state_subgeographies)
    else
      quos_names(city_subgeographies),
    rename = "subgeography"
  )

  bind_cols(base, subgeography)
}
