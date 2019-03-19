source("common.R")


# VALIDATION: [GREEN] The Burlington PD's 2017 Annual Report lists figures that
# are very close to those in the data; the discrepancy is likely due to the
# exclusion of warrants and other small filters.
load_raw <- function(raw_data_dir, n_max) {
  # NOTE: calls/incidents are also in the raw data, but aren't loaded here
  d <- load_single_file(raw_data_dir, "TrafficTicketsWarnings12_17.csv", n_max)
  colnames(d$data) <- make_ergonomic(colnames(d$data))
  bundle_raw(d$data, d$loading_problems)
}


clean <- function(d, helpers) {

  tr_race <- c(
    tr_race,
    "nat.amer" = "other/unknown"
  )

  tr_sex <- c(
    "Male - M" = "male",
    "Female - F" = "female"
  )

  d$data %>%
    # NOTE: while not included here, violation_group provides a simpler
    # grouping of specific violations
    merge_rows(
      issued_at,
      location,
      race,
      gender,
      city,
      dob,
      lat,
      lon
    ) %>%
    rename(
      department_name = ori,
      vehicle_registration_state = license_state,
      reason_for_stop = stop_based_on,
      reason_for_search = search_based_on,
      subject_age = age,
      lng = lon
    ) %>%
    mutate(
      # NOTE: all violations appear to be vehicle related
      type = "vehicular",
      datetime = parse_datetime(issued_at, "%m/%d/%Y %H:%M"),
      date = as.Date(datetime),
      time = format(datetime, "%H:%M"),
      subject_race = tr_race[tolower(race)],
      subject_sex = tr_sex[gender],
      subject_dob = parse_date(dob, "%m/%d/%Y"),
      subject_age = age_at_date(subject_dob, date),
      search_conducted = !str_detect(reason_for_search, "NS"),
      search_basis = first_of(
        "other" = str_detect(reason_for_search, "with warrant"),
        "probable cause" = search_conducted
      ),
      contraband_found = str_detect(contraband_evidence, "C = Contraband"),
      warning_issued = str_detect(outcome_of_stop, "W = Warning"),
      citation_issued = str_detect(outcome_of_stop, "T = Ticket"),
      arrest_made = str_detect(outcome_of_stop, "^A = |^AW = "),
      outcome = first_of(
        arrest = arrest_made,
        citation = citation_issued,
        warning = warning_issued
      )
    ) %>%
    standardize(d$metadata)
}
