source("common.R")


# VALIDATION: [YELLOW] Only partial data for 2018. The San Antonio PD doesn't
# appear to issue annual reports or traffic statistics. That said, the number
# of stops seems reasonable if not a little low for a state of 1.4M people.
load_raw <- function(raw_data_dir, n_max) {
  # NOTE: The 2018 data from second-wave OPP (Dan and Amy, in 2018 and 2019) is
  # incomplete; we start with the 2018 data gathered by Phoebe in the 2020 data
  # refresh.
  csv_fns <- files_with_recent_year_in_name(raw_data_dir) %>%
    str_subset("/2018_citations", negate = TRUE)
  d <- load_similar_files(csv_fns, n_max = n_max)
  d$data <- make_ergonomic_colnames(d$data)
  bundle_raw(d$data, d$loading_problems)
}


clean <- function(d, helpers) {

  tr_race <- c(
    tr_race,
    # TODO(phoebe): is this Latino?
    # https://app.asana.com/0/456927885748233/661513016681937
    "L" = "other",
    # TODO(phoebe): what is this?
    # https://app.asana.com/0/456927885748233/661513016681937
    "M" = "other",
    "X" = "other",
    "0" = "other",
    "1" = "other",
    "9" = "other"
  )

  tr_search_basis <- c(
    "Consent" = "consent",
    "Incident to Arrest" = "other",
    "Towing Inventory" = "other",
    "Probable Cause" = "probable cause",
    "Evidence" = "probable cause"
  )

  speeds <-
    d$data %>%
    group_by(citation_number) %>%
    summarize(
      max_speed = max(as.integer(actual_speed), na.rm = T),
      max_posted_speed = max(as.integer(actual_speed), na.rm = T)
    )

  d$data %>%
    mutate(
      custodial_arrest_made = coalesce(custodial_arrest_made,
                                       custodia_larrest_made)
    ) %>%
    helpers$add_type(
      "offense"
    ) %>%
    merge_rows(
      # NOTE: One citation number gets recycled between 2012 and 2018.
      citation_number, year(violation_date)
    ) %>%
    left_join(
      speeds
    ) %>%
    rename(
      date = violation_date,
      time = violation_time,
      location = violation_location,
      subject_age = age_at_time_of_violation,
      vehicle_registration_state = license_plate_state,
      raw_search_reason = search_reason,
      raw_actual_speed = actual_speed,
      raw_posted_speed = posted_speed,
      speed = max_speed,
      posted_speed = max_posted_speed,
      violation = offense
    ) %>%
    mutate(
      subject_race = tr_race[race],
      subject_sex = tr_sex[gender],
      search_conducted = str_detect_na(
        raw_search_reason,
        str_c(names(tr_search_basis), collapse = "|")
      ),
      search_basis = tr_search_basis[raw_search_reason],
      contraband_found = replace_na(tr_yn[contraband_or_evidence], F),
      arrest_made = replace_na(tr_yn[custodial_arrest_made], F),
      citation_issued = !is.na(citation_number),
      # NOTE: warnings are not recorded
      outcome = first_of(
        "arrest" = arrest_made,
        "citation" = citation_issued
      ),
      # NOTE: 0 in vehicle year seems to indicate not recorded rather than 2000;
      # this is set to NA in standardization
    ) %>%
    helpers$add_lat_lng(
    ) %>%
    helpers$add_shapefiles_data(
    ) %>%
    rename(
      district = DISTRICT,
      # NOTE: SUBCODE is just the first letter of SUBSTN
      substation = SUBSTN.x,
    ) %>%
    add_raw_colname_prefix(
      race,
      search_reason,
      contraband_or_evidence,
      custodial_arrest_made
    ) %>%
    standardize(d$metadata)
}
