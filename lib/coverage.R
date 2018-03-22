library(here)
library(parallel)

source("opp.R")


coverage <- function(n_cores = max(1, detectCores() / 2)) {
  cache_file <- here::here("cache", "coverage.rds")
  cvg <- get_or_create_cache(cache_file)

  cl <- makeForkCluster(n_cores)
  cvg <- parLapply(cl, locs, city_coverage)
  stopCluster(cl)
  cvg
}


get_or_create_cache <- function(cache_file) {
  paths <- opp_data_paths()
  cvg <- tibble(
    path = paths,
    state = sapply(paths, extract_state_from_path),
    city = sapply(paths, extract_city_from_path),
    modified_time = sapply(paths, modified_time)
  )
  if (file.exists(cache_file)) {
    cvg <- left_join(cvg, readRDS(cache_file))
  }
  mutate(cvg, nrow = if (exists("nrow", where = cvg)) nrow else NA)
}


city_coverage <- function(loc) {
  state <- loc["state"]
  city <- loc["city"]
  data <- opp_load_required_data(state, city)
  list(
    date_range = range(data$incident_date),
    nrows = nrow(data),
    coverage = lapply(data, coverage_rate)
  )
}
