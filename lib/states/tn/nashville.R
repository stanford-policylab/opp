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
      data <- data[1:n_max]
      break
    }
  }
  bundle_raw(data, loading_problems)
}


clean <- function(d) {
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
    rename(
      # TODO(danj): use incident_num not stop_n7um
      incident_id = stop_number,
      incident_location = stop_location,
      subject_race = race,
      search_conducted = search_occurred,
      arrest_made = custodial_arrest_issued,
      citation_issued = traffic_citation_issued | misd_state_citation_issued,
      subject_sex = sex,
      subject_age = age_of_suspect,
      officer_id = officer_employee_number,
      vehicle_registration_state = vehicle_tag_state,
      search_vehicle = vehicle_searched,
      frisk_performed = pat_down_search,
      search_driver = driver_searched,
      search_passenger = passenger_searched,
      search_incident_to_arrest = search_arrest
    ) %>%
    separate_cols(
      stop_datetime = c("incident_date", "incident_time")
    ) %>%
    apply_translator_to(
      yn_to_tf,
      "county_resident",
      "verbal_warning_issued",
      "written_warning_issued",
      "citation_issued",
      "misd_state_citation_issued",
      "arrest_made",
      "action_against_driver",
      "action_against_passenger",
      "search_conducted",
      "evidence_seized",
      "drugs_seized",
      "weapons_seized",
      "other_seized",
      "search_vehicle",
      "frisk_performed",
      "search_driver",
      "search_passenger",
      "search_consent",
      "search_probable_cause",
      "search_incident_to_arrest",
      "search_warrant",
      "search_inventory",
      "search_plain_view"
    ) %>%
    mutate(
      incident_type = "vehicular",
      reason_for_stop = tr_stop_type[stop_type],
      incident_date = parse_date(incident_date, "%m/%d/%Y"),
      incident_time = parse_time(incident_time, "%I:%M:%S %p"),
      incident_outcome = first_of(
        arrest = arrest_made,
        citation = citation_issued,
        warning = verbal_warning_issued | written_warning_issued
      ),
      subject_race =
        tr_race[ifelse(suspect_ethnicity == "H", "H", subject_race)],
      subject_sex = tr_sex[subject_sex],
      contraband_found = (
        evidence_seized
        | drugs_seized
        | weapons_seized
        | other_seized
      ),
      search_type = first_of(
        "plain view" = search_plain_view,
        "consent" = search_consent,
        "probable cause" = (
          search_driver
          | search_passenger
          | search_vehicle
          | search_inventory
          | search_warrant
          | search_probable_cause
        ),
        "incident to arrest" = search_incident_to_arrest
      )
    ) %>%
    standardize(d$metadata)
}
