library(functional)
library(readr)
library(lubridate)


valid_start_date <- parse_date("2000-01-01")
valid_end_date <- parse_date(Sys.Date())


valid_vehicle_start_year <- 1800
# NOTE: end year depends on stop date


valid_age_start <- 10
valid_age_end <- 110


valid_types <- c(
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


schema <- c(
  # back-reference
  raw_row_number                = as.numeric,

  # when
  date                          = parse_date,
  time                          = parse_time,

  # where
  location                      = as.character,
  lat                           = as.numeric,
  lng                           = as.numeric,
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
  sector                        = as.character,
  service_area                  = as.character,
  zone                          = as.character,

  # who
  subject_age                   = as.numeric,
  subject_dob                   = as.Date,
  subject_race                  = Curry(factor, levels = valid_races),
  subject_sex                   = Curry(factor, levels = valid_sexes),
  officer_id                    = as.character,
  officer_age                   = as.numeric,
  officer_dob                   = as.Date,
  officer_race                  = Curry(factor, levels = valid_races),
  officer_sex                   = Curry(factor, levels = valid_sexes),
  officer_first_name            = as.character,
  officer_last_name             = as.character,
  officer_years_of_service      = as.numeric,
  department_id                 = as.character,
  department_name               = as.character,

  # what
  type                          = Curry(factor, levels = valid_types),
  # NOTE: violation here is used for charge and violation
  disposition                   = as.character,
  violation                     = as.character,
  arrest_made                   = as.logical,
  citation_issued               = as.logical,
  warning_issued                = as.logical,
  outcome                       = Curry(factor, levels = valid_outcomes),
  contraband_found              = as.logical,
  contraband_drugs              = as.logical,
  contraband_weapons            = as.logical,
  frisk_performed               = as.logical,
  search_conducted              = as.logical,
  search_person                 = as.logical,
  search_vehicle                = as.logical,
  search_type                   = Curry(factor, levels = valid_search_types),

  # why
  reason_for_arrest             = as.character,
  reason_for_frisk              = as.character,
  reason_for_search             = as.character,
  reason_for_stop               = as.character,

  # other
  use_of_force_description      = as.character,
  use_of_force_reason           = as.character,
  vehicle_color                 = as.character,
  vehicle_make                  = as.character,
  vehicle_model                 = as.character,
  vehicle_type                  = as.character,
  vehicle_registration_state    = Curry(factor, levels = valid_states),
  vehicle_year                  = as.integer,
  notes                         = as.character
)


# NOTE: these are to enforce consistent treatment; i.e. if search_conducted
# was marked FALSE, but search_type had a value, assume search_conducted
# takes precedence as it is more general
predicated_columns <- list(
  search_type = list(
    predicate = "search_conducted",
    if_not = schema$search_type(NA)
  ),
  reason_for_search = list(
    predicate = "search_conducted",
    if_not = NA_character_
  ),
  reason_for_arrest = list(
    predicate = "arrest_made",
    if_not = NA_character_
  ),
  contraband_drugs = list(
    predicate = "contraband_found",
    if_not = FALSE
  ),
  contraband_weapons = list(
    predicate = "contraband_found",
    if_not = FALSE
  )
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
