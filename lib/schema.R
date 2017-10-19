library(tidyverse)
library(stringr)


verify_schema <- function(tbl) {
  quit_if_not_tibble(tbl)
  quit_if_not_required_schema(tbl)
  quit_if_not_valid_factors(tbl)
}


quit_if_not_tibble <- function(tbl) {
  if (class(tbl)[1] != "tbl_df") {
    print("Invalid tibble in verify_schema!")
    q(status = 1)
  }
}


quit_if_not_required_schema <- function(tbl) {
  tbl_schema <- named_vector_from_list_firsts(sapply(tbl, class))
  same <- required_schema == tbl_schema[names(required_schema)]
  if (!all(same)) {
    not_same_str <- str_c(names(required_schema)[!same], collapse = ", ")
    print(str_c("Invalid or missing columns: ", not_same_str))
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


required_schema <- c(
  "incident_id"                       = "character",
  "incident_type"                     = "factor",
  "incident_date"                     = "Date",
  "incident_time"                     = "hms",
  "incident_location"                 = "character",
  "incident_lat"                      = "numeric",
  "incident_lng"                      = "numeric",
  "defendant_race"                    = "factor",
  "reason_for_stop"                   = "character",
  "search_conducted"                  = "logical",
  "search_type"                       = "factor",
  "contraband_found"                  = "logical",
  "arrest_made"                       = "logical",
  "citation_issued"                   = "logical"
)

extra_schema <- c(
  "defendant_sex"                     = "factor",
  "defendant_dob"                     = "Date",
  "defendant_is_resident_of_state"    = "logical",
  "officer_id"                        = "integer",
  "officer_sex"                       = "factor",
  "officer_race"                      = "factor",
  "officer_dob"                       = "Date",
  "officer_years_of_service"          = "numeric",
  "vehicle_year"                      = "factor",
  "vehicle_color"                     = "character",
  "vehicle_make"                      = "character",
  "vehicle_style"                     = "character",
  "vehicle_registration_state"        = "factor",
  "warning_issued"                    = "logical",
  "frisk_performed"                   = "logical",
  "search_consent"                    = "logical",
  "search_plain_view"                 = "logical",
  "search_driver"                     = "logical",
  "search_passenger"                  = "logical",
  "search_vehicle"                    = "logical",
  "search_incident_to_arrest"         = "logical",
  "reason_for_frisk"                  = "character",
  "reason_for_arrest"                 = "character",
  "reason_for_citation"               = "character",
  "contraband_recovered_from_frisk"   = "character",
  "contraband_recovered_from_search"  = "character",
  "complaint_filed_by_defendant"      = "logical",
  "notes"                             = "character"
)


valid_incident_types <- c(
  "pedestrian",
  "vehicular"
)


valid_search_types <- c(
  "probable cause",
  "custodial"
)

valid_search_probable_cause_types <- c(
  "plain view",
  "k9"
)


valid_sexes <- c(
  "male",
  "female"
)


valid_races <- c(
  "asian/pacific islander",
  "black",
  "hispanic",
  "other",
  "white"
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
  "search_type"                     = valid_search_types,
  "search_probable_cause_type"      = valid_search_probable_cause_types,
  "defendant_sex"                   = valid_sexes,
  "defendant_race"                  = valid_races,
  "officer_sex"                     = valid_sexes,
  "officer_race"                    = valid_races,
  "vehicle_year"                    = valid_vehicle_years,
  "vehicle_registration_state"      = valid_states
)
