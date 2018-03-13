source("common.R")

load_raw <- function(raw_data_dir, n_max) {
	
  fname <- "traffic_citation_stats_-_year-to-date_2017_sheet_1.csv"
	# TODO(phoebe): what is this file? it has similar fields but far fewer records
	# ytd_traffic_stops_from_rms_data_export_tool_sheet_1.csv	
	# 
  data <- read_csv
  loading_problems <- list()
  bundle_raw(loading_problems)
}


clean <- function(d, calculated_features_path) {
  d$data %>%
    standardize(d$metadata)
}
