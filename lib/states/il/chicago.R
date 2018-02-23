source("common.R")

load_raw <- function(raw_data_dir, n_max) {
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
      subject_age                   = "d",
      subject_gender                = "c",
      subject_race                  = "c",
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

  full_join(
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
    # NOTE: coalesce identical columns, preferring arrests to citations data
    left_coalesce_cols_by_suffix(
      ".x",
      ".y"
    ) %>%
		bundle_raw(loading_problems)
}


clean <- function(d, calculated_features_path) {
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
      incident_date = arrest_date,
      reason_for_stop = statute_description,
      citation_issued = citation,
			officer_id = officer_employee_no
    ) %>%
    mutate(
      incident_type = "vehicular",
      incident_time = parse_time(arrest_hour, "%H"),
      incident_location = str_trim(
        str_c(
          street_no,
          street_name,
          street_direction,
          sep = " "
        )
      ),
      subject_race = tr_race[coalesce(subject_race, driver_race)],
      subject_sex = tr_sex[coalesce(subject_gender, driver_gender)],
      arrest_made = !is.na(arrest_id),
      incident_outcome = first_of(
        arrest = arrest_made,
        citation = citation_issued
      )
    ) %>%
    add_lat_lng(
      "incident_location",
      calculated_features_path
    ) %>%
    standardize(d$metadata)
}
