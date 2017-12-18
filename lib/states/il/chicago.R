source("common.R")

load_raw <- function(raw_data_dir, geocodes_path) {
  loading_problems <- list()
  arrests_file <- "arrests.csv"
  arrests <- read_csv_with_types(
    file.path(raw_data_dir, arrests_file),
    c(
      arrest_id                     = "i",
      arrest_date                   = "D",
      arrest_hour                   = "i",
      street_no                     = "c",
      street_direction              = "c",
      street_name                   = "c",
      statute                       = "c",
      statute_description           = "c",
      defendant_age                 = "d",
      defendant_gender              = "c",
      defendant_race                = "c",
      officer_role                  = "c",
      officer_employee_no           = "i",
      officer_last_name             = "c",
      officer_first_name            = "c",
      officer_middle_initial        = "c",
      officer_gender                = "c",
      officer_race                  = "c",
      officer_age                   = "d",
      officer_position              = "c",
      officer_years_of_service      = "i"
    )
  )
  loading_problems[[arrests_file]] <- problems(arrests)

  citations_file <- "citations.csv"
  citations <- read_csv_with_types(
    file.path(raw_data_dir, citations_file),
    c(
      contact_card_id               = "i",
      contact_date                  = "D",
      time_of_day                   = "i",
      street_no                     = "c",
      street_direction              = "c",
      street_name                   = "c",
      statute                       = "c",
      statute_description           = "c",
      citation                      = "i",
      driver_gender                 = "c",
      driver_race                   = "c",
      officer_last_name             = "c",
      officer_first_name            = "c",
      officer_gender                = "c",
      officer_race                  = "c",
      officer_position              = "c",
      officer_years_of_service      = "i"
    )
  )
  loading_problems[[citations_file]] <- problems(citations)

  data <- full_join(
    arrests,
    citations,
    by = c(
      "arrest_date" = "contact_date",
      "arrest_hour" = "time_of_day",
      "officer_first_name" = "officer_first_name",
      "officer_last_name" = "officer_last_name",
      "street_no" = "street_no",
      "street_name" = "street_name",
      "street_direction" = "street_direction"
      )
    ) %>%
    # coalesce remaining identical columns, preferring arrests to citations
    left_coalesce_cols_by_suffix(
      ".x",
      ".y"
    ) %>%
    # NOTE: normally mutates are reserved for cleaning, but
    # here it's required to join to geolocation data
    mutate(
      incident_location = str_trim(
        str_c(
          street_no,
          street_name,
          street_direction,
          sep = " "
        )
      )
    ) %>%
    add_lat_lng(
      "incident_location",
      geocodes_path
    )

	list(data = data, metadata = list(loading_problems = loading_problems))
}


clean <- function(d) {
  tr_race = c(
    "AMER IND/ALASKAN NATIVE" = "other/unknown",
    "ASIAN/PACIFIC ISLANDER" = "asian/pacific islander",
    "BLACK" = "black",
    "HISPANIC" = "hispanic",
    "UNKNOWN" = "other/unknown",
    "WHITE" = "white"
  )

  d$data %>%
    rename(
      citation_issued = citation,
      incident_date = arrest_date,
      reason_for_stop = statute_description,
      subject_age = defendant_age
    ) %>%
    mutate(
      # arrest_id and contact_card_id have different ranges, so this is ok
      incident_id = coalesce(arrest_id, contact_card_id),
      incident_type = "vehicular",
      incident_time = parse_time(arrest_hour, "%H"),
      subject_race = tr_race[coalesce(defendant_race, driver_race)],
      subject_sex = tr_sex[coalesce(defendant_gender, driver_gender)],
      officer_sex = tr_sex[officer_gender],
      officer_race = tr_race[officer_race],
      arrest_made = !is.na(arrest_id),
      incident_outcome = first_of(
        arrest = arrest_made,
        citation = citation_issued
      )
    ) %>%
    standardize(d$metadata)
}
