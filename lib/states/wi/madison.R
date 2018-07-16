source("common.R")

load_raw <- function(raw_data_dir, n_max) {
  # NOTE: "IBM" is the officers department ID
  cit <- load_single_file(
    raw_data_dir,
    "mpd_traffic_stop_request_citations.csv",
    n_max
  )
  warn <- load_single_file(
    raw_data_dir,
    "mpd_traffic_stop_request_warnings.csv",
    n_max
  )
  bundle_raw(
    bind_rows(cit$data, warn$data),
    c(cit$cloading_problems, warn$loading_problems)
  )
}


clean <- function(d, helpers) {
  tr_race <- c(
    "A" = "asian/pacific islander",
    "B" = "black",
    "H" = "hispanic",
    "I" = "other/unknown",
    "W" = "white"
  )
  # TODO(phoebe): can we get reason_for_stop/search/contraband data?
  # https://app.asana.com/0/456927885748233/595493946182539
  d$data %>%
    rename(
      violation = `Statute Description`,
      vehicle_make = Make,
      vehicle_model = Model,
      vehicle_year = Year,
      vehicle_color = Color,
      vehicle_registration_state = State,
      posted_speed = Limit
    ) %>%
    separate_cols(
      OfficerName = c("officer_last_name", "officer_first_name")
    ) %>%
    mutate(
      # NOTE: Statute Descriptions all appear to be vehicle related
      type = "vehicular",
      speed = as.integer(posted_speed) + as.integer(OverLimit),
      date = parse_date(Date, "%Y/%m/%d"),
      time = parse_time(Time, "%H:%M:%S"),
      location = coalesce(onStreet, onStreetName),
      warning_issued = is.na(`Ticket #`),
      citation_issued = !is.na(`Ticket #`),
      # TODO(phoebe): can we get arrests?
      # https://app.asana.com/0/456927885748233/595493946182543
      outcome = first_of(
        citation = citation_issued,
        warning = warning_issued
      ),
      subject_race = tr_race[Race],
      subject_sex = tr_sex[Sex]
    ) %>%
    helpers$add_lat_lng(
    ) %>%
    helpers$add_shapefiles_data(
    ) %>%
    rename(
      sector = Sector,
      district = District
    ) %>%
    standardize(d$metadata)
}
