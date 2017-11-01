source("lib/schema.R")
source("lib/utils.R")


path_prefix <- "data/states/tn/nashville/"


opp_load <- function() {
  tbls <- list()
  raw_csv_path_prefix = str_c(path_prefix, "/raw_csv/")
  for (year in 2010:2016) {
    filename <- str_c(raw_csv_path_prefix, "traffic_stop_", year, ".csv")
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
        "search_occurred",
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
        search_occurred                 = col_character(),
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
  add_lat_lng(bind_rows(tbls), "stop_location", path_prefix)
}


opp_clean <- function(tbl) {
  yn_to_tf <- c(Y = TRUE, N = FALSE)
  tr_race <- c(A = "asian/pacific islander",
               B = "black",
               H = "hispanic",
               I = "other/unknown",
               O = "other/unknown",
               U = "other/unknown",
               W = "white")
  tbl %>%
    rename(incident_id = stop_number,
           incident_location = stop_location,
           defendant_race = race,
           incident_lat = lat,
           incident_lng = lng,
           # TODO(journalist):
           # https://app.asana.com/0/456927885748233/462732257741346
           reason_for_stop = stop_type,
           search_conducted = search_occurred,
           arrest_made = custodial_arrest_issued,
           # NOTE: not using misd_state_citation_issued
           citation_issued = traffic_citation_issued,
           defendant_sex = sex,
           defendant_age = age_of_suspect,
           officer_id = officer_employee_number,
           vehicle_registration_state = vehicle_tag_state,
           frisk_performed = pat_down_search,
           search_driver = driver_searched,
           search_passenger = passenger_searched,
           search_incident_to_arrest = search_arrest
          ) %>%
    separate(stop_datetime, c("incident_date", "incident_time"),
             sep = " ", extra = "merge"
            ) %>%
    mutate(incident_id = as.character(incident_id),
           incident_type = factor("vehicular", levels = valid_incident_types),
           incident_date = parse_date(incident_date, "%m/%d/%Y"),
           incident_time = parse_time(incident_time, "%I:%M:%S %p"),
           incident_lat = parse_double(incident_lat),
           incident_lng = parse_double(incident_lng),
           defendant_race = factor(tr_race[ifelse(suspect_ethnicity == "H",
                                                  "H",
                                                  defendant_race)],
                                   levels = valid_races),
           county_resident = yn_to_tf[county_resident],
           verbal_warning_issued = yn_to_tf[verbal_warning_issued],
           written_warning_issued = yn_to_tf[written_warning_issued],
           citation_issued = yn_to_tf[citation_issued],
           misd_state_citation_issued = yn_to_tf[misd_state_citation_issued],
           arrest_made = yn_to_tf[arrest_made],
           action_against_driver = yn_to_tf[action_against_driver],
           search_conducted = yn_to_tf[search_conducted],
           evidence_seized = yn_to_tf[evidence_seized],
           drugs_seized = yn_to_tf[drugs_seized],
           weapons_seized = yn_to_tf[weapons_seized],
           other_seized = yn_to_tf[other_seized],
           contraband_found = any(evidence_seized,
                                  drugs_seized,
                                  weapons_seized,
                                  other_seized),
           # NOTE: invalid states converted to NAs
           vehicle_registration_state = factor(vehicle_registration_state,
                                               levels = valid_states),
           vehicle_searched = yn_to_tf[vehicle_searched],
           frisk_performed = yn_to_tf[frisk_performed],
           search_driver = yn_to_tf[search_driver],
           search_passenger = yn_to_tf[search_passenger],
           search_consent = yn_to_tf[search_consent],
           search_probable_cause = yn_to_tf[search_probable_cause],
           search_incident_to_arrest = yn_to_tf[search_incident_to_arrest],
           search_warrant = yn_to_tf[search_warrant],
           search_inventory = yn_to_tf[search_inventory],
           search_plain_view = yn_to_tf[search_plain_view],
           search_type = factor(c("plain view",
                                  "consent",
                                  "probable cause",
                                  "incident to arrest")[min(which(c(
                                  search_plain_view,
                                  search_consent,
                                  any(search_driver,
                                      search_passenger,
                                      search_probable_cause,
                                      search_warrant,
                                      search_inventory),
                                  search_incident_to_arrest
                                  )))],
                                levels = valid_search_types)
          ) %>%
    replace_na(list(misd_state_citation_issued = FALSE)
              ) %>%
    select(incident_id,
           incident_type,
           incident_date,
           incident_time,
           incident_location,
           incident_lat,
           incident_lng,
           defendant_race,
           reason_for_stop,
           search_conducted,
           search_type,
           contraband_found,
           arrest_made,
           citation_issued,
           everything()
           )
}


opp_save <- function(tbl) {
  save_clean_csv(tbl, path_prefix, "nashville")
}
