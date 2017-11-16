library(lubridate)


valid_incident_start_date <- ymd("2000-01-01")
valid_incident_end_date <- ymd(Sys.Date())


valid_vehicle_start_year <- 1800
valid_vehicle_end_year <- lubridate::year(Sys.Date()) + 1


valid_dob_start_date <- ymd("1900-01-01")
valid_dob_end_date <- ymd(Sys.Date())


valid_age_start <- 0
valid_age_end <- 120


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
  "k9",
  "plain view",
  "consent",
  "probable cause",
  "incident to arrest"
)

valid_search_probable_cause_types <- c(
  "k9",
  "other",
  "plain view"
)


valid_sexes <- c(
  "male",
  "female"
)


# if ethnicity, i.e. hispanic use the, else default to race
valid_races <- c(
  "asian/pacific islander",
  "black",
  "hispanic",
  "other/unknown",
  "white"
)


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
  "vehicle_registration_state"      = valid_states
)
