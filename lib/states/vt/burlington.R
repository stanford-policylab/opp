source("common.R")


# VALIDATION: [GREEN] The Burlington PD's 2017 Annual Report lists figures that
# are very close to those in the data; the discrepancy is likely due to the
# exclusion of warrants and other small filters.
load_raw <- function(raw_data_dir, n_max) {
  # NOTE: calls/incidents are also in the raw data, but aren't loaded here
  old_d <- load_single_file(raw_data_dir, "TrafficTicketsWarnings12_17.csv", n_max)
  old_d$data <- old_d$data %>%
    mutate(source = "old_data")
  colnames(old_d$data) <- make_ergonomic(colnames(old_d$data))
  
  updated_d <- load_single_file(raw_data_dir, "2018-2020_traffic_calls.csv", n_max)
  updated_d$data <- updated_d$data %>%
    mutate(source = "new_data")
  colnames(updated_d$data) <- make_ergonomic(colnames(updated_d$data))
  
  bundle_raw(
    bind_rows(old_d$data, updated_d$data),
    c(old_d$loading_problems,
      updated_d$loading_problems)
  )
}


clean <- function(d, helpers) {
  tr_race <- c( 
    tr_race,
    c("asian - a" = "asian/pacific islander",
      "black - b" = "black",
      "hispanic - do not use" = "hispanic",
      "nat.amer" = "other/unknown",
      "native am/alaska nat - i" = "other/unknown",
      "other - u" = "other/unknown",
      "pacific is - a" = "asian/pacific islander",
      "unknown - u" = "unknown",
      "white - w" = "white"
    )
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
      date_time,
      location,
      race,
      issued_to_race,
      gender,
      issued_to_gender,
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
      lng = lon,
      raw_race = race,
      raw_gender = gender,
      raw_outcome_of_stop = outcome_of_stop,
      raw_contraband_evidence = contraband_evidence
    ) %>%
    mutate(
      raw_race = coalesce(raw_race, issued_to_race),
      raw_gender = coalesce(raw_gender, issued_to_gender),
      violation = coalesce(violation, ticket_violation),
      raw_outcome_of_stop = coalesce(raw_outcome_of_stop, ticket_outcome),
      # NOTE: all violations appear to be vehicle related
      type = "vehicular",
      datetime = if_else(
        source == "old_data",
        parse_datetime(issued_at, "%m/%d/%Y %H:%M"),
        parse_datetime(date_time, "%Y/%m/%d %H:%M:%S")
      ),
      date = as.Date(datetime),
      time = format(datetime, "%H:%M"),
      subject_race = tr_race[str_to_lower(raw_race)], 
      subject_sex = tr_sex[raw_gender],
      subject_dob = parse_date(dob, "%m/%d/%Y"),
      search_conducted = replace_na(
        !str_detect(reason_for_search, "NS"), 
        FALSE
      ),
      search_basis = first_of(
        "other" = str_detect(reason_for_search, "with warrant"),
        "probable cause" = search_conducted
      ),
      contraband_found = str_detect(raw_contraband_evidence, "C = Contraband"),
      warning_issued = str_detect(raw_outcome_of_stop, "W = Warning"),
      citation_issued = str_detect(raw_outcome_of_stop, "T = Ticket"),
      arrest_made = str_detect(raw_outcome_of_stop, "^A = |^AW = "),
      outcome = first_of(
        arrest = arrest_made,
        citation = citation_issued,
        warning = warning_issued
      )
    ) %>%
    standardize(d$metadata)
}
