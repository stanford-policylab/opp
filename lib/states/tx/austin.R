source("common.R")

load_raw <- function(raw_data_dir, n_max) {
  loading_problems <- list()
  fname <- "data.csv"
  data <- read_csv_with_types(
    file.path(raw_data_dir, fname),
    n_max = n_max,
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

  mutate(
    data,
    reason_checked_description = reason_checked_tr[reason_checked],
    race_description = race_tr[race],
    street_check_description = street_check_tr[street_check_type],
    vehicle_style_description = vehicle_style_tr[veh_style],
    vehicle_type_description = vehicle_type_tr[veh_type]
  ) %>%
  bundle_raw(loading_problems)
}


clean <- function(d, helpers) {
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

  # TODO(phoebe): can we get location and outcome?
  # https://app.asana.com/0/456927885748233/507608374034702/f
  d$data %>%
    merge_rows(
      street_check_case_number
    ) %>%
    rename(
      date = occurred_date,
      reason_for_stop = reason_checked_description,
      subject_race = race,
      subject_ethnicity = ethnicity,
      subject_sex = sex,
      search_person = person_searched,
      search_vehicle = vehicle_searched,
      officer_id = officer,
      vehicle_year = veh_year,
      vehicle_make = veh_make,
      vehicle_model = veh_model,
      vehicle_registration_state = soi
    ) %>%
    mutate(
      date = parse_date(date, dt_fmt),
      subject_race = tr_race[ifelse(
        !is.na(subject_ethnicity) & subject_ethnicity == "H",
        "H",
        subject_race
      )],
      subject_sex = tr_sex[subject_sex],
      subject_age = as.integer(format(date, "%Y")) - as.integer(yob),
      search_person = str_detect(search_person, "YES"),
      search_vehicle = str_detect(search_vehicle, "YES"),
      search_conducted = search_person | search_vehicle,
      # NOTE: SUSPICIOUS PERSON / VEHICLE is one category, so this will
      # pick up some suspicious persons unfortunately
      type = first_of(
        "vehicular" = search_vehicle | str_detect(reason_for_stop, "VEHICLE"),
        "pedestrian" = TRUE  # default if not vehicular
      ),
      # TODO(phoebe): we appear to lose about 10% by predicating on search
      # https://app.asana.com/0/456927885748233/548400265824560 
      search_type = first_of(
        "plain view" = any_matches(
          "PLAIN VIEW",
          person_search_search_based_on,
          vehicle_search_search_based_on
        ),
        "consent" = any_matches(
          "CONSENT",
          person_search_search_based_on,
          vehicle_search_search_based_on
        ),
        "non-discretionary" = any_matches(
          "INCIDENTAL|INVENTORY",
          person_search_search_based_on,
          vehicle_search_search_based_on
        ),
        "probable cause" = any_matches(
          "PROBABLE",
          person_search_search_based_on,
          vehicle_search_search_based_on
        ) | search_conducted  # default
      ),
      frisk_performed = any_matches(
        "FRISK",
        person_search_search_based_on,
        vehicle_search_search_based_on
      ),
      contraband_found = any_matches(
        "ALCOHOL|CASH|DRUGS|OTHER|WEAPONS",
        person_search_search_discovered,
        vehicle_search_search_discovered
      ),
      contraband_drugs = any_matches(
        "DRUGS",
        person_search_search_discovered,
        vehicle_search_search_discovered
      ),
      contraband_weapons = any_matches(
        "WEAPONS",
        person_search_search_discovered,
        vehicle_search_search_discovered
      )
    ) %>%
    standardize(d$metadata)
}
