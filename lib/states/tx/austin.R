source("common.R")

load_raw <- function(raw_data_dir, n_max) {

  loading_problems <- list()
  r <- function(fname) {
    d <- load_single_file(raw_data_dir, fname, n_max = n_max)
    loading_problems <<- c(loading_problems, d$loading_problems)
    d$data
  }

  data <- r("data.csv")
  colnames(data) <- make_ergonomic(colnames(data))
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
    reason_checked_description = translate_by_char(
      # NOTE: reason checked sometimes contains spaces, which are not entries
      str_replace_all(reason_checked_more_than_1_entry_allowed, " ", ""),
      reason_checked_tr
    ),
    race_description = race_tr[race],
    street_check_description = translate_by_char(
      street_check_type_more_than_1_entry_allowed,
      street_check_tr,
    ),
    vehicle_style_description = vehicle_style_tr[veh_style],
    vehicle_type_description = vehicle_type_tr[veh_type]
  ) %>%
  bundle_raw(loading_problems)
}


clean <- function(d, helpers) {

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
      date = parse_date(date, "%Y/%m/%d"),
      subject_race = tr_race[if_else_na(
        subject_ethnicity == "H",
        "H",
        subject_race
      )],
      subject_sex = tr_sex[subject_sex],
      subject_age = year(date) - as.integer(yob),
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
      search_basis = first_of(
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
        "other" = any_matches(
          "INCIDENTAL|INVENTORY",
          person_search_search_based_on,
          vehicle_search_search_based_on
        ),
        "probable cause" = any_matches(
          "PROBABLE",
          person_search_search_based_on,
          vehicle_search_search_based_on
        )
        | search_conducted  # default
      ),
      frisk_performed = any_matches(
        "FRISK",
        person_search_search_based_on,
        vehicle_search_search_based_on
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
      ),
      contraband_found = contraband_drugs | contraband_weapons
    ) %>%
    # TODO(danj): add shapefiles after location given
    # https://app.asana.com/0/456927885748233/743595706194913 
    standardize(d$metadata)
}
