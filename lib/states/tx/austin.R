source("lib/common.R")

load_raw <- function(raw_data_dir, geocodes_path) {
  tbl <- read_csv_with_types(str_c(raw_data_dir, "data.csv"), c(
    street_check_case_number          = "c",
    occurred_date                     = "c",
    officer                           = "c",
    reason_checked                    = "c",
    street_check_type                 = "c",
    sex                               = "c",
    race                              = "c",
    ethnicity                         = "c",
    yob                               = "i",
    person_search_race_known          = "c",
    person_search_reason_for_stop     = "c",
    person_search_search_based_on     = "c",
    person_search_search_discovered   = "c",
    person_searched                   = "c",
    veh_type                          = "i",
    veh_year                          = "i",
    veh_make                          = "c",
    veh_model                         = "c",
    veh_style                         = "c",
    soi                               = "c",
    vehicle_search_race_known         = "c",
    vehicle_search_reason_for_stop    = "c",
    vehicle_search_search_based_on    = "c",
    vehicle_search_search_discovered  = "c",
    vehicle_searched                  = "c"
  ))

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
  tr_race = c(
    A = "asian/pacific islander",
    B = "black",
    I = "other/unknown",
    M = "other/unknown",
    P = "other/unknown",
    U = "other/unknown",
    W = "white"
  )

  tbl %>%
    rename(
      incident_id = street_check_case_number,
      incident_date = occurred_date,
      officer_id = officer,
      reason_checked_code = reason_checked,
      street_check_type_code = street_check_type,
      subject_sex = sex,
      subject_race = race,
      subject_ethnicity = ethnicity,
      subject_yob = yob,
      search_person = person_searched,
      search_vehicle = vehicle_searched,
      vehicle_type = veh_type,
      vehicle_year = veh_year,
      vehicle_make = veh_make,
      vehicle_model = veh_model,
      vehicle_style = veh_style,
      vehicle_code = soi
    ) %>%
    merge_rows(
      incident_id
    ) %>%
    mutate(
      # TODO(danj): looks like there are some random types here
      incident_type = "vehicular",
      incident_date = parse_date(incident_date, dt_fmt),
      subject_sex = tr_sex[subject_sex],
      subject_race = tr_race[subject_race],
      # TODO(danj): is this the right reason?
      reason_for_stop = person_search_reason_for_stop,
      person_search_race_known = matches(person_search_race_known, "YES"),
      search_person = matches(search_person, "YES"),
      vehicle_search_race_known = matches(vehicle_search_race_known, "YES"),
      search_vehicle = matches(search_vehicle, "YES"),
      search_conducted = search_person | search_vehicle,
      # TODO(danj): check this
      search_type = ifelse(search_conducted, "probable cause", NA)
    )
}
