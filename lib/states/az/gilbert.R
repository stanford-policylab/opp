source("common.R")

# VALIDATION: [YELLOW] Gilbert Police Department's "FY 2017 Annual Report" has
# a section on call volume for traffic stops, which seems to be about 10-20%
# higher than the number of recorded stops in our data; this may be because
# only certain outcomes are recorded; unfortunately, we don't get a lot of data
# here, including stop outcome.
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
      vehicle_color = vehic_color
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
      type = if_else(call_type == "TS", "vehicular", "pedestrian"),
      vehicle_year = as.integer(model_year),
      # NOTE: the overwhelming majority of model_years are either NULL or 0,
      # and there are so many 0s that it's more likely a NULL value than the
      # proportion of vehicles stopped that were made in the year 2000
      vehicle_year = if_else(vehicle_year == 0, NA_integer_, vehicle_year),
      vehicle_year = if_else(
        vehicle_year < 100,
        format_two_digit_year(vehicle_year),
        vehicle_year
      )
    ) %>%
    helpers$add_lat_lng(
    ) %>%
    standardize(d$metadata)
}
