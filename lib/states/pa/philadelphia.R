source("common.R")

load_raw <- function(raw_data_dir, n_max) {
  fname <- "car_ped_stops.csv"
  data <- read_csv(file.path(raw_data_dir, fname), n_max = n_max)
  loading_problems <- list()
  loading_problems[[fname]] <- problems(data)
  bundle_raw(data, loading_problems)
}


clean <- function(d, helpers) {

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
      location = location,
      district = districtoccur,
      arrest_made = individual_arrested,
      search_person = individual_searched,
      search_vehicle = vehicle_searched,
      lat = lat,
      lng = lng,
      # police service area
      service_area = psa
    ) %>%
    mutate(
      datetime = parse_datetime(datetimeoccur),
      date = as.Date(datetime),
      time = format(datetime, "%H:%M%S"),
      type = tr_type[stoptype],
      # TODO(phoebe): can we get other outcomes - citations/warnings?
      # https://app.asana.com/0/456927885748233/658391963833527
      outcome = first_of(
        "arrest" = arrest_made
      ),
      contraband_found = individual_contraband | vehicle_contraband,
      search_conducted = search_person | search_vehicle,
      # TODO(ravi):  is a vehicle_frisk a frisk?
      # https://app.asana.com/0/456927885748233/658391963833528
      frisk_performed = individual_frisked | vehicle_frisked,
      search_basis = first_of(
        "probable cause" = search_conducted | frisk_performed
      ),
      subject_sex = tr_sex[gender],
      subject_race = tr_race[race]
    ) %>%
    standardize(d$metadata)
}
