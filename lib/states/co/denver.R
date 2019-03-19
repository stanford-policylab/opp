source("common.R")


# VALIDATION: [YELLOW] There is almost no data from 2010 and only the first 7
# months of 2018. The annual report put out by denvergov.org doesn't supply
# stop figures, but these figures seem reasonable given the population;
# unfortunately, we don't get key demographic information; see TODOS for
# outstanding tasks
load_raw <- function(raw_data_dir, n_max) {
  # TODO(phoebe): what is police_pedestrian_stops_and_vehicle_stops.zip?
  # it unzips to .gb tables?
  # https://app.asana.com/0/456927885748233/758649899422591
  d <- load_single_file(
    raw_data_dir,
    "police_pedestrian_stops_and_vehicle_stops.csv",
    n_max
  )
  bundle_raw(d$data, d$loading_problems)
}


clean <- function(d, helpers) {

  # TODO(phoebe): can we get race/sex/age (i.e. demographics)?
  # https://app.asana.com/0/456927885748233/758649899422592
  # TODO(phoebe): can we get reason_for_stop/search/contraband fields?
  # https://app.asana.com/0/456927885748233/758649899422593
  d$data %>%
    rename(
      location = ADDRESS,
      lat = GEO_LAT,
      lng = GEO_LON,
      # NOTE: we have shapefiles, but don't load them since district and
      # precinct are given in the data
      district = DISTRICT_ID,
      precinct = PRECINCT_ID,
      disposition = CALL_DISPOSITION
    ) %>%
    mutate(
      # NOTE: stops are either a Vehicle Stop or a Subject Stop
      type = if_else(PROBLEM == "Vehicle Stop", "vehicular", "pedestrian"),
      # NOTE: we don't get time of stop, but time of phone call
      datetime = parse_datetime(TIME_PHONEPICKUP),
      date = as.Date(datetime),
      time = format(datetime, "%H:%M:%S"),
      # TODO: outcome from disposition
      tmp_disposition = tolower(disposition),
      warning_issued = str_detect(tmp_disposition, "war"),
      citation_issued = str_detect(tmp_disposition, "cit"),
      arrest_made = str_detect(tmp_disposition, "arrest"),
      outcome = first_of(
        arrest = arrest_made,
        citation = citation_issued,
        warning = warning_issued
      )
    ) %>%
    standardize(d$metadata)
}
