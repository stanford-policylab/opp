source("common.R")


# VALIDATION: [GREEN] The Nashville PD's Annual Report only lists violent and
# property crime statistics, but this lab did an in-depth study here that
# aligns well with the public data received here:
# https://policylab.stanford.edu/projects/nashville-traffic-stops.html
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
      stop_date_time,
      stop_location_street,
      officer_employee_number,
      race,
      sex,
      age_of_suspect
    ) %>%
    rename(
      arrest_made = custodial_arrest_issued,
      contraband_drugs = drugs_seized,
      contraband_found = evidenceseized,
      contraband_weapons = weapons_seized,
      frisk_performed = pat_down_search,
      location = stop_location_street,
      notes = officers_comments,
      officer_id = officer_employee_number,
      search_conducted = searchoccur,
      search_incident_to_arrest = search_arrest,
      search_vehicle = vehicle_searched,
      subject_age = age_of_suspect,
      subject_race = race,
      subject_sex = sex,
      vehicle_registration_state = vehicle_tag_state
    ) %>%
    helpers$add_lat_lng(
    ) %>%
    separate_cols(
      stop_date_time = c("date", "time")
    ) %>%
    apply_translator_to(
      tr_yn,
      "arrest_made",
      "contraband_drugs",
      "contraband_found",
      "contraband_weapons",
      "driver_searched",
      "frisk_performed",
      "misd_state_citation_issued",
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
      "written_warning_issued"
    ) %>%
    mutate(
      # NOTE: all the files are traffic_stop_* and the violations are vehicle
      # related
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
      violation = tr_stop_type[stop_type],
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
      precinct = substr(zone, 1, 1)
    ) %>%
    standardize(d$metadata)
}
