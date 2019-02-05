source("common.R")


# VALIDATION: [YELLOW] There is only partial data for 2018, and it looks like
# the first month or two of 2014 are missing. According to the 2017 Annual
# Report, recorded pedestrian stops are 20-30k higher than that reported here
# each year.

# TODO(phoebe): why are pedestrian stops 20-30k higher each year according to
# the 2017 Annual Report than in this data?
# https://app.asana.com/0/456927885748233/955011230721892 
load_raw <- function(raw_data_dir, n_max) {
  d <- load_single_file(raw_data_dir, "car_ped_stops.csv", n_max = n_max)
  bundle_raw(d$data, d$loading_problems)
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
      # police service area
      service_area = psa
    ) %>%
    apply_translator_to(
      tr_int_str_to_bool,
      "arrest_made",
      "search_person",
      "search_vehicle",
      "individual_contraband",
      "vehicle_contraband",
      "individual_frisked",
      "vehicle_frisked"
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
      subject_sex = tr_sex[gender],
      subject_race = tr_race[race]
    ) %>%
    standardize(d$metadata)
}
