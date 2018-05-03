source("common.R")

load_raw <- function(raw_data_dir, n_max) {
  fname <- "car_ped_stops.csv"
  data <- read_csv(file.path(raw_data_dir, fname), n_max = n_max)
  loading_problems <- list()
  loading_problems[[fname]] <- problems(data)
  bundle_raw(data, loading_problems)
}


clean <- function(d, calculated_features_path) {

  tr_race <- c(
    "Black - Non-Latino" = "black",
    "White - Non-Latino" = "white",
    "White - Latino" = "hispanic",
    "Asian" = "asian/pacific islander",
    # NOTE: being hispanic/latino trumps other races in assignment
    "Black - Latino" = "hispanic",
    "Unknown" = "other/unknown",
    "American Indian" = "other/unknown"
  )

  tr_sex <- c(
    "Male" = "male",
    "Female" = "female"
  )

  tr_type <- c(
    "vehicle" = "vehicular",
    "pedestrian" = "pedestrian"
  )

  # NOTE: some clarifications of variables can be found here:
  # http://metadata.phila.gov/#home/datasetdetails/
  # 571787614fc865407e3cf2b4/representationdetails/571787614fc865407e3cf2b8/ 

  # TODO(phoebe): can we get reason_for_stop?
  # https://app.asana.com/0/456927885748233/658391963833525
  d$data %>%
    rename(
      subject_age = age,
      incident_location = location,
      precinct = districtoccur,
      arrest_made = individual_arrested,
      search_person = individual_searched,
      search_vehicle = vehicle_searched,
      incident_lat = lat,
      incident_lng = lng,
      beat = psa
    ) %>%
    mutate(
      incident_datetime = parse_datetime(datetimeoccur),
      incident_date = as.Date(incident_datetime),
      incident_time = format(incident_datetime, "%H:%M%S"),
      incident_type = tr_type[stoptype],
      # TODO(phoebe): can we get other outcomes - citations/warnings?
      # https://app.asana.com/0/456927885748233/658391963833527
      incident_outcome = first_of(
        "arrest" = arrest_made
      ),
      contraband_found = individual_contraband | vehicle_contraband,
      search_conducted = search_person | search_vehicle,
      # TODO(ravi):  is a vehicle_frisk a frisk?
      # https://app.asana.com/0/456927885748233/658391963833528
      frisk_performed = individual_frisked | vehicle_frisked,
      search_type = first_of(
        "probable cause" = search_conducted | frisk_performed
      ),
      subject_sex = tr_sex[gender],
      subject_race = tr_race[race]
    ) %>%
    standardize(d$metadata)
}
