source("common.R")


# VALIDATION: [RED] There is only the first 7 months of 2010 here and there
# doesn't seem to be an annual report that goes back that far (as of 2018-12-13
# there is only the Annual Report for 2017).
load_raw <- function(raw_data_dir, n_max) {
  d <- load_single_file(raw_data_dir, "kean_for_traffic_stop_data.csv", n_max)
  bundle_raw(d$data, d$loading_problems)
}


clean <- function(d, helpers) {
  # TODO(phoebe): can we get race/search/contraband?
  # https://app.asana.com/0/456927885748233/583463577237756
  # TODO(phoebe): can we get more than the first half of 2010?
  # https://app.asana.com/0/456927885748233/583463577237757 
  d$data %>%
    rename(
      date = Date,
      district = District,
      officer_id = `Officer ID`
    ) %>%
    mutate(
      # NOTE: the "Nature" of all stops is TRAFFIC, so all vehicular stops
      type = "vehicular",
      time = parse_time_int(Time) ,
      location = str_c_na(
        str_c_na(Address_1, Address_2, sep = " "),
        City,
        State,
        Zip,
        sep = ", "
      )
    ) %>%
    helpers$add_lat_lng(
    ) %>%
    standardize(d$metadata)
}
