library(functional)
library(readr)
library(lubridate)


valid_start_date <- parse_date("1970-01-01")
valid_end_date <- parse_date(as.character(Sys.Date()))


valid_vehicle_start_year <- 1800
# NOTE: end year depends on stop date


valid_age_start <- 10
valid_age_end <- 110


valid_types <- c(
  "pedestrian",
  "vehicular"
)


# order they are likely to occur
valid_search_bases <- c(
  "k9",
  "plain view",
  "consent",
  "probable cause",
  "other"  # NOTE: arrest/warrant, probation/parole, inventory
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
  "white",
  "other",
  "unknown"
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


city_subgeographies <- quos(
  beat,
  district,
  subdistrict,
  division,
  subdivision,
  police_grid_number,
  precinct,
  region,
  reporting_area,
  sector,
  subsector,
  substation,
  service_area,
  zone
)


state_subgeographies <- quos(
  county_name,
  beat,
  department_id,
  department_name
)


schema <- c(
  # make character in case raw rows are merged, i.e. could be 1|2|3
  raw_row_number                = as.character,

  # when
  date                          = function(v) parse_date(as.character(v)),
  time                          = function(v) parse_time(as.character(v)),

  # where
  location                      = as.character,
  lat                           = as.numeric,
  lng                           = as.numeric,
  geocode_source                = as.character,
  county_name                   = as.character,
  neighborhood                  = as.character,
  beat                          = as.character,
  district                      = as.character,
  subdistrict                   = as.character,
  division                      = as.character,
  subdivision                   = as.character,
  police_grid_number            = as.character,
  precinct                      = as.character,
  region                        = as.character,
  reporting_area                = as.character,
  sector                        = as.character,
  subsector                     = as.character,
  substation                    = as.character,
  service_area                  = as.character,
  zone                          = as.character,

  # who
  subject_age                   = as.numeric,
  subject_dob                   = as.Date,
  subject_yob                   = as.integer,
  subject_race                  = Curry(factor, levels = valid_races),
  subject_sex                   = Curry(factor, levels = valid_sexes),
  subject_first_name            = as.character,
  subject_middle_name           = as.character,
  subject_last_name             = as.character,
  subject_drivers_license       = as.character,
  subject_drivers_license_state = as.character,
  officer_id                    = as.character,
  officer_id_hash               = as.character,
  officer_age                   = as.numeric,
  officer_dob                   = as.Date,
  officer_race                  = Curry(factor, levels = valid_races),
  officer_sex                   = Curry(factor, levels = valid_sexes),
  officer_first_name            = as.character,
  officer_last_name             = as.character,
  officer_years_of_service      = as.numeric,
  officer_assignment            = as.character,
  department_id                 = as.character,
  department_name               = as.character,
  unit                          = as.character,

  # what
  type                          = Curry(factor, levels = valid_types),
  disposition                   = as.character,
  # NOTE: violation here is used for charge, offense, statute, and/or violation
  violation                     = as.character,
  arrest_made                   = as.logical,
  citation_issued               = as.logical,
  warning_issued                = as.logical,
  outcome                       = Curry(factor, levels = valid_outcomes),
  contraband_found              = as.logical,
  contraband_drugs              = as.logical,
  contraband_weapons            = as.logical,
  contraband_alcohol            = as.logical,
  contraband_other              = as.logical,
  frisk_performed               = as.logical,
  search_conducted              = as.logical,
  search_person                 = as.logical,
  search_vehicle                = as.logical,
  search_basis                  = Curry(factor, levels = valid_search_bases),

  # why
  reason_for_arrest             = as.character,
  reason_for_frisk              = as.character,
  reason_for_search             = as.character,
  reason_for_stop               = as.character,

  # other
  speed                         = as.numeric,
  posted_speed                  = as.numeric,
  charged_speed                 = as.numeric,
  use_of_force_description      = as.character,
  use_of_force_reason           = as.character,
  vehicle_color                 = as.character,
  vehicle_license_plate         = as.character,
  vehicle_make                  = as.character,
  vehicle_model                 = as.character,
  vehicle_type                  = as.character,
  vehicle_registration_state    = Curry(factor, levels = valid_states),
  vehicle_year                  = as.integer,
  notes                         = as.character
)


# NOTE: these are to enforce consistent treatment; i.e. if search_conducted
# was marked FALSE, but search_basis had a value, assume search_conducted
# takes precedence as it is more general
predicated_columns <- list(
  search_basis = list(
    predicate = "search_conducted",
    if_not = schema$search_basis(NA)
  ),
  search_person = list(
    predicate = "search_conducted",
    if_not = FALSE
  ),
  search_vehicle = list(
    predicate = "search_conducted",
    if_not = FALSE
  ),
  reason_for_search = list(
    predicate = "search_conducted",
    if_not = NA_character_
  ),
  reason_for_frisk = list(
    predicate = "frisk_performed",
    if_not = NA_character_
  ),
  reason_for_arrest = list(
    predicate = "arrest_made",
    if_not = NA_character_
  ),
  contraband_found = list(
    predicate = "search_conducted",
    if_not = NA
  ),
  contraband_drugs = list(
    predicate = "contraband_found",
    if_not = FALSE
  ),
  contraband_weapons = list(
    predicate = "contraband_found",
    if_not = FALSE
  ),
  contraband_other = list(
    predicate = "contraband_found",
    if_not = FALSE
  )
)

# NOTE: these are dependencies for reporting null rates only,
# i.e. contraband_weapons null rate will only be the null rate
# only where contraband_found is TRUE
reporting_predicated_columns <- c(
  search_basis = "search_conducted",
  reason_for_search = "search_conducted",
  reason_for_arrest = "arrest_made",
  contraband_found = "search_conducted",
  contraband_weapons = "contraband_found",
  contraband_drugs = "contraband_found"
)


redact_for_public_release <- c(
  "subject_dob",
  "subject_yob",
  "officer_id",
  "officer_dob",
  "officer_first_name",
  "officer_last_name",
  "subject_first_name",
  "subject_middle_name",
  "subject_last_name",
  "subject_drivers_license",
  "subject_drivers_license_state",
  "vehicle_license_plate"
)
