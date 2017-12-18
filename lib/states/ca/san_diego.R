source("common.R")

load_raw <- function(raw_data_dir, geocodes_path) {
  loading_problems <- list()
  fname <- "pra_16-1288_vehiclestop2014-2015_sheet_1.csv"
  data <- read_csv_with_types(
    file.path(raw_data_dir, fname),
    c(
      vehicle_stop_id       = "c",
      stop_date             = "D",
      stop_time             = "t",
      stop_cause            = "c",
      race                  = "c",
      sex                   = "c",
      age                   = "d",
      arrested              = "c",
      searched              = "c",
      obtained_consent      = "c",
      contraband_found      = "c",
      property_seized       = "c",
      san_diego_resident    = "c",
      service_area          = "c",
      agency                = "c"
    )
  )
  loading_problems[[fname]] <- problems(data)

	list(data = data, metadata = list(loading_problems = loading_problems))
}


clean <- function(d) {
  # TODO(danj): check this map
  tr_race = c(
    "A" = "asian/pacific islander",
    "B" = "black",
    "C" = "other/unknown",
    "D" = "other/unknown",
    "F" = "other/unknown",
    "G" = "other/unknown",
    "H" = "hispanic",
    "I" = "other/unknown",
    "J" = "other/unknown",
    "K" = "other/unknown",
    "L" = "other/unknown",
    "O" = "other/unknown",
    "P" = "other/unknown",
    "S" = "other/unknown",
    "U" = "other/unknown",
    "V" = "other/unknown",
    "W" = "white",
    "X" = "other/unknown",
    "Z" = "other/unknown"
  )

  d$data %>%
    rename(
      incident_id = vehicle_stop_id,
      incident_date = stop_date,
      incident_time = stop_time,
      reason_for_stop = stop_cause,
      subject_race = race,
      subject_sex = sex,
      subject_age = age,
      search_conducted = searched,
      search_consent = obtained_consent,
      arrest_made = arrested
    ) %>%
    apply_translator_to(
      yn_to_tf,
      "search_conducted",
      "search_consent",
      "contraband_found",
      "property_seized",
      "san_diego_resident",
      "arrest_made"
    ) %>%
    mutate(
      incident_type = "vehicular",
      subject_race = tr_race[subject_race],
      subject_sex = tr_sex[subject_sex],
      incident_outcome = ifelse(arrest_made, "arrest", NA),
      search_type = first_of(
        "consent" = search_consent,
        "probable cause" = search_conducted 
      )
    ) %>%
    standardize(d$metadata)
}
