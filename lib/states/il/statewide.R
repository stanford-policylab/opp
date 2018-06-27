library(jsonlite)

source("common.R")


load_raw <- function(raw_data_dir, n_max) {
  read_single_year <- function(year, n_max) {
    col_types <- cols(
      AgencyName = "c",
      AgencyCode = "c",
      DateOfStop = col_date(format = "%m/%d/%Y"),
      TimeOfStop = col_time(format = ""),
      DurationOfStop = "d",
      ZIP = "c",
      VehicleMake = "c",
      VehicleYear = "d",
      DriversYearofBirth = "c",
      DriverSex = "d",
      DriverRace = "i",
      ReasonForStop = "i",
      TypeOfMovingViolation = "i",
      ResultOfStop = "i",
      BeatLocationOfStop = "c", # mostly int, but some string
      VehicleConsentSearchRequested = "i",
      VehicleConsentGiven = "i",
      VehicleSearchConducted = "i",
      VehicleSearchConductedBy = "i",
      VehicleContrabandFound = "i",
      VehicleDrugsFound = "i",
      VehicleDrugParaphernaliaFound = "i",
      VehicleAlcoholFound = "i",
      VehicleWeaponFound = "i",
      VehicleStolenPropertyFound = "i",
      VehicleOtherContrabandFound = "i",
      VehicleDrugAmount = "i",
      DriverConsentSearchRequested = "i",
      DriverConsentGiven = "i",
      DriverSearchConducted = "i",
      DriverSearchConductedBy = "i",
      PassengerConsentSearchRequested = "i",
      PassengerConsentGiven = "i",
      PassengerSearchConducted = "i",
      PassengerSearchConductedBy = "i",
      DriverPassengerContrabandFound = "i",
      DriverPassengerDrugsFound = "i",
      DriverPassengerDrugParaphernaliaFound = "i",
      DriverPassengerAlcoholFound = "i",
      DriverPassengerWeaponFound = "i",
      DriverPassengerStolenPropertyFound = "i",
      DriverPassengerOtherContrabandFound = "i",
      DriverPassengerDrugAmount = "i",
      PoliceDogPerformSniffOfVehicle = "d",
      PoliceDogAlertIfSniffed = "d",
      PoliceDogVehicleSearched = "d",
      PoliceDogContrabandFound = "d",
      PoliceDogDrugsFound = "d",
      PoliceDogDrugParaphernaliaFound = "d",
      PoliceDogAlcoholFound = "d",
      PoliceDogWeaponFound = "d",
      PoliceDogStolenPropertyFound = "d",
      PoliceDogOtherContrabandFound = "d",
      PoliceDogDrugAmount = "d"
    )

    # NOTE: 2013 DateOfStop has values with format "%m/%d/%Y" and
    # "%Y-%m-%d %H:%M:%S" with time 00:00:00.  We read the column in as
    # characters and normalize in order to rbind with other years.
    if (year == 2013) {
      col_types$cols$DateOfStop = col_character()
    }

    filename <- paste0(as.character(year), "_itss_data.csv")
    d <- load_single_file(raw_data_dir,
                          filename,
                          col_types = col_types,
                          n_max = n_max)

    if (year == 2013) {
      extract_date_for_2013 <- function(x) {
        ifelse(grepl("/", x),
               as.Date(x, format="%m/%d/%Y"),
               as.Date(substr(x, 1, 10), format="%Y-%m-%d"))
      }

      d$data <- d$data %>% 
        mutate(temp_col = mapply(extract_date_for_2013, DateOfStop)) %>%
        select(-DateOfStop) %>%
        mutate(DateOfStop = as_date(unname(temp_col))) %>%
        select(-temp_col)
    }

    d
  }

  years <- 2012:2016
  years_data <- years %>% map(function(x) read_single_year(x, n_max))
  loading_problems <- years_data %>% map(function(x) x$loading_problems)
  data <- bind_rows(years_data %>% map(function(x) x$data))

  # NOTE: Many columns are encoded as integer enums values. For each such
  # column, we add a column named <ORIG_COLUMN_NAME>_desc with the character
  # description of the enum value.
  enum_col_desc_maps <- fromJSON(read_file(file.path(raw_data_dir,
                                                     "ITSS_Field_Values.json")))
  enum_col_names <- names(enum_col_desc_maps)

  for (col_name in enum_col_names) {
    cat("Adding enum description column for: ", col_name, "\n")
    data[[col_name]] <- as.integer(data[[col_name]])

    col_desc_name <- paste0(col_name, "_desc")
    data[[col_desc_name]] <- mapply(function(x) {
      ifelse(as.character(x) %in% names(enum_col_desc_maps[[col_name]]),
             enum_col_desc_maps[[col_name]][[as.character(x)]],
             NA)
    }, data[[col_name]])
  }

  bundle_raw(data, loading_problems)
}


