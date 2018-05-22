source("common.R")

load_raw <- function(raw_data_dir, n_max) {
	loading_problems <- list()
  fname <- "data_from_muni_clerk_sheet_1.csv"
  data <- read_csv(
    file.path(raw_data_dir, fname),
    # NOTE: inconsistent time format, so import as character
    col_types = cols(Time = col_character()),
    n_max = n_max
  )
  loading_problems[[fname]] <- problems(data)
  bundle_raw(data, loading_problems)
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
      incident_location = Location,
      incident_date = `Offense Date`,
      vehicle_make = `Veh Make`,
      vehicle_model = `Veh Model`,
      vehicle_color = `Veh Color`,
      vehicle_year = `Veh Year`,
      vehicle_registration_state = `Vehicle Vrn St`,
      reason_for_stop = Offense
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
    helpers$add_incident_type(
    ) %>%
    filter(
      incident_type != "other"
    ) %>%
    mutate(
      # NOTE: these are all citations since indexed by citation number
      incident_outcome = "citation",
      incident_time = parse_time(Time, "%I:%M%p"),
      citation_issued = TRUE,
      subject_race = tr_race[Race],
      subject_sex = tr_sex[Sex],
      search_conducted = yn_to_tf[Search],
      search_type = first_of(
        "consent" = yn_to_tf[Consent],
        "probable cause" = search_conducted  # default
      ),
      contraband_found = yn_to_tf[Contraband]
    ) %>%
    # TODO(phoebe): how can we dedupe these to match number of drivers?
    # https://app.asana.com/0/456927885748233/573247093484087
    merge_rows(
      incident_location,
      incident_date,
      incident_time
    ) %>%
    standardize(d$metadata)
}
