source("common.R")

load_raw <- function(raw_data_dir, n_max) {
  d <- load_single_file(raw_data_dir, "ts_and_ss_2008_2018_ytd.csv", n_max)
  colnames(d$data) <- make_ergonomic(colnames(d$data))
  bundle_raw(d$data, d$loading_problems)
}


clean <- function(d, helpers) {

  # TODO(phoebe): can we get reason_for_stop/search/contraband fields?
  # https://app.asana.com/0/456927885748233/758649899422600
  # TODO(phoebe): can we get demographics (age/sex/race)?
  # https://app.asana.com/0/456927885748233/758649899422601
  # TODO(phoebe): can we get stop outcome (warning/citation/arrest)?
  # https://app.asana.com/0/456927885748233/758649899422602
  # NOTE: we have subject name here but no other demographic information
  d$data %>%
    rename(
      vehicle_make = make,
      vehicle_model = model,
      vehicle_color = vehic_color,
      vehicle_year = model_year
    ) %>%
    separate_cols(
      officer = c("officer_last_name", "officer_first_name"),
      sep = ", "
    ) %>%
    separate_cols(
      officer_first_name = c("officer_first_name", "officer_id"),
      sep = "/"
    ) %>%
    mutate(
      type = if_else(call_type == "TS", "vehicular", "pedestrian")
    ) %>%
    helpers$add_lat_lng(
    ) %>%
    standardize(d$metadata)
}
