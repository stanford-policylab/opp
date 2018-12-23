source("common.R")


# VALIDATION: [RED] The primary key, Citation number appears to overcount
# events, or at least be really high relative to the population. The EEPD
# apparently released a racial profiling report to the town council, although
# it doesn't seem to have been released online yet. The report notes that in
# 2017 (a year not present in our data), there were 85k traffic stops, which is
# considerably lower than the years in the data here. Even deduping on
# location, date, and time, these figures seem a bit high.
# NOTE: there is only partial data for 2016
load_raw <- function(raw_data_dir, n_max) {
	loading_problems <- list()
  d <- load_single_file(
    raw_data_dir,
    "data_from_muni_clerk_sheet_1.csv",
    n_max = n_max
  )
  bundle_raw(d$data, d$loading_problems)
}


clean <- function(d, helpers) {

  tr_race <- c(
    "A" = "asian/pacific islander",
    "B" = "black",
    "B;W" = "other/unknown",
    "H" = "hispanic",
    "I" = "other/unknown",
    "M" = "other/unknown",
    "U" = "other/unknown",
    "W" = "white"
  )

  # NOTE: officer name exists in raw data, but no officer_id
  d$data %>%
    rename(
      location = Location,
      date = `Offense Date`,
      vehicle_make = `Veh Make`,
      vehicle_model = `Veh Model`,
      vehicle_color = `Veh Color`,
      vehicle_year = `Veh Year`,
      vehicle_registration_state = `Vehicle Vrn St`,
      violation = Offense
    ) %>%
    helpers$add_lat_lng(
    ) %>%
    helpers$add_shapefiles_data(
    ) %>%
    rename(
      # NOTE: DISTRICT2 appears to be a simpler version of DISTRICT
      district = DISTRICT2,
      region = REGION
    ) %>%
    helpers$add_type(
      "violation"
    ) %>%
    separate_cols(
      Officer = c("officer_last_name", "officer_first_name"),
      sep = ", "
    ) %>%
    mutate(
      # NOTE: these are all citations since indexed by citation number
      citation_issued = TRUE,
      outcome = "citation",
      time = parse_time(Time, "%I:%M%p"),
      subject_race = tr_race[Race],
      subject_sex = tr_sex[Sex],
      search_conducted = tr_yn[Search],
      search_basis = first_of(
        "consent" = tr_yn[Consent],
        "probable cause" = search_conducted  # default
      ),
      contraband_found = tr_yn[Contraband]
    ) %>%
    # TODO(phoebe): how can we dedupe these to match number of drivers?
    # https://app.asana.com/0/456927885748233/573247093484087
    merge_rows(
      location,
      date,
      time
    ) %>%
    standardize(d$metadata)
}
