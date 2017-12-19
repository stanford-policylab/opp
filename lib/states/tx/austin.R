source("common.R")

load_raw <- function(raw_data_dir, geocodes_path) {
  loading_problems <- list()
  fname <- "data.csv"
  data <- read_csv_with_types(
    file.path(raw_data_dir, "data.csv"),
    c(
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
    )
  )
  loading_problems[[fname]] <- problems(data)

  r <- function(fname) {
    tbl <- read_csv(file.path(raw_data_dir, fname))
    loading_problems[[fname]] <<- problems(tbl)
    tbl
  }

  reason_checked_tr <- translator_from_tbl(
    r("reason_checked_code_lookup.csv"),
    "reason_checked_code",
    "reason_checked_description"
  )
  race_tr <- translator_from_tbl(
    r("race_code_lookup.csv"),
    "race_code",
    "race_description"
  )
  street_check_tr <- translator_from_tbl(
    r("street_check_type_code_lookup.csv"),
    "street_check_type_code",
    "street_check_description"
  )
  vehicle_style_tr <- translator_from_tbl(
    r("vehicle_style_code_lookup.csv"),
    "vehicle_style_code",
    "vehicle_style_description"
  )
  vehicle_type_tr <- translator_from_tbl(
    r("vehicle_type_code_lookup.csv"),
    "vehicle_type_code",
    "vehicle_type_description"
  )
  data <- mutate(
    data,
    reason_checked_description = reason_checked_tr[reason_checked],
    race_description = race_tr[race],
    street_check_description = street_check_tr[street_check_type],
    vehicle_style_description = vehicle_style_tr[veh_style],
    vehicle_type_description = vehicle_type_tr[veh_type]
  )

  list(data = data, metadata = list(loading_problems = loading_problems))
}


clean <- function(d) {
  dt_fmt = "%Y/%m/%d"
  tr_race = c(
    A = "asian/pacific islander",
    B = "black",
    H = "hispanic",
    I = "other/unknown",
    M = "other/unknown",
    P = "other/unknown",
    U = "other/unknown",
    W = "white"
  )

  d$data %>%
    rename(
      incident_id = street_check_case_number,
      incident_date = occurred_date,
      officer_id = officer,
      reason_checked_code = reason_checked,
      reason_for_stop = reason_checked_description,
      street_check_type_code = street_check_type,
      subject_sex = sex,
      subject_race = race,
      subject_ethnicity = ethnicity,
      subject_yob = yob,
      search_person = person_searched,
      search_person_race_known_before_stop = person_search_race_known,
      search_person_discovered = person_search_search_discovered,
      search_vehicle = vehicle_searched,
      search_vehicle_race_known_before_stop = vehicle_search_race_known,
      search_vehicle_discovered = vehicle_search_search_discovered,
      vehicle_type = veh_type,
      vehicle_year = veh_year,
      vehicle_make = veh_make,
      vehicle_model = veh_model,
      vehicle_style = veh_style,
      vehicle_registration_state = soi
    ) %>%
    merge_rows(
      incident_id
    ) %>%
    mutate(
      search_person = matches(search_person, "YES"),
      search_vehicle = matches(search_vehicle, "YES"),
      search_conducted = search_person | search_vehicle,
      # TODO(danj): verify logic with Ravi
      incident_type = ifelse(
        search_vehicle | matches(reason_for_stop, "VEHICLE"),
        "vehicular",
        "pedestrian"
      ),
      incident_date = parse_date(incident_date, dt_fmt),
      subject_sex = tr_sex[subject_sex],
      # TODO(danj): N in ethnicity was highest, H second, what is N?
      subject_race =
        tr_race[ifelse(subject_ethnicity == "H", "H", subject_race)],
      search_person_race_known_before_stop =
        matches(search_person_race_known_before_stop, "YES"),
      search_vehicle_race_known_before_stop =
        matches(search_vehicle_race_known_before_stop, "YES"),
      search_consent = any_matches(
        "CONSENT",
        search_person_search_based_on,
        search_vehicle_search_based_on
      ),
      search_plain_view = any_matches(
        "PLAIN VIEW",
        search_person_search_based_on,
        search_vehicle_search_based_on
      ),
      search_incident_to_arrest = any_matches(
        "INCIDENTAL",
        search_person_search_based_on,
        search_vehicle_search_based_on
      ),
      frisk_performed = any_matches(
        "FRISK",
        search_person_search_based_on,
        search_vehicle_search_based_on
      ),
      search_probable_cause = any_matches(
        "PROBABLE",
        search_person_search_based_on,
        search_vehicle_search_based_on
      ),
      search_type = first_of(
        "plain view" = search_plain_view,
        "consent" = search_consent,
        "probable cause" = search_probable_cause,
        "incident to arrest" = search_incident_to_arrest,
        "probable cause" = search_conducted  # default
      ),
      contraband_found = any_matches(
        # TODO(danj): include alcohol, other?
        "ALCOHOL|CASH|DRUGS|OTHER|WEAPONS",
        search_person_search_discovered,
        search_vehicle_search_discovered
      ),
      contraband_recovered_from_search = str_combine(
        search_person_discovered, search_vehicle_discovered,
        prefix_left = "subject=", prefix_right = "vehicle="
      )
    ) %>%
    standardize(d$metadata)
}
