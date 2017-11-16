load_raw <- function(raw_data_dir, geocodes_path) {
  tbl <- read_csv(str_c(raw_data_dir, "columbus_oh_data_sheet_1.csv"),
    col_names = c(
      "incident_id",
      "stop_date",
      "contact_end_date",
      "system_entry_date",
      "type_of_stop",
      "cruiser_district",
      "stop_reason",
      "enforcement_taken",
      "gender",
      "ethnicity",
      "traffic_stop_street",
      "traffic_stop_cross_street",
      "violation_street",
      "violation_cross_street"
    ),
    skip = 1
  )

  # NOTE: normally mutates are reserved for cleaning, but
  # here it's required to join to geolocation data
  # TODO(danj): is this the right address to use?
  tbl <- mutate(tbl, incident_location = str_trim(str_c(violation_street,
                                                  violation_cross_street,
                                                  sep = " and ")))

  add_lat_lng(tbl, "incident_location", geocodes_path)
}


clean <- function(tbl) {
  dt_fmt = "%Y/%m/%d"
  tm_fmt = "%H:%M:%S"
  tr_race = c(
    Asian = "asian/pacific islander",
    Black = "black",
    Hispanic = "hispanic",
    Other = "other/unknown",
    White = "white"
  )
  tr_sex = c(FEMALE = "female", MALE = "male")

  tbl %>%
    rename(
      incident_lat = lat,
      incident_lng = lng,
      stop_road_type = type_of_stop,
      reason_for_stop = stop_reason,
      defendant_race = ethnicity,
      defendant_sex = gender
    ) %>%
    separate(
      stop_date, c("incident_date", "incident_time"),
      sep = " ", extra = "merge"
    ) %>%
    separate(
      contact_end_date, c("contact_end_date", "contact_end_time"),
      sep = " ", extra = "merge"
    ) %>%
    separate(
      system_entry_date, c("system_entry_date", "system_entry_time"),
      sep = " ", extra = "merge"
    ) %>%
    mutate(
      incident_id = as.character(incident_id),
      incident_type = factor("vehicular", levels = valid_incident_types),
      incident_date = parse_date(incident_date, dt_fmt),
      incident_time = parse_time(incident_time, tm_fmt),
      contact_end_date = parse_date(contact_end_date, dt_fmt),
      contact_end_time = parse_time(contact_end_time, tm_fmt),
      system_entry_date = parse_date(system_entry_date, dt_fmt),
      system_entry_time = parse_time(system_entry_time, tm_fmt),
      defendant_race = factor(tr_race[defendant_race], levels = valid_races),
      defendant_sex = factor(tr_sex[defendant_sex], levels = valid_sexes),
      search_conducted = (enforcement_taken == "Vehicle Search"
                          | enforcement_taken == "Driver Search"),
      search_type = factor("probable cause", levels = valid_search_types), 
      contraband_found = as.logical(NA),
      arrest_made = enforcement_taken == "Arrest",
      # TODO(danj): include "Misd. Citation or Summons"?
      citation_issued = enforcement_taken == "Traffic Citation",
      warning_issued = enforcement_taken == "Verbal Warning"
    ) %>%
    select(
      incident_id,
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
