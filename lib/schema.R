library(tidyverse)
library(stringr)


verify_schema <- function(tbl) {
  quit_if_not_tibble(tbl)
  quit_if_not_valid_schema(tbl)
  quit_if_not_valid_factors(tbl)
}


quit_if_not_tibble <- function(tbl) {
  if (class(tbl)[1] != "tbl_df") {
    print("Invalid tibble in verify_schema!")
    q(status = 1)
  }
}


quit_if_not_valid_schema <- function(tbl) {
  tbl_schema <- named_vector_from_list_firsts(sapply(tbl, class))
  same <- valid_schema == tbl_schema
  extra <- tbl_schema != valid_schema
  if (!all(same) || any(extra)) {
    not_same_str <- str_c(names(valid_schema)[!same], collapse = ", ")
    extra_str <- str_c(names(tbl_schema)[extra], collapse = ", ")
    print(str_c("Invalid or missing columns: ", not_same_str))
    print(str_c("Extra columns found: ", extra_str))
    q(status = 1)
  }
}


quit_if_not_valid_factors <- function(tbl) {
  tbl_schema <- sapply(tbl, class)
  tbl_factors <- names(tbl_schema[tbl_schema == "factor"])
  invalid_factors <- map_lgl(tbl_factors, function(col) {
    values <- levels(tbl[[col]])
    valids <- valid_factors[col]
    all(valids == values)
  })
  if (any(invalid_factors)) {
    invalid_factors_str <- str_c(tbl_factors[invalid_factors], collapse = ", ")
    print(str_c("The following columns have invalid factor values: ",
                invalid_factors_str))
    q(status = 1)
  }
}


valid_schema <- c(
 "case_number"                      = "integer",
 "incident_type"                    = "factor",
 "incident_date"                    = "Date",
 "incident_time"                    = "hms",
 "incident_location"                = "character",
 "incident_lat"                     = "numeric",
 "incident_long"                    = "numeric",
 "defendant_gender"                 = "factor",
 "defendant_race"                   = "factor",
 "defendant_dob"                    = "Date",
 "officer_first_name"               = "character",
 "officer_last_name"                = "character",
 "officer_id"                       = "integer",
 "officer_gender"                   = "factor",
 "officer_race"                     = "factor",
 "officer_dob"                      = "Date",
 "officer_years_of_service"         = "numeric",
 "vehicle_year"                     = "factor",
 "vehicle_color"                    = "character",
 "vehicle_make"                     = "character",
 "vehicle_style"                    = "character",
 "vehicle_registration_state"       = "factor"
)


valid_incident_types <- c(
  "pedestrian",
  "vehicular"
)


valid_genders <- c(
  "male",
  "female"
)


valid_races <- c(
  "hispanic",
  "white",
  "african american",
  "asian american",
  "pacific islander",
  "middle eastern",
  "native american"
)


valid_vehicle_years <- 1800:(lubridate::year(Sys.Date()) + 1)


valid_states <- c(
  "AL",
  "AK",
  "AZ",
  "AR",
  "CA",
  "CO",
  "CT",
  "DE",
  "DC",
  "FL",
  "GA",
  "HI",
  "ID",
  "IL",
  "IN",
  "IA",
  "KS",
  "KY",
  "LA",
  "ME",
  "MT",
  "NE",
  "NV",
  "NH",
  "NJ",
  "NM",
  "NY",
  "NC",
  "ND",
  "OH",
  "OK",
  "OR",
  "MD",
  "MA",
  "MI",
  "MN",
  "MS",
  "MO",
  "PA",
  "RI",
  "SC",
  "SD",
  "TN",
  "TX",
  "UT",
  "VT",
  "VA",
  "WA",
  "WV",
  "WI",
  "WY"
)


valid_factors <- list(
  "incident_type"                   = valid_incident_types,
  "defendant_gender"                = valid_genders,
  "defendant_race"                  = valid_races,
  "officer_gender"                  = valid_genders,
  "officer_race"                    = valid_races,
  "vehicle_year"                    = valid_vehicle_years,
  "vehicle_registration_state"      = valid_states
)
