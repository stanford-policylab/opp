source("common.R")

load_raw <- function(raw_data_dir, n_max) {
  fname <- "kean_for_traffic_stop_data_sheet_1.csv"
  data <- read_csv(file.path(raw_data_dir, fname), n_max = n_max)
	loading_problems <- list()
  loading_problems[[fname]] <- problems(tbl)
  bundle_raw(data, loading_problems)
}


clean <- function(d, calculated_features_path) {

  # TODO(phoebe):
  # can we get race/search/contraband?
  # https://app.asana.com/0/456927885748233/583463577237756
  # can we get more than the first half of 2010?
  # https://app.asana.com/0/456927885748233/583463577237757 
  d$data %>%
    rename(
      incident_date = Date,
      precinct = District,
      officer_id = `Officer ID`
    ) %>%
    mutate(
      # NOTE: the "Nature" of all stops is TRAFFIC, so all vehicular stops
      incident_type = "vehicular",
      incident_time = parse_time_int(Time) ,
      incident_location = str_c_na(
        str_c_na(Address_1, Address_2, sep = " "),
        City,
        State,
        Zip,
        sep = ", "
      )
    ) %>%
    add_lat_lng(
      "incident_location",
      calculated_features_path
    ) %>%
    standardize(d$metadata)
}
