source("common.R")

load_raw <- function(raw_data_dir, n_max) {
  d <- load_years(raw_data_dir, n_max)
  bundle_raw(d$data, d$loading_problems)
}


clean <- function(d, helpers) {

  # TODO(phoebe): can we get reason_for_stop/search/contraband fields?
  #
  d$data %>%
    rename(
      date = incident_date,
      time = incident_time,
      location = incident_address,
      subject_sex = sex,
      subject_race = race,
      violation = offense_title,
      disposition = final_disposition,
      officer_id = officer_badge,
      vehicle_make = make,
      vehicle_registration_state = vehicle_state
    ) %>%
    mutate(
    ) %>%
    helpers$add_lat_lng(
    ) %>%
    standardize(d$metadata)
}
