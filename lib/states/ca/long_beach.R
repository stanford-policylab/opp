source("common.R")

load_raw <- function(raw_data_dir, n_max) {
  data <- tibble()
  loading_problems <- list()
  for (year in 2008:2017) {
    fname <- str_c(year, ".csv")
    tbl <- read_csv(file.path(raw_data_dir, fname))
    loading_problems[[fname]] <- problems(tbl)
    data <- bind_rows(data, tbl)
    if (nrow(data) > n_max) {
      data <- data[1:n_max,]
    }
  }
  bundle_raw(data, loading_problems)
}


clean <- function(d, calculated_features_path) {
  d$data %>%
    standardize(d$metadata)
}
