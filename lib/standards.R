library(functional)
library(readr)
library(lubridate)


valid_incident_start_date <- ymd("2000-01-01")
valid_incident_end_date <- ymd(Sys.Date())


valid_vehicle_start_year <- 1800
valid_vehicle_end_year <- lubridate::year(Sys.Date()) + 1


valid_age_start <- 10
valid_age_end <- 100


valid_dob_start_date <- ymd(Sys.Date()) - valid_age_end
valid_dob_end_date <- ymd(Sys.Date()) - valid_age_start


valid_yob_start <- year(Sys.Date()) - valid_age_end
valid_yob_end <- year(Sys.Date()) - valid_age_start


valid_incident_types <- c(
  "pedestrian",
  "vehicular"
)


# order they are likely to occur
valid_search_types <- c(
  "k9",
  "plain view",
  "consent",
  "probable cause",
  "non-discretionary"  # NOTE: arrest/warrant, probation/parole, inventory
)


valid_outcomes <- c(
  "warning",
  "citation",
  "summons",
  "arrest"
)


valid_sexes <- c(
  "male",
  "female"
)


# NOTE: if ethnicity, i.e. hispanic use it, else default to race
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
  incident_date           = parse_date,
  # NOTE: lubridate's hms does not play well with dplyr
  # https://github.com/tidyverse/dplyr/issues/2520
  incident_time           = parse_time,
  incident_location       = as.character,
  incident_outcome        = Curry(factor, levels = valid_outcomes),
  subject_race            = Curry(factor, levels = valid_races),
  reason_for_stop         = as.character,
  search_conducted        = as.logical,
  search_type             = Curry(factor, levels = valid_search_types),
  contraband_found        = as.logical
)


extra_schema <- c(
  incident_lat                      = as.numeric,
  incident_lng                      = as.numeric,
  beat                              = as.character,
  district                          = as.character,
  precinct                          = as.character,
  sector                            = as.character,
  zone                              = as.character,
  department_name                   = as.character,
  subject_sex                       = Curry(factor, levels = valid_sexes),
  subject_dob                       = as.Date,
  subject_age                       = as.numeric,
  officer_id                        = as.character,
  vehicle_color                     = as.character,
  vehicle_make                      = as.character,
  vehicle_model                     = as.character,
  vehicle_registration_state        = Curry(factor, levels = valid_states),
  vehicle_year                      = as.integer,
  citation_issued                   = as.logical,
  warning_issued                    = as.logical,
  arrest_made                       = as.logical,
  frisk_performed                   = as.logical,
  search_person                     = as.logical,
  search_vehicle                    = as.logical,
  contraband_drugs                  = as.logical,
  contraband_weapons                = as.logical,
  reason_for_search                 = as.character,
  reason_for_frisk                  = as.character,
  reason_for_arrest                 = as.character,
  use_of_force_description          = as.character,
  use_of_force_reason               = as.character,
  complaint_filed_by_subject        = as.logical,
  notes                             = as.character
)


# NOTE: these are to enforce consistent treatment; i.e. if search_conducted
# was marked FALSE, but search_type had a value, assume search_conducted
# takes precedence as it is more general
predicated_columns <- list(
  search_type = list(predicate = "search_conducted", if_not = NA),
  reason_for_search = list(predicate = "search_conducted", if_not = NA),
  reason_for_arrest = list(predicate = "arrest_made", if_not = NA),
  contraband_drugs = list(predicate = "contraband_found", if_not = FALSE),
  contraband_weapons = list(predicate = "contraband_found", if_not = FALSE)
)

# NOTE: these are dependencies for reporting null rates only,
# i.e. contraband_weapons null rate will only be the null rate
# only where contraband_found is TRUE
reporting_predicated_columns <- c(
  search_type = "search_conducted",
  reason_for_search = "search_conducted",
  reason_for_arrest = "arrest_made",
  contraband_found = "search_conducted",
  contraband_weapons = "contraband_found",
  contraband_drugs = "contraband_found"
)
