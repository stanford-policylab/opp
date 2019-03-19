source("common.R")


# VALIDATION: [YELLOW] Only partial data for 2018. The San Antonio PD doesn't
# appear to issue annual reports or traffic statistics. That said, the number
# of stops seems reasonable if not a little low for a state of 1.4M people.
load_raw <- function(raw_data_dir, n_max) {
  d <- load_years(raw_data_dir, n_max = n_max)
  bundle_raw(d$data, d$loading_problems)
}


clean <- function(d, helpers) {

  tr_race <- c(
    "H" = "hispanic",
    "W" = "white",
    "B" = "black",
    # TODO(phoebe): is this Latino?
    # https://app.asana.com/0/456927885748233/661513016681937
    "L" = "other/unknown",
    "A" = "asian/pacific islander",
    # TODO(phoebe): what is this?
    # https://app.asana.com/0/456927885748233/661513016681937
    "M" = "other/unknown",
    "I" = "other/unknown",
    "U" = "other/unknown",
    "X" = "other/unknown",
    "0" = "other/unknown",
    "1" = "other/unknown",
    "9" = "other/unknown"
  )

  tr_search_basis <- c(
    "Consent" = "consent",
    "Incident to Arrest" = "other",
    "Towing Inventory" = "other",
    "Probable Cause" = "probable cause",
    "Evidence" = "probable cause"
  )

  tbl <-
    d$data %>%
    rename(
      subject_age = `Age At Time Of Violation`,
      location = `Violation Location`,
      vehicle_registration_state = `License Plate State`,
      vehicle_year = `Vehicle Year`,
      vehicle_make = `Vehicle Make`,
      vehicle_model = `Vehicle Model`,
      vehicle_color = `Vehicle Color`,
      arrest_made = `Custodial Arrest Made`,
      speed = `Actual Speed`,
      posted_speed = `Posted Speed`,
      violation = Offense
    ) %>%
    helpers$add_type(
      "violation"
    ) %>%
    mutate(
      date = parse_date(`Violation Date`),
      time = parse_time(`Violation Time`),
      subject_race = tr_race[Race],
      subject_sex = tr_sex[Gender],
      search_conducted = str_detect(
        `Search Reason`,
        str_c(names(tr_search_basis), collapse = "|")
      ),
      search_basis = tr_search_basis[`Search Reason`],
      contraband_found = tr_yn[`Contraband Or Evidence`],
      arrest_made = tr_yn[arrest_made],
      citation_issued = !is.na(`Citation #`),
      # NOTE: warnings are not recorded
      outcome = first_of(
        "arrest" = arrest_made,
        "citation" = citation_issued
      ),
      # NOTE: 0 seems to indicate not recorded rather than 2000
      vehicle_year = if_else(vehicle_year == "0", NA_character_, vehicle_year)
    ) %>%
    helpers$add_lat_lng(
    ) %>%
    helpers$add_shapefiles_data(
    ) %>%
    rename(
      district = DISTRICT,
      # NOTE: SUBCODE is just the first letter of SUBSTN
      substation = SUBSTN.x
    )

  # NOTE: select only schema cols to void merging columns that will be dropped
  select_only_schema_cols(list(data = tbl))$data %>%
  merge_rows(
    date,
    time,
    location,
    subject_race,
    subject_sex,
    subject_age
  ) %>%
  standardize(d$metadata)
}
