source("common.R")

load_raw <- function(raw_data_dir, n_max) {
  fname <- "traffic_citation_stats_-_year-to-date_2017_sheet_1.csv"
	# TODO(phoebe): what is this file? it has similar fields but far fewer records
	# ytd_traffic_stops_from_rms_data_export_tool_sheet_1.csv	
	# https://app.asana.com/0/456927885748233/592025853254518
  data <- read_csv(file.path(raw_data_dir, fname), n_max = n_max)
  loading_problems <- list()
  loading_problems[[fname]] <- problems(data)
  bundle_raw(data, loading_problems)
}


clean <- function(d, helpers) {
  tr_race <- c(
    "AFRICAN AMERICAN" = "black",
    "AMERICAN INDIAN" = "other/unknown",
    "ASIAN" = "asian/pacific islander",
    "CAUCASIAN" = "white",
    "UNKNOWN" = "other/unknown"
  )
  tr_sex <- c(
    "Female" = "female",
    "Male" = "male"
  )

  # TODO(phoebe): can we get reason_for_stop/search/contraband fields?
  # https://app.asana.com/0/456927885748233/592025853254519
  d$data %>%
		rename(
      subject_age = `Defendant Age`,
      incident_lat = Latitude,
      incident_lng = Longitude
		) %>%
		mutate(
      incident_datetime = parse_datetime(DateTime, "%m/%d/%Y %I:%M:%S %p"),
      incident_date = as.Date(incident_datetime),
      incident_time = format(incident_datetime, "%H:%M:%S"),
      # NOTE: all of the stops have an associated `Vehicle Type`
      incident_type = "vehicular",
      # TODO(phoebe): can we get other outcomes (warnings/arrests)?
      # https://app.asana.com/0/456927885748233/592025853254520
      citation_issued = TRUE,
      incident_outcome = "citation",
      subject_race = tr_race[`Defendant Race`],
      subject_sex = tr_sex[`Defendant Gender`]
		) %>%
    standardize(d$metadata)
}
