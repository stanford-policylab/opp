source("common.R")

load_raw <- function(raw_data_dir, n_max) {
  fname <- "green_bay.csv"
  data <- read_csv(file.path(raw_data_dir, fname), n_max = n_max)
  loading_problems <- list()
  loading_problems[[fname]] <- problems(data)
  bundle_raw(data, loading_problems)
}


clean <- function(d, calculated_features_path) {
  d$data %>%
    standardize(d$metadata)
}
