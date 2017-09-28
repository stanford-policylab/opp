source("lib/schema.R")

opp_load <- function() {
  tbls <- list()
  for (year in 2010:2016) {
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
        stop_number                     = col_number(),
        stop_datetime                   = col_character(),
        related_incident_number         = col_character(),
        stop_location                   = col_character(),
        officer_employee_number         = col_number(),
        stop_type                       = col_character(),
        race                            = col_character(),
        sex                             = col_character(),
        county_resident                 = col_character(),
        vehicle_tag_state               = col_character(),
        verbal_warning_issued           = col_character(),
        written_warning_issued          = col_character(),
        traffic_citation_issued         = col_character(),
        misd_state_citation_issued      = col_character(),
        custodial_arrest_issued         = col_character(),
        officers_comments               = col_character(),
        age_of_suspect                  = col_number(),
        related_mov_vio_number          = col_character(),
        zone                            = col_character(),
        vehicle_tag_number              = col_character(),
        crime_reduction_initiative      = col_character(),
        reporting_area                  = col_character(),
        suspect_ethnicity               = col_character(),
        action_against_driver           = col_character(),
        action_against_passenger        = col_character(),
        search_occured                  = col_character(),
        evidence_seized                 = col_character(),
        drugs_seized                    = col_character(),
        weapons_seized                  = col_character(),
        other_seized                    = col_character(),
        vehicle_searched                = col_character(),
        pat_down_search                 = col_character(),
        driver_searched                 = col_character(),
        passenger_searched              = col_character(),
        search_consent                  = col_character(),
        search_probable_cause           = col_character(),
        search_arrest                   = col_character(),
        search_warrant                  = col_character(),
        search_inventory                = col_character(),
        search_plain_view               = col_character(),
        id                              = col_number()
      ),
      skip = 1
    )
  }
  bind_rows(tbls)
}

opp_clean <- function(tbl) {
  yn_to_tf <- c(Y = TRUE, N = FALSE)
  tbl %>%
    separate(stop_datetime, c("date", "time"), sep = " ", extra = "merge") %>%
    mutate(date = parse_date(date, "%m/%d/%Y"),
           time = parse_time(time, "%I:%M:%S %p"),
           county_resident = yn_to_tf[county_resident],
           verbal_warning_issued = yn_to_tf[verbal_warning_issued],
           written_warning_issued = yn_to_tf[written_warning_issued],
           traffic_citation_issued = yn_to_tf[traffic_citation_issued],
           misd_state_citation_issued = yn_to_tf[misd_state_citation_issued],
           custodial_arrest_issued = yn_to_tf[custodial_arrest_issued],
           action_against_driver = yn_to_tf[action_against_driver],
           search_occurred = yn_to_tf[search_occured],
           evidence_seized = yn_to_tf[evidence_seized],
           drugs_seized = yn_to_tf[drugs_seized],
           weapons_seized = yn_to_tf[weapons_seized],
           other_seized = yn_to_tf[other_seized],
           vehicle_searched = yn_to_tf[vehicle_searched],
           pat_down_search = yn_to_tf[pat_down_search],
           driver_searched = yn_to_tf[driver_searched],
           passenger_searched = yn_to_tf[passenger_searched],
           search_consent = yn_to_tf[search_consent],
           search_probable_cause = yn_to_tf[search_probable_cause],
           search_arrest = yn_to_tf[search_arrest],
           search_warrant = yn_to_tf[search_warrant],
           search_inventory = yn_to_tf[search_inventory],
           search_plain_view = yn_to_tf[search_plain_view])
}


opp_save <- function(tbl) {
}
