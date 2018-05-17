source("common.R")

load_raw <- function(raw_data_dir, n_max) {
  data <- tibble()
  loading_problems <- list()
  for (year in 2012:2018) {
    fname <- str_c(year, "_citations.csv")
    tbl <- read_csv(file.path(raw_data_dir, fname))
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

  tr_search_type <- c(
    "Consent" = "consent",
    "Incident to Arrest" = "non-discretionary",
    "Towing Inventory" = "non-discretionary",
    "Probable Cause" = "probable cause",
    "Evidence" = "probable cause"
  )

  tr_yn <- c(
    "No" = FALSE,
    "Yes" = TRUE
  )

  d$data %>%
    rename(
      subject_age = `Age At Time Of Violation`,
      incident_location = `Violation Location`,
      vehicle_registration_state = `License Plate State`,
      vehicle_year = `Vehicle Year`,
      vehicle_make = `Vehicle Make`,
      vehicle_model = `Vehicle Model`,
      vehicle_color = `Vehicle Color`,
      reason_for_stop = Offense,
      arrest_made = `Custodial Arrest Made`
    ) %>%
    helpers$add_incident_type(
    ) %>%
    filter(
      incident_type != "other"
    ) %>%
    mutate(
      incident_date = parse_date(`Violation Date`),
      incident_time = seconds_to_hms(`Violation Time`),
      subject_race = tr_race[Race],
      subject_sex = tr_sex[Gender],
      search_conducted = `Search Reason` %in% names(tr_search_type),
      search_type = tr_search_type[`Search Reason`],
      contraband_found = tr_yn[`Contraband Or Evidence`],
      arrest_made = tr_yn[arrest_made],
      citation_issued = !is.na(`Citation #`),
      # TODO(phoebe): can we get warnings?
      # https://app.asana.com/0/456927885748233/661513016681938
      incident_outcome = first_of(
        "arrest" = arrest_made,
        "citation" = citation_issued
      )
    ) %>%
    helpers$add_lat_lng(
    ) %>%
    standardize(d$metadata)
}
