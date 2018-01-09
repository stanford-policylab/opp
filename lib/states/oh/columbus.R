source("common.R")

load_raw <- function(raw_data_dir, geocodes_path) {
  loading_problems <- list()
  fname <- "columbus_oh_data_sheet_1.csv"
  data <- read_csv_with_types(
    file.path(raw_data_dir, fname),
    c(
      incident_id                 = "c",
      stop_date                   = "c",
      contact_end_date            = "c",
      system_entry_date           = "c",
      type_of_stop                = "c",
      cruiser_district            = "c",
      stop_reason                 = "c",
      enforcement_taken           = "c",
      gender                      = "c",
      ethnicity                   = "c",
      traffic_stop_street         = "c",
      traffic_stop_cross_street   = "c",
      violation_street            = "c",
      violation_cross_street      = "c"
    )
  )
  loading_problems[[fname]] <- problems(data)

  # NOTE: normally mutates are reserved for cleaning, but
  # here it's required to join to geolocation data
  # TODO(ravi): is this the right address to use?
  # https://app.asana.com/0/456927885748233/519045240013558
  data <- mutate(
    data,
    incident_location = str_trim(
      str_c(
        violation_street,
        violation_cross_street,
        sep = " and "
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
  dt_fmt = "%Y/%m/%d"
  tr_race = c(
    Asian = "asian/pacific islander",
    Black = "black",
    Hispanic = "hispanic",
    Other = "other/unknown",
    White = "white"
  )
  tr_sex = c(
    MALE = "male",
    FEMALE = "female"
  )

  d$data %>%
    rename(
      stop_road_type = type_of_stop,
      reason_for_stop = stop_reason,
      subject_race = ethnicity,
      subject_sex = gender
    ) %>%
    separate_cols(
      stop_date = c("incident_date", "incident_time"),
      contact_end_date = c("contact_end_date", "contact_end_time"),
      system_entry_date = c("system_entry_date", "system_entry_time")
    ) %>%
    mutate(
      incident_type = "vehicular",
      incident_date = parse_date(incident_date, dt_fmt),
      incident_time = parse_time(incident_time),
      contact_end_date = parse_date(contact_end_date, dt_fmt),
      contact_end_time = parse_time(contact_end_time),
      system_entry_date = parse_date(system_entry_date, dt_fmt),
      system_entry_time = parse_time(system_entry_time),
      subject_race = tr_race[subject_race],
      subject_sex = tr_sex[subject_sex],
      search_conducted = 
        enforcement_taken %in% c("Vehicle Search", "Driver Search"),
      search_type = ifelse(search_conducted, "probable cause", NA), 
      arrest_made = enforcement_taken == "Arrest",
      # TODO(ravi): include "Misd. Citation or Summons"?
      # https://app.asana.com/0/456927885748233/519045240013558
      citation_issued = enforcement_taken == "Traffic Citation",
      warning_issued = enforcement_taken == "Verbal Warning",
      incident_outcome = first_of(
        arrest = arrest_made,
        citation = citation_issued,
        warning = warning_issued
      )
    ) %>%
    standardize(d$metadata)
}
