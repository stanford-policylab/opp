source("common.R")

load_raw <- function(raw_data_dir, n_max) {
  data <- tibble()
  loading_problems <- list()
  bundle_raw(loading_problems)
}


clean <- function(d, calculated_features_path) {
  d$data %>%
    standardize(d$metadata)
}
