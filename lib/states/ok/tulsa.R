source("common.R")

load_raw <- function(raw_data_dir, n_max) {
  data <- tibble()
  loading_problems <- list()
  for (year in 2009:2016) {
    fname <- str_c("37_", year, ".csv")
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


clean <- function(d, calculated_features_path) {

  tr_race <- c(
    "A" = "asian/pacific islander",
    "B" = "black",
    "C" = "other/unknown",
    "D" = "other/unknown",
    "E" = "other/unknown",
    "F" = "other/unknown",
    "G" = "other/unknown",
    "H" = "hispanic",
    "I" = "other/unknown",
    "K" = "other/unknown",
    "L" = "other/unknown",
    "M" = "other/unknown",
    "N" = "other/unknown",
    "O" = "other/unknown",
    "P" = "other/unknown",
    "R" = "other/unknown",
    "S" = "other/unknown",
    "T" = "other/unknown",
    "U" = "other/unknown",
    "V" = "other/unknown",
    "W" = "white",
    "Y" = "other/unknown"
  )
  # TODO(phoebe): can we get outcome (warning, citation, arrest)?
  # https://app.asana.com/0/456927885748233/642528085814343
  # TODO(phoebe): can we get search/contraband fields?
  # https://app.asana.com/0/456927885748233/642528085814345
  # TODO(phoebe): what is CHARGEPARA and CHARGESECTION? Can we get a data
  # dictionary?
  # https://app.asana.com/0/456927885748233/642528085814346
	# TODO(phoebe): can we get beat/precinct or shapefiles for those?
	# https://app.asana.com/0/456927885748233/642528085814347
  colnames(d$data) <- tolower(colnames(d$data))
  d$data %>%
    rename(
      reason_for_stop = charge,
      incident_location = violation_location,
      vehicle_color = color,
      vehicle_make = make,
      vehicle_model = model,
      vehicle_registration_state = tagstate
    ) %>%
    add_incident_types(
      "reason_for_stop",
      calculated_features_path
    ) %>%
    filter(
      incident_type != "other"
    ) %>%
    mutate(
      incident_datetime = coalesce(
        parse_datetime(violationdate, "%Y/%m/%d %H:%M:%S"),
        parse_datetime(violationdate, "%Y/%m/%d")
      ),
      incident_date = as.Date(incident_datetime),
      incident_time = format(incident_datetime, "%H:%M:%S"),
      subject_race = tr_race[race],
      subject_sex = tr_sex[sex],
      vehicle_year = format_two_digit_year(year, cutoff = 2017)
    ) %>%
    add_lat_lng(
      "incident_location",
      calculated_features_path
    ) %>%
    standardize(d$metadata)
}
