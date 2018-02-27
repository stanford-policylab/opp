source("common.R")

load_raw <- function(raw_data_dir, n_max) {
	loading_problems <- list()
  fname <- "2012-2016trafficstops-_plank_sheet_2.csv"
  data <- read_csv(file.path(raw_data_dir, fname), n_max = n_max)
  loading_problems[[fname]] <- problems(data)
  bundle_raw(data, loading_problems)
}


# TODO(phoebe): is this all we can get? we got almost nothing other than date
# https://app.asana.com/0/456927885748233/573247093484079 
clean <- function(d, calculated_features_path) {
  d$data %>%
    rename(
      incident_date = `Occ Date`,
      reason_for_stop = `Final Case Type D`
    ) %>%
    mutate(
      # NOTE: these are only traffic stops according to the correspondence
      incident_type = "vehicular"
    ) %>%
    standardize(d$metadata)
}
