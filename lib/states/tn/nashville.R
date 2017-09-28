source("lib/schema.R")

opp_load <- function() {
  tbls <- list()
  # for (year in 2010:2016) {
  for (year in 2010:2011) {
    filename = str_c("data/states/tn/nashville/traffic_stop_", year, ".csv")
    tbls[[length(tbls) + 1]] <- read_csv(filename,
      col_names = c(
        "stop_number",
        "stop_datetime",
        "related_incident_number",
        "stop_location",
        "officer_employee_number",
        "stop_type",
        "race",
        "sex",
        "county_resident",
        "vehicle_tag_state",
        "verbal_warning_issued",
        "written_warning_issued",
        "traffic_citation_issued",
        "misd_state_citation_issued",
        "custodial_arrest_issued",
        "officers_comments",
        "age_of_suspect",
        "related_mov_vio_number",
        "zone",
        "vehicle_tag_number",
        "crime_reduction_initiative",
        "reporting_area",
        "suspect_ethnicity",
        "action_against_driver",
        "action_against_passenger",
        "search_occured",
        "evidence_seized",
        "drugs_seized",
        "weapons_seized",
        "other_seized",
        "vehicle_searched",
        "pat_down_search",
        "driver_searched",
        "passenger_searched",
        "search_consent",
        "search_probable_cause",
        "search_arrest",
        "search_warrant",
        "search_inventory",
        "search_plain_view",
        "id"
      ),
      col_types = cols(
        stop_number                     = col_integer(),
        stop_datetime                   = col_datetime(),
        related_incident_number         = col_character(),
        stop_location                   = col_character(),
        officer_employee_number         = col_integer(),
        stop_type                       = col_factor(NULL, include_na = TRUE),
        race                            = col_factor(NULL, include_na = TRUE),
        sex                             = col_factor(NULL, include_na = TRUE),
        county_resident                 = col_factor(NULL, include_na = TRUE),
        vehicle_tag_state               = col_factor(valid_states,
                                                     include_na = TRUE),
        verbal_warning_issued           = col_factor(NULL, include_na = TRUE),
        written_warning_issued          = col_factor(NULL, include_na = TRUE),
        traffic_citation_issued         = col_factor(NULL, include_na = TRUE),
        misd_state_citation_issued      = col_factor(NULL, include_na = TRUE),
        custodial_arrest_issued         = col_factor(NULL, include_na = TRUE),
        officers_comments               = col_character(),
        age_of_suspect                  = col_integer(),
        related_mov_vio_number          = col_integer(),
        zone                            = col_character(),
        vehicle_tag_number              = col_integer(),
        crime_reduction_initiative      = col_factor(NULL, include_na = TRUE),
        reporting_area                  = col_character(),
        suspect_ethnicity               = col_factor(NULL, include_na = TRUE),
        action_against_driver           = col_factor(NULL, include_na = TRUE),
        action_against_passenger        = col_factor(NULL, include_na = TRUE),
        search_occured                  = col_factor(NULL, include_na = TRUE),
        evidence_seized                 = col_factor(NULL, include_na = TRUE),
        drugs_seized                    = col_factor(NULL, include_na = TRUE),
        weapons_seized                  = col_factor(NULL, include_na = TRUE),
        other_seized                    = col_factor(NULL, include_na = TRUE),
        vehicle_searched                = col_factor(NULL, include_na = TRUE),
        pat_down_search                 = col_factor(NULL, include_na = TRUE),
        driver_searched                 = col_factor(NULL, include_na = TRUE),
        passenger_searched              = col_factor(NULL, include_na = TRUE),
        search_consent                  = col_factor(NULL, include_na = TRUE),
        search_probable_cause           = col_factor(NULL, include_na = TRUE),
        search_arrest                   = col_factor(NULL, include_na = TRUE),
        search_warrant                  = col_factor(NULL, include_na = TRUE),
        search_inventory                = col_factor(NULL, include_na = TRUE),
        search_plain_view               = col_factor(NULL, include_na = TRUE),
        id                              = col_integer()
      ),
      skip = 1
    )
  }
  bind_rows(tbls)
}

opp_clean <- function(tbl) {
  tbl
}

opp_save <- function(tbl) {
}
