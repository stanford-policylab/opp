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

  tr_stop_type <- c(
    "CR" = "child restraint",
    "INV" = "investigative stop",
    "MTV" = "moving traffic violation",
    "PARK" = "parking violation",
    "REGS" = "registration",
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
    search_vehicle = vehicle_searched,
    subject_age = age_of_suspect,
    vehicle_registration_state = vehicle_tag_state,
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
    "search_arrest",
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
    # NOTE: all the files are traffic_stop_* and the stop reasons are vehicle
    # related
    type = "vehicular",
    date = coalesce(
      parse_date(date, "%m/%d/%Y"),
      parse_date(date, "%Y/%m/%d")
    ),
    time = coalesce(
      parse_time(time, "%I:%M:%S %p"),
      parse_time(time, "%H:%M:%S")
    ),
    citation_issued =
      traffic_citation_issued
      # NOTE: misd_state_citation_issued is NA sometimes, assume this is false
      | replace_na(misd_state_citation_issued, F),
    warning_issued =
      verbal_warning_issued
      | replace_na(written_warning_issued, F),
    outcome = first_of(
      arrest = arrest_made,
      citation = citation_issued,
      warning = warning_issued
    ),
    reason_for_stop = tr_stop_type[stop_type],
    # NOTE: sometimes the stop_type is pretextual, other times it is a
    # violation, but it isn't always what the subject was ultimately cited for
    violation = reason_for_stop,
    contraband_found = replace_na(contraband_found, F),
    search_person = driver_searched | passenger_searched,
    subject_race = tr_race[if_else_na(
      (suspect_ethnicity == "H" | suspect_ethnicity == "LATINO"),
      "H",
      race
    )],
    subject_sex = tr_sex[sex],
    search_basis = first_of(
      "plain view" = search_plain_view,
      "consent" = search_consent,
      "other" = 
        search_arrest
        | search_warrant
        | search_inventory,
      "probable cause" = search_conducted # default
    ),
    precinct = substr(zone, 1, 1)
  ) %>%
  add_raw_colname_prefix(
    traffic_citation_issued,
    misd_state_citation_issued,
    verbal_warning_issued,
    written_warning_issued,
    driver_searched,
    passenger_searched,
    suspect_ethnicity,
    suspect_race,
    search_plain_view,
    search_consent,
    search_arrest,
    search_warrant,
    search_inventory
  ) %>%
  standardize(d$metadata)
}
