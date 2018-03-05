source("common.R")

load_raw <- function(raw_data_dir, n_max) {
  fname <- "kean_for_traffic_stop_data_sheet_1.csv"
  data <- read_csv(file.path(raw_data_dir, fname), n_max = n_max)
	loading_problems <- list(fname = problems(data))
  bundle_raw(data, loading_problems)
}


clean <- function(d, calculated_features_path) {

  d$data %>%
    standardize(d$metadata)
}
