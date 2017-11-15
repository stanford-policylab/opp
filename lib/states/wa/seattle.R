load_raw <- function(raw_data_dir, geocodes_path) {
  tbls <- list()
  for (year in 2006:2015) {
    filename <- str_c(raw_data_dir, "trafs_evs_", year, "_sheet_1.csv")
    tbls[[length(tbls) + 1]] <- read_csv(filename,
      col_names = c(
        "rin",
        "datetime",
        "address",
        "type",
        "pri",
        "mir_and_description",
        "disposition_description",
        "veh",
        "possible_race_and_sex",
        "subject_dob",
        "officer_no_name_1",
        "officer_no_name_2",
        "empty"
      ),
      col_types = cols(
        rin                         = col_character(),
        datetime                    = col_character(),
        address                     = col_character(),
        type                        = col_character(),
        pri                         = col_integer(),
        mir_and_description         = col_character(),
        disposition_description     = col_character(),
        veh                         = col_character(),
        possible_race_and_sex       = col_character(),
        subject_dob                 = col_character(),
        officer_no_name_1           = col_character(),
        officer_no_name_2           = col_character(),
        empty                       = col_character()
      ),
      skip = 1
    )
  }
  add_lat_lng(bind_rows(tbls), "address", geocodes_path)
}


clean <- function(tbl) {
  tr_race <- c(
    A = "asian/pacific islander",
    B = "black",
    H = "hispanic",
    W = "white"
  )

  tbl %>%
    select(
      -empty
    ) %>%
    rename(
      incident_id = rin,
      incident_location = address,
      incident_lat = lat,
      incident_lng = lng,
      # TODO(journalist): clarify relationship between
      # mir_and_description, disposition_description, type
      # https://app.asana.com/0/456927885748233/462732257741348 
      reason_for_stop = mir_and_description,
      defendant_dob = subject_dob
    ) %>%
    filter(
      !is.na(incident_id)
    ) %>%
    separate(
      datetime, c("incident_date", "incident_time"),
      sep = " ", extra = "merge"
    ) %>%
    separate(
      possible_race_and_sex, c("defendant_race", "defendant_sex"),
      sep = 1, extra = "merge"
    ) %>%
    separate(
      officer_no_name_1, c("officer_id_1", "officer_name_1"),
      sep = " ", extra = "merge"
    ) %>%
    separate(
      officer_no_name_2, c("officer_id_2", "officer_name_2"),
      sep = " ", extra = "merge"
    ) %>%
    mutate(
      incident_type = factor("vehicular", levels = valid_incident_types),
      # NOTE: vehicular because mir_and_description are all traffic
      incident_date = sanitize_incident_date(parse_date(incident_date,
                                                        "%Y/%m/%d")),
      incident_time = parse_time(incident_time, "%H:%M:%S"),
      incident_lat = parse_number(incident_lat),
      incident_lng = parse_number(incident_lng),
      defendant_race = factor(tr_race[defendant_race],
                              levels = valid_races),
      search_conducted = as.logical(NA),
      search_type = factor(NA, levels = valid_search_types),
      contraband_found = as.logical(NA),
      arrest_made = str_sub(disposition_description, 1, 1) == "A",
      # NOTE: includes criminal and non-criminal citations
      citation_issued = as.vector(!is.na(str_match(disposition_description,
                                                   "CITATION"))),
      defendant_dob = sanitize_dob(ymd(defendant_dob)),
      officer_id_1 = parse_number(officer_id_1),
      officer_id_2 = parse_number(officer_id_2)
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
