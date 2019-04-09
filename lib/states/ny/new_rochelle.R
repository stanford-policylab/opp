source("common.R")

# TODO(phoebe); request this data not printed to excel but rather in the
# original csv format, also this appears to only provide subject stops
# https://app.asana.com/0/456927885748233/1117283630988012 
load_raw <- function(raw_data_dir, n_max) {
  d <- load_regex(raw_data_dir, "subjectstop", n_max)
  bundle_raw(d$data, d$loading_problems)
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
