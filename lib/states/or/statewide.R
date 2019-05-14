source(here::here("lib", "common.R"))

load_raw <- function(raw_data_dir, n_max) {
  d <- load_single_file(
    raw_data_dir,
    "oregon_data_public_records_request_54552.csv",
    n_max = n_max
  )

  # NOTE: Data are aggregated with a Count column. Unaggregate them so that
  # one row in the dataset represents one stop.
  bundle_raw(
    # Use `rep` to duplicate rows n times, where n is defined by `Count`. Drop
    # the `Count` row from the resulting dataset, as it is no longer useful.
    d$data[rep(1:nrow(d$data), d$data$Count),] %>% select(-Count),
    d$loading_problems
  )
}


clean <- function(d, helpers) {

  tr_race <- c(
    "African American" = "black",
    "Asian" = "asian/pacific islander",
    "Hispanic" = "hispanic",
    # NOTE: We treat middle-eastern as white. See the US Census race
    # definitions: https://www.census.gov/topics/population/race/about.html
    "Middle Eastern" = "white",
    "Native American" = "other/unknown",
    "Unknown" = "other/unknown",
    "White" = "white"
  )

  # TODO(phoebe): can we get literally any other fields?
  # date/location/reason_for_stop/search/contraband, etc.
  # https://app.asana.com/0/456927885748233/743138732675745
  d$data %>%
    add_raw_colname_prefix(
      Race
    ) %>% 
    mutate(
      # NOTE: The only date information we have is year. Set the date as the
      # first day of the year, similar to how we treat coarse time units for
      # other states.
      date = parse_date(str_c(Year, "0101"), "%Y%m%d"),
      subject_race = tr_race[raw_Race],
      # NOTE: Source file is for traffic stops.
      type = "vehicular"
    ) %>%
    standardize(d$metadata)
}
