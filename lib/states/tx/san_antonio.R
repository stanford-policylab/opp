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

  tr_search_basis <- c(
    "Consent" = "consent",
    "Incident to Arrest" = "other",
    "Towing Inventory" = "other",
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
      location = `Violation Location`,
      vehicle_registration_state = `License Plate State`,
      vehicle_year = `Vehicle Year`,
      vehicle_make = `Vehicle Make`,
      vehicle_model = `Vehicle Model`,
      vehicle_color = `Vehicle Color`,
      reason_for_stop = Offense,
      arrest_made = `Custodial Arrest Made`
    ) %>%
    helpers$add_type(
    ) %>%
    filter(
      type != "other"
    ) %>%
    mutate(
      date = parse_date(`Violation Date`),
      time = seconds_to_hms(`Violation Time`),
      subject_race = tr_race[Race],
      subject_sex = tr_sex[Gender],
      search_conducted = `Search Reason` %in% names(tr_search_basis),
      search_basis = tr_search_basis[`Search Reason`],
      contraband_found = tr_yn[`Contraband Or Evidence`],
      arrest_made = tr_yn[arrest_made],
      citation_issued = !is.na(`Citation #`),
      # NOTE: warnings are not recorded
      outcome = first_of(
        "arrest" = arrest_made,
        "citation" = citation_issued
      )
    ) %>%
    helpers$add_lat_lng(
    ) %>%
    helpers$add_shapefiles_data(
    ) %>%
    rename(
      district = DISTRICT
      # TODO(phoebe): what are SECTION and SUBCODE?
      # https://app.asana.com/0/456930159055660/665206850829187 
    ) %>%
    standardize(d$metadata)
}
