library(here)
library(parallel)

source("opp.R")
source("standards.R")


coverage <- function(n_cores = max(1, detectCores() / 2)) {
  cl <- makeForkCluster(n_cores)
  locs <- find_cities_with_data()
  cvg <- parLapply(cl, locs, city_coverage)
  stopCluster(cl)
  cvg
}


# TODO(danj): is searching for .rds files the best way to assess coverage?
find_cities_with_data <- function() {
  paths <- list.files(here::here("data"), ".*\\.rds$", recursive = TRUE)
  lapply(paths, extract_state_city_from_path)
}


extract_state_city_from_path <- function(path) {
  state <- extract_token_from_path(path, 2)
  city <- extract_token_from_path(path, 3)
  c(state = state, city = city)
}


city_coverage <- function(loc) {
  state <- loc["state"]
  city <- loc["city"]
  data <- opp_load_required_data(state, city)
  list(
    date_range = range(data$incident_date)
    nrows = nrow(data),
    coverage = lapply(data, coverage_rate)
  )
}
