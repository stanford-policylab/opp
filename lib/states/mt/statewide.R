source(here::here("lib", "common.R"))


load_raw <- function(raw_data_dir, n_max) {
  d <- load_all_csvs(raw_data_dir, n_max = n_max)
  # NOTE: Even though StopTime has the Z timezone indicating UTC, the timestamps
  # are actually in local time America/Denver. So we strip the Z because it is
  # technically incorrect.
  d$data <- mutate(
    d$data,
    StopTime = str_replace(StopTime, 'Z$', '')
  )
  bundle_raw(d$data, d$loading_problems)
}


clean <- function(d, helpers) {
  tr_race <- c(
    A = "asian/pacific islander",
    B = "black",
    I = "other",
    U = "unknown",
    W = "white"
  )

  tr_search_basis <- c(
    "CONSENT SEARCH CONDUCTED" = "consent",
    "INVENTORY" = "other",
    "PLAIN VIEW" = "plain view",
    "PROBABLE CAUSE" = "probable cause",
    "PROBATION/PAROLE OFFICER CONSENT" = "other",
    "SEARCH INCIDENT TO ARREST" = "other",
    "SEARCH WARRANT" = "other",
    # NOTE: we mark this as NA because we categorize protective frisks as
    # separate from searches, and assume they have RAS (or consent) as the basis
    "STOP AND FRISK (OFFICER SAFETY) (S.901.151, F.S.)" = NA_character_
  )

  # NOTE: Replacing "NULL" with NA everywhere.
  d$data[d$data == "NULL"] <- NA

  d$data %>%
    merge_rows(
      StopTime, 
      LinkedNumber, 
      Location, 
      City,
      County, 
      Age, 
      Sex, 
      Race
    ) %>%
    add_raw_colname_prefix(
      Ethnicity,
      Race,
      SearchType
    ) %>% 
    rename(
      lat = Latitude,
      lng = Longitude,
      subject_age = Age,
      vehicle_make = VehicleMake,
      vehicle_model = VehicleModel,
      vehicle_type = VehicleStyle,
      vehicle_registration_state = VehicleTagNoState,
      vehicle_year = VehicleYear
    ) %>%
    mutate(
      # remove dashed characters
      reason_for_stop = str_replace_all(ReasonForStop, "--- - ",""),
      date = coalesce(
        parse_date(StopTime, format = "%Y/%m/%d %H:%M:%S"),
        parse_date(StopTime, format = "%Y-%m-%dT%H:%M:%S")
      ), 
      time = coalesce(
        parse_time(StopTime, format = "%Y/%m/%d %H:%M:%S"),
        parse_time(StopTime, format = "%Y-%m-%dT%H:%M:%S")
      ),
      location = str_c_na(Location, City, sep=", "),
      county_name = str_c(str_to_title(County), " County"),
      subject_race = if_else(
        raw_Ethnicity == "H",
        "hispanic",
        fast_tr(raw_Race, tr_race)
      ),
      subject_sex = fast_tr(Sex, tr_sex),
      # NOTE: The public records request for the data received in Feb 2017 were
      # vehicular stops by the Montana Highway Patrol.
      department_name = "Montana Highway Patrol",
      type = if_else(reason_for_stop == "PEDESTRIAN", "pedestrian", "vehicular"),
      violation = str_c_na(
        Violation1,
        Violation2,
        Violation3,
        sep = "|"
      ),
      multi_outcome = str_c_na(
        EnforcementAction1,
        EnforcementAction2,
        EnforcementAction3,
        sep = "|"
      ),
      arrest_made = str_detect(multi_outcome, "ARREST"),
      citation_issued = str_detect(multi_outcome, "CITATION|NOTICE"),
      warning_issued = str_detect(multi_outcome, "WARNING"),
      outcome = first_of(
        "arrest" = arrest_made,
        "citation" = citation_issued,
        "warning" = warning_issued
      ),
      frisk_performed = str_detect(raw_SearchType, "FRISK"),
      search_conducted = !(raw_SearchType %in% c(
        "NO SEARCH REQUESTED",
        "NO SEARCH / CONSENT DENIED"
      )),
      search_basis = fast_tr(raw_SearchType, tr_search_basis),
      raw_search_basis = str_c_na(
        SearchRationale1,
        SearchRationale2,
        SearchRationale3,
        SearchRationale4,
        sep = "|"
      )
    ) %>%
    standardize(d$metadata)
}
