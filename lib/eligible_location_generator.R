source("opp.R")

coverage <- function(
  locations = opp_available(),
  years = 2000:year(Sys.Date()),
  vehicular_only = T,
  exclude_non_highway_patrol_from_states = T,
  only_analysis_demographics = T,
  cast_unk_race_to_na = T
) {
  d <- opp_apply(
    function(state, city) {
      calculate_coverage(
        state,
        city,
        years,
        vehicular_only,
        exclude_non_highway_patrol_from_states,
        only_analysis_demographics,
        cast_unk_race_to_na
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
    race_na,
    race_hispanic,
    subject_sex,
    reason_for_stop,
    warning_issued,
    citation_issued,
    arrest_made,
    outcome,
    p_citations,
    p_warnings,
    p_arrests,
    universe,
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
  vehicular_only = F,
  exclude_non_highway_patrol_from_states = F,
  only_analysis_demographics = F,
  cast_unk_race_to_na = F
) {
  tbl <- load_coverage_data(
    state,
    city,
    years,
    vehicular_only,
    exclude_non_highway_patrol_from_states,
    only_analysis_demographics,
    cast_unk_race_to_na
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
      end_date = date_range[2],
      race_na = mean(is.na(tbl$subject_race)),
      race_hispanic = mean(tbl$subject_race == "hispanic", na.rm = T),
      p_citations = mean(tbl$outcome == "citation", na.rm = T),
      p_warnings = mean(tbl$outcome == "warning", na.rm = T),
      p_arrests = mean(tbl$outcome == "arrest", na.rm = T),
      # NOTE: this will be incorrect if the location has only arrests, for ex;
      # This happens in Philly, and we manually correct to NA (looking at
      # the above columns in conjunction with the below column help distinguish)
      universe = mean(tbl$outcome == "warning", na.rm = T) > 0
    ),
    predicated_coverage_rates(tbl, reporting_predicated_columns) %>%
      spread(feature, `coverage rate`)
  )
}


load_coverage_data <- function(
  state,
  city,
  years = 2000:year(Sys.Date()),
  vehicular_only = F,
  exclude_non_highway_patrol_from_states = F,
  only_analysis_demographics = F,
  cast_unk_race_to_na = F
) {
  tbl <-
    opp_load_clean_data(state, city) %>%
    filter(year(date) %in% years)
  
  if (vehicular_only)
    tbl <- filter(tbl, type == "vehicular")
  
  if (exclude_non_highway_patrol_from_states)
    tbl <-
      mutate(tbl, state = state, city = city) %>%
      opp_filter_out_non_highway_patrol_stops_from_states() %>%
      select(-state, -city)
    
    if (cast_unk_race_to_na)
      if ("subject_race" %in% colnames(tbl)) {
        tbl <- tbl %>% 
          mutate(subject_race = if_else(
            subject_race == "other/unknown" | subject_race == "unknown", 
            NA_character_,
            as.character.factor(subject_race))
          )
      }
  
    if (only_analysis_demographics)
      if ("subject_race" %in% colnames(tbl))
        tbl <- tbl %>% 
          filter(subject_race %in% c("black", "white", "hispanic", NA))
    
    if (nrow(tbl) == 0)
      return(tbl)
    
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
        "outcome",
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


