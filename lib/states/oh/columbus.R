load_raw <- function(raw_data_dir, geocodes_path) {
  d <- read_csv(str_c(raw_data_dir, "columbus_oh_data_sheet_1.csv"),
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
      "traffic_stop_street"
    ),
    # col_types = cols(
    #   incident_id           = col_character(),
    #   stop_date             = col_character(),
    #   contact_end_date      = col_character(),
    #   system_entry_date     = col_character(),
    #   type_of_stop          = col_character(),
    #   cruiser_district      = col_character(),
    #   stop_reason           = col_character(),
    #   enforcement_taken     = col_character(),
    #   gender                = col_character(),
    #   ethnicity             = col_character(),
    #   traffic_stop_street   = col_character()
    # ),
    skip = 1
  )


}

clean <- function(tbl) {
  tbl
}
