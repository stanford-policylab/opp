source("common.R")

load_raw <- function(raw_data_dir, geocodes_path) {
  data <- tibble()
	loading_problems <- list()
  data <- add_lat_lng(data, "some_col", geocodes_path)

	list(data = data, metadata = list(loading_problems = loading_problems))
}


clean <- function(d) {
  d$data %>%
    standardize(d$metadata)
}
