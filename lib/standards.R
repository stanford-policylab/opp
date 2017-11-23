library(functional)
library(lubridate)


valid_incident_start_date <- ymd("2000-01-01")
valid_incident_end_date <- ymd(Sys.Date())


valid_vehicle_start_year <- 1800
valid_vehicle_end_year <- lubridate::year(Sys.Date()) + 1


valid_dob_start_date <- ymd("1900-01-01")
valid_dob_end_date <- ymd(Sys.Date())


valid_yob_start <- 1900
valid_yob_end <- year(Sys.Date())


valid_age_start <- 0
valid_age_end <- 120


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


# if ethnicity, i.e. hispanic use it, else default to race
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


required_schema <- c(
  incident_id             = as.character,
  incident_type           = Curry(factor, levels = valid_incident_types),
  incident_date           = as.Date,
  incident_time           = hms,
  incident_location       = as.character,
  incident_lat            = as.numeric,
  incident_lng            = as.numeric,
  subject_race            = Curry(factor, levels = valid_races),
  reason_for_stop         = as.character,
  search_conducted        = as.logical,
  search_type             = Curry(factor, levels = valid_search_types),
  contraband_found        = as.logical,
  arrest_made             = as.logical,
  citation_issued         = as.logical
)


extra_schema <- c(
  subject_sex                       = Curry(factor, levels = valid_sexes),
  subject_dob                       = as.Date,
  subject_is_resident_of_state      = as.logical,
  officer_id                        = as.character,
  officer_sex                       = Curry(factor, levels = valid_sexes),
  officer_race                      = Curry(factor, levels = valid_races),
  officer_dob                       = as.Date,
  officer_years_of_service          = as.numeric,
  vehicle_year                      = as.numeric,
  vehicle_color                     = as.character,
  vehicle_make                      = as.character,
  vehicle_style                     = as.character,
  vehicle_registration_state        = Curry(factor, levels = valid_states),
  warning_issued                    = as.logical,
  frisk_performed                   = as.logical,
  search_consent                    = as.logical,
  search_plain_view                 = as.logical,
  search_driver                     = as.logical,
  search_passenger                  = as.logical,
  search_vehicle                    = as.logical,
  search_incident_to_arrest         = as.logical,
  reason_for_frisk                  = as.character,
  reason_for_arrest                 = as.character,
  reason_for_citation               = as.character,
  contraband_recovered_from_frisk   = as.character,
  contraband_recovered_from_search  = as.character,
  complaint_filed_by_subject        = as.logical,
  notes                             = as.character
)
