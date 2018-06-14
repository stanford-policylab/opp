source("common.R")

load_raw <- function(raw_data_dir, n_max) {
  d <- load_single_file(
    raw_data_dir,
    "2012-2016trafficstops-_plank_sheet_2.csv",
    n_max
  )
  bundle_raw(d$data, d$loading_problems)
}


# TODO(phoebe): is this all we can get? we got almost nothing other than date
# https://app.asana.com/0/456927885748233/573247093484079 
clean <- function(d, helpers) {
  d$data %>%
    rename(
      date = `Occ Date`,
      # NOTE: this isn't really a reason for the stop, this is more like
      # a mix of reason for stop, stop category, and violation in one
      reason_for_stop = `Final Case Type D`
    ) %>%
    mutate(
      # NOTE: these are only traffic stops according to the correspondence
      type = "vehicular"
    ) %>%
    standardize(d$metadata)
}
