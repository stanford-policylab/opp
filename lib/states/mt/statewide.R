source("common.R")


load_raw <- function(raw_data_dir, n_max) {
  d <- load_regex(raw_data_dir, "\\.csv$", n_max = n_max)
  bundle_raw(d$data, d$loading_problems)
}


clean <- function(d, helpers) {
  loc <- locale(tz="America/Denver")

  tr_race <- c(
    A = "asian/pacific islander",
    B = "black",
    I = "other/unknown",
    U = "other/unknown",
    W = "white"
  )

  search_not_conducted <- c(
    "NO SEARCH REQUESTED",
    "NO SEARCH / CONSENT DENIED",
    NA_character_
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
      local_datetime = parse_character(parse_datetime(StopTime, locale=loc)),
      date = as.Date(parse_datetime(local_datetime)),
      time = parse_time(local_datetime, format="%Y-%m-%d %H:%M:%S"),
      location = str_c_na(Location, City, sep=", "),
      subject_race = if_else(
        Ethnicity == "H",
        "hispanic",
        fast_tr(Race, tr_race)
      ),
      subject_sex = fast_tr(Sex, tr_sex),
      department_name = "Montana Highway Patrol",
      # TODO(walterk): Verify whether all stops are vehicular.
      # https://app.asana.com/0/456927885748233/748076854773119
      type = "vehicular",
      violation = str_c_na(Violation1, Violation2, Violation3, sep=";"),
      multi_outcome = str_c_na(
        EnforcementAction1,
        EnforcementAction2,
        EnforcementAction3,
        sep=";"
      ),
      arrest_made = str_detect(multi_outcome, "ARREST"),
      citation_issued = str_detect(multi_outcome, "CITATION"),
      warning_issued = str_detect(multi_outcome, "WARNING"),
      outcome = first_of(
        "arrest" = arrest_made,
        "citation" = citation_issued,
        "warning" = warning_issued
      ),
      search_conducted = !(SearchType %in% search_not_conducted),
      search_basis = if_else(
        search_conducted,
        fast_tr(SearchType, tr_search_basis),
        NA_character_
      )
    ) %>%
    standardize(d$metadata)
}
