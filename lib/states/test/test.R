source("lib/schema.R")

opp_load <- function() {
  read_csv("data/states/test/test.csv",
    col_names = c(
      "case_number",
      "incident_type",
      "incident_date",
      "incident_time",
      "incident_location",
      "incident_lat",
      "incident_long",
      "defendant_gender",
      "defendant_race",
      "defendant_dob",
      "officer_first_name",
      "officer_last_name",
      "officer_id",
      "officer_gender",
      "officer_race",
      "officer_dob",
      "officer_years_of_service",
      "vehicle_year",
      "vehicle_color",
      "vehicle_make",
      "vehicle_style",
      "vehicle_registration_state"
    ),
    col_types = cols(
      case_number                   = col_integer(),
      incident_type                 = col_factor(valid_incident_types),
      incident_date                 = col_date(),
      incident_time                 = col_time(),
      incident_location             = col_character(),
      incident_lat                  = col_double(),
      incident_long                 = col_double(),
      defendant_gender              = col_factor(valid_genders),
      defendant_race                = col_factor(valid_races),
      defendant_dob                 = col_date(),
      officer_first_name            = col_character(),
      officer_last_name             = col_character(),
      officer_id                    = col_integer(),
      officer_gender                = col_factor(valid_genders),
      officer_race                  = col_factor(valid_races),
      officer_dob                   = col_date(),
      officer_years_of_service      = col_double(),
      vehicle_year                  = col_factor(valid_vehicle_years),
      vehicle_color                 = col_character(),
      vehicle_make                  = col_character(),
      vehicle_style                 = col_character(),
      vehicle_registration_state    = col_factor(valid_states)
    ),
    skip = 1
  )
}

opp_clean <- function(tbl) {
  tbl
}

opp_save <- function(tbl) {
}