clean <- function(d, helpers) {
  normalize_subject_yob <- function(x) {
    ifelse(grepl("/", x),
           year(as.Date(x, format="%m/%d/%Y")),
           as.integer(x))
  }

  subject_sex_map <- c(
    `1` = "male",
    `2` = "female"
  )

  subject_race_map <- c(
    `1` = "white",
    `2` = "black",
    `3` = "other/unknown", # American Indian or Alaska Native
    `4` = "hispanic",
    `5` = "asian/pacific islander", # Asian
    `6` = "asian/pacific islander" # Native Hawaiian or Other Pacific Islander
  )

  outcome_map <- c(
    `1` = "citation",
    `2` = "warning", # Written Warning
    `3` = "warning" # Verbal Warning (stop card)
  )

  normalize_with_map <- function(map) {
    function(value) {
      ifelse(as.character(value) %in% names(map),
             map[[as.character(value)]],
             NA)
    }
  }

  normalize_reason_for_stop <- function(x) {
    ifelse(grepl("/", x),
           year(as.Date(x, format="%m/%d/%Y")),
           as.integer(x))
  }

  d$data %>%
    rename(
      # when
      date = DateOfStop,
      time = TimeOfStop,

      # where
      location = ZIP, #TODO(wkim): Should this be ZIP and beat?
      beat = BeatLocationOfStop,

      #who
      department_name = AgencyName,
      department_id = AgencyCode,

      # other
      vehicle_make = VehicleMake
    ) %>%
    mutate(
      # where
      # county_name = #TODO(wkim): Should this be computed from the ZIP?

      #who
      # subject_age = #TODO(wkim): Should this be computed from the YOB and
      #                            arrest date?
      subject_sex = mapply(normalize_with_map(subject_sex_map), DriverSex),
      subject_race = mapply(normalize_with_map(subject_race_map), DriverRace),

      # what
      type = "vehicular",
      # violation = #TODO(wkim): Should this just be a copy of reason_for_stop?
      arrest_made = NA,
      citation_issued = ResultOfStop == 1,
      warning_issued = ResultOfStop == 2 | ResultOfStop == 3,
      outcome = mapply(normalize_with_map(outcome_map), ResultOfStop),
      contraband_found = VehicleContrabandFound == 1 |
        VehicleDrugsFound == 1 |
        VehicleDrugParaphernaliaFound == 1 |
        VehicleAlcoholFound == 1 |
        VehicleWeaponFound == 1 |
        VehicleStolenPropertyFound == 1 |
        VehicleOtherContrabandFound == 1 |
        DriverPassengerContrabandFound == 1 |
        DriverPassengerDrugsFound == 1 |
        DriverPassengerDrugParaphernaliaFound == 1 |
        DriverPassengerAlcoholFound == 1 |
        DriverPassengerWeaponFound == 1 |
        DriverPassengerStolenPropertyFound == 1 |
        DriverPassengerOtherContrabandFound == 1 |
        PoliceDogContrabandFound == 1 |
        PoliceDogDrugsFound == 1 |
        PoliceDogDrugParaphernaliaFound == 1 |
        PoliceDogAlcoholFound == 1 |
        PoliceDogWeaponFound == 1 |
        PoliceDogStolenPropertyFound == 1 |
        PoliceDogOtherContrabandFound == 1,
      contraband_drugs = VehicleDrugsFound == 1 |
        VehicleDrugParaphernaliaFound == 1 |
        VehicleDrugAmount > 0 |
        DriverPassengerDrugsFound == 1 |
        DriverPassengerDrugParaphernaliaFound == 1 |
        DriverPassengerDrugAmount > 0 |
        PoliceDogDrugsFound == 1 |
        PoliceDogDrugParaphernaliaFound == 1 |
        PoliceDogDrugAmount > 0,
      contraband_weapons = VehicleWeaponFound == 1 |
        DriverPassengerWeaponFound == 1 |
        PoliceDogWeaponFound == 1,
      search_conducted = VehicleSearchConducted == 1 |
        DriverSearchConducted == 1 |
        PassengerSearchConducted == 1 |
        PoliceDogVehicleSearched == 1,
      search_person = DriverSearchConducted == 1 |
        PassengerSearchConducted == 1,
      search_vehicle = VehicleSearchConducted == 1 |
        PoliceDogVehicleSearched == 1,
      search_type = ifelse(VehicleConsentGiven == 1 |
                             DriverConsentGiven == 1 |
                             PassengerConsentGiven == 1,
                           "consent",
                           ifelse(PoliceDogAlertIfSniffed == 1,
                                  "k9",
                                  NA)),

      #why
      reason_for_stop = ifelse(ReasonForStop == 1,
                               paste(ReasonForStop_desc,
                                     TypeOfMovingViolation,
                                     sep=": "),
                               ReasonForStop_desc),
      # other
      vehicle_year = as.integer(VehicleYear),

      # Added constraints
      # NOTE: Sometimes contraband is found but no search is recorded. We set
      # these to FALSE (because we define it as contraband found as the result
      # of a search). The vast majority of vals for contraband are NA, which we
      # set to FALSE.
      contraband_found = ifelse(is.na(contraband_found) | (!search_conducted),
                                FALSE,
                                contraband_found),

      # Extras columns
      duration = dminutes(x=DurationOfStop),
      subject_yob = mapply(normalize_subject_yob, DriversYearofBirth)
    ) %>%
    helpers$add_lat_lng(
    ) %>%
    standardize(d$metadata)
}
