source("common.R")


load_raw <- function(raw_data_dir, n_max) {
  d <- load_all_csvs(raw_data_dir, n_max = n_max)
  # NOTE: Even though StopTime has the Z timezone indicating UTC, the timestamps
  # are actually in local time America/Denver. So we strip the Z because it is
  # technically incorrect.
  d$data <- d$data %>%
    mutate(
      StopTime = str_replace(StopTime, 'Z$', '')
    )
  bundle_raw(d$data, d$loading_problems)
}


clean <- function(d, helpers) {
  tr_race <- c(
    A = "asian/pacific islander",
    B = "black",
    I = "other/unknown",
    U = "other/unknown",
    W = "white"
  )

  # TODO(walterk): Verify that these search bases are mapped correctly.
  # https://app.asana.com/0/456927885748233/748076854773116
  tr_search_basis <- c(
    "CONSENT SEARCH CONDUCTED" = "consent",
    "INVENTORY" = "other",
    "PLAIN VIEW" = "plain view",
    "PROBABLE CAUSE" = "probable cause",
    "PROBATION/PAROLE OFFICER CONSENT" = "other",
    "SEARCH INCIDENT TO ARREST" = "other",
    "SEARCH WARRANT" = "other",
    "STOP AND FRISK (OFFICER SAFETY) (S.901.151, F.S.)" = "other"
  )

  # NOTE: Replacing "NULL" with NA everywhere.
  d$data[d$data == "NULL"] <- NA

  d$data %>%
    rename(
      lat = Latitude,
      lng = Longitude,
      county_name = County,
      subject_age = Age,
      reason_for_stop = ReasonForStop,
      vehicle_make = VehicleMake,
      vehicle_model = VehicleModel,
      vehicle_type = VehicleStyle,
      vehicle_registration_state = VehicleTagNoState,
      vehicle_year = VehicleYear
    ) %>%
    mutate(
      date = parse_date(StopTime, format = "%Y-%m-%dT%H:%M:%S"),
      time = parse_time(StopTime, format = "%Y-%m-%dT%H:%M:%S"),
      location = str_c_na(Location, City, sep=", "),
      subject_race = if_else(
        Ethnicity == "H",
        "hispanic",
        fast_tr(Race, tr_race)
      ),
      subject_sex = fast_tr(Sex, tr_sex),
      # NOTE: The public records request for the data received in Feb 2017 were
      # vehicular stops by the Montana Highway Patrol.
      department_name = "Montana Highway Patrol",
      type = "vehicular",
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
      citation_issued = str_detect(multi_outcome, "CITATION"),
      warning_issued = str_detect(multi_outcome, "WARNING"),
      outcome = first_of(
        "arrest" = arrest_made,
        "citation" = citation_issued,
        "warning" = warning_issued
      ),
      search_conducted = !(SearchType %in% c(
        "NO SEARCH REQUESTED",
        "NO SEARCH / CONSENT DENIED"
      )),
      search_basis = fast_tr(SearchType, tr_search_basis)
    ) %>%
    standardize(d$metadata)
}
