source("common.R")

load_raw <- function(raw_data_dir, n_max) {
  d <- load_years(raw_data_dir, n_max = n_max)
  colnames(d$data) <- make_ergonomic(colnames(d$data))
  bundle_raw(d$data, d$loading_problems)
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
      location = stop_location_street,
      frisk_performed = pat_down_search,
      subject_race = race,
      arrest_made = custodial_arrest_issued,
      subject_sex = sex,
      subject_age = age_of_suspect,
      officer_id = officer_employee_number,
      vehicle_registration_state = vehicle_tag_state,
      search_conducted = searchoccur,
      search_vehicle = vehicle_searched,
      search_incident_to_arrest = search_arrest
    ) %>%
    helpers$add_lat_lng(
    ) %>%
    separate_cols(
      stop_date_time = c("date", "time")
    ) %>%
    apply_translator_to(
      tr_yn,
      "arrest_made",
      "driver_searched",
      "drugs_seized",
      "evidenceseized",
      "frisk_performed",
      "misd_state_citation_issued",
      "other_seized",
      "passenger_searched",
      "search_conducted",
      "search_consent",
      "search_incident_to_arrest",
      "search_inventory",
      "search_plain_view",
      "search_probable_cause",
      "search_vehicle",
      "search_warrant",
      "traffic_citation_issued",
      "verbal_warning_issued",
      "weapons_seized",
      "written_warning_issued"
    ) %>%
    mutate(
      type = "vehicular",
      date = parse_date(date, "%m/%d/%Y"),
      time = parse_time(time, "%I:%M:%S %p"),
      citation_issued = traffic_citation_issued | misd_state_citation_issued,
      warning_issued = verbal_warning_issued | written_warning_issued,
      outcome = first_of(
        arrest = arrest_made,
        citation = citation_issued,
        warning = warning_issued
      ),
      reason_for_stop = tr_stop_type[stop_type],
      search_person = driver_searched | passenger_searched,
      subject_race = tr_race[if_else_na(
        (suspect_ethnicity == "H" | suspect_ethnicity == "LATINO"),
        "H",
        subject_race
      )],
      subject_sex = tr_sex[subject_sex],
      search_basis = first_of(
        "plain view" = search_plain_view,
        "consent" = search_consent,
        "other" = (
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
      contraband_drugs = drugs_seized,
      contraband_weapons = weapons_seized,
      contraband_found = contraband_drugs | contraband_weapons,
      notes = officers_comments
    ) %>%
    standardize(d$metadata)
}
