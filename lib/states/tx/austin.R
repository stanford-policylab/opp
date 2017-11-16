load_raw <- function(raw_data_dir, geocodes_path) {
  tbl <- read_csv(str_c(raw_data_dir, "data.csv"),
    col_names = c(
      "street_check_case_number",
      "occurred_date",
      "officer",
      "reason_checked",       # can be more than 1
      "street_check_type",    # can be more than 1
      "sex",
      "race",
      "ethnicity",
      "yob",
      "person_search_race_known",
      "person_search_reason_for_stop",
      "person_search_search_based_on",
      "person_search_search_discovered",
      "person_searched",
      "veh_type",
      "veh_year",
      "veh_make",
      "veh_model",
      "veh_style",
      "soi",
      "vehicle_search_race_known",
      "vehicle_search_reason_for_stop",
      "vehicle_search_search_based_on",
      "vehicle_search_search_discovered",
      "vehicle_searched"
    ),
    col_types = cols(
      street_check_case_number          = col_character(),
      occurred_date                     = col_date(),
      officer                           = col_character(),
      reason_checked                    = col_character(),
      street_check_type                 = col_character(),
      sex                               = col_character(),
      race                              = col_character(),
      ethnicity                         = col_character(),
      yob                               = col_integer(),
      person_search_race_known          = col_character(),
      person_search_reason_for_stop     = col_character(),
      person_search_search_based_on     = col_character(),
      person_search_search_discovered   = col_character(),
      person_searched                   = col_character(),
      veh_type                          = col_integer(),
      veh_year                          = col_integer(),
      veh_make                          = col_character(),
      veh_model                         = col_character(),
      veh_style                         = col_character(),
      soi                               = col_character(),
      vehicle_search_race_known         = col_character(),
      vehicle_search_reason_for_stop    = col_character(),
      vehicle_search_search_based_on    = col_character(),
      vehicle_search_search_discovered  = col_character(),
      vehicle_searched                  = col_character()
    ),
    skip = 1
  )


  r <- function(fname) { read_csv(str_c(raw_data_dir, fname)) }

  reason_codes <- r("reason_checked_code_lookup.csv")
  race_codes <- r("race_code_lookup.csv")
  street_codes <- r("street_check_type_code_lookup.csv")
  vehicle_codes <- r("vehicle_code_lookup.csv")
  vehicle_type_codes <- r("vehicle_type_code_lookup.csv")

  left_join(tbl, reason_codes,
            by = c("reason_checked" = "reason_checked_code")
  ) %>%
  left_join(race_codes,
            by = c("race" = "race_code")
  ) %>%
  left_join(street_codes,
            by = c("street_check_type" = "street_check_type_code")
  ) %>%
  left_join(vehicle_codes,
            by = c("soi" = "vehicle_code")
  ) %>%
  left_join(vehicle_type_codes,
            by = c("veh_type" = "vehicle_type_code")
  )
}


clean <- function(tbl) {
  dt_fmt = "%Y/%m/%d"
  tm_fmt = "%H:%M:%S"
  tr_race = c(
    A = "asian/pacific islander",
    B = "black",
    H = "hispanic",
    U = "other/unknown",
    W = "white"
  )
  tr_sex = c(
    F = "female",
    M = "male"
  )

  tbl %>%
    rename(
      incident_id = street_check_case_number,
      incident_date = occurred_date,
      officer_id = officer,
      reason_checked_code = reason_checked,
      street_check_type = street_check_type_code,
      defendant_sex = sex,
      defendant_race = race,
      year_of_birth = yob
    ) %>%
    mutate(
      person_searched = if_else(is.na(str_match(person_searched, "YES"),
                                FALSE, TRUE)),
      vehicle_searched = if_else(is.na(str_match(vehicle_searched, "YES"),
                                 FALSE, TRUE))
    )

  # tbl %>%
  #   select(
  #     incident_id,
  #     incident_type,
  #     incident_date,
  #     incident_time,
  #     incident_location,
  #     incident_lat,
  #     incident_lng,
  #     defendant_race,
  #     reason_for_stop,
  #     search_conducted,
  #     search_type,
  #     contraband_found,
  #     arrest_made,
  #     citation_issued,
  #     everything()
  #   )
}
