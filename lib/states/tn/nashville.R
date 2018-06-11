source("common.R")

load_raw <- function(raw_data_dir, n_max) {
  data <- tibble()
  loading_problems <- list()
  for (year in 2010:2016) {
    fname <- str_c("traffic_stop_", year, ".csv")
    tbl <- read_csv_with_types(
      file.path(raw_data_dir, fname),
      c(
        stop_number                     = "n",
        stop_datetime                   = "c",
        related_incident_number         = "c",
        stop_location                   = "c",
        officer_employee_number         = "i",
        stop_type                       = "c",
        race                            = "c",
        sex                             = "c",
        county_resident                 = "c",
        vehicle_tag_state               = "c",
        verbal_warning_issued           = "c",
        written_warning_issued          = "c",
        traffic_citation_issued         = "c",
        misd_state_citation_issued      = "c",
        custodial_arrest_issued         = "c",
        officers_comments               = "c",
        age_of_suspect                  = "d",
        related_mov_vio_number          = "c",
        zone                            = "c",
        vehicle_tag_number              = "c",
        crime_reduction_initiative      = "c",
        reporting_area                  = "c",
        suspect_ethnicity               = "c",
        action_against_driver           = "c",
        action_against_passenger        = "c",
        search_occurred                 = "c",
        evidence_seized                 = "c",
        drugs_seized                    = "c",
        weapons_seized                  = "c",
        other_seized                    = "c",
        vehicle_searched                = "c",
        pat_down_search                 = "c",
        driver_searched                 = "c",
        passenger_searched              = "c",
        search_consent                  = "c",
        search_probable_cause           = "c",
        search_arrest                   = "c",
        search_warrant                  = "c",
        search_inventory                = "c",
        search_plain_view               = "c",
        id                              = "i"
      )
    )
    data <- bind_rows(data, tbl)
    loading_problems[[fname]] <- problems(tbl)
    if (nrow(data) > n_max) {
      data <- data[1:n_max, ]
      break
    }
  }
  bundle_raw(data, loading_problems)
}


clean <- function(d, helpers) {
  tr_race <- c(
    A = "asian/pacific islander",
    B = "black",
    H = "hispanic",
    I = "other/unknown",
    O = "other/unknown",
    U = "other/unknown",
    W = "white"
  )
  tr_stop_type <- c(
    "CR" = "child restraint",
    "INV" = "investigative stop",
    "MTV" = "moving traffic violation",
    "PARK" = "parking violation",
    "REGS" = "regulatory violation",
    "S/BELT" = "seatbelt violation",
    "SAFETY" = "safety violation",
    "VEV" = "vehicle equipment violation"
  )

  d$data %>%
    merge_rows(
      stop_number
    ) %>%
    rename(
      incident_location = stop_location,
      beat = zone,
      frisk_performed = pat_down_search,
      subject_race = race,
      arrest_made = custodial_arrest_issued,
      subject_sex = sex,
      subject_age = age_of_suspect,
      officer_id = officer_employee_number,
      vehicle_registration_state = vehicle_tag_state,
      search_conducted = search_occurred,
      search_vehicle = vehicle_searched,
      search_incident_to_arrest = search_arrest
    ) %>%
    helpers$add_lat_lng(
    ) %>%
    separate_cols(
      stop_datetime = c("incident_date", "incident_time")
    ) %>%
    apply_translator_to(
      tr_yn,
      "verbal_warning_issued",
      "written_warning_issued",
      "traffic_citation_issued",
      "misd_state_citation_issued",
      "arrest_made",
      "search_conducted",
      "evidence_seized",
      "drugs_seized",
      "weapons_seized",
      "other_seized",
      "frisk_performed",
      "driver_searched",
      "passenger_searched",
      "search_vehicle",
      "search_consent",
      "search_probable_cause",
      "search_incident_to_arrest",
      "search_warrant",
      "search_inventory",
      "search_plain_view"
    ) %>%
    mutate(
      incident_type = "vehicular",
      incident_date = parse_date(incident_date, "%m/%d/%Y"),
      incident_time = parse_time(incident_time, "%I:%M:%S %p"),
      citation_issued = traffic_citation_issued | misd_state_citation_issued,
      warning_issued = verbal_warning_issued | written_warning_issued,
      incident_outcome = first_of(
        arrest = arrest_made,
        citation = citation_issued,
        warning = warning_issued
      ),
      reason_for_stop = tr_stop_type[stop_type],
      search_person = driver_searched | passenger_searched,
      subject_race = tr_race[ifelse(
        !is.na(suspect_ethnicity)
          & (suspect_ethnicity == "H" | suspect_ethnicity == "LATINO"),
        "H",
        subject_race
      )],
      subject_sex = tr_sex[subject_sex],
      search_type = first_of(
        "plain view" = search_plain_view,
        "consent" = search_consent,
        "non-discretionary" = (
          search_incident_to_arrest
          | search_warrant
          | search_inventory
        ),
        "probable cause" = (
          search_person
          | search_vehicle
          | search_probable_cause
          | search_conducted  # default
        )
      ),
      contraband_found = (
        evidence_seized
        | drugs_seized
        | weapons_seized
        | other_seized
      ),
      contraband_drugs = drugs_seized,
      contraband_weapons = weapons_seized,
      notes = officers_comments
    ) %>%
    standardize(d$metadata)
}
