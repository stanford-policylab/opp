source("common.R")

# TODO(danj): use load years everywhere
load_raw <- function(raw_data_dir, n_max) {
  fname_prefix = ""
  fname_suffix = "_profile_database_01_law_enforcement_agencies.csv"
  d <- load_years(2011, 2015, raw_data_dir, fname_prefix, fname_suffix)
  data <- d$data
  loading_problems <- d$loading_problems
  bundle_raw(data, loading_problems)
}


clean <- function(d, helpers) {

  # TODO(phoebe): can we get reason_for_stop/search/contraband fields?
  #
  d$data %>%
    rename(
    ) %>%
    mutate(
    ) %>%
    helpers$add_lat_lng(
    ) %>%
    standardize(d$metadata)
}
