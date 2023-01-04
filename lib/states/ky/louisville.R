source("common.R")

load_raw <- function(raw_data_dir, n_max) {

  # original data
  stops <- load_single_file(raw_data_dir, "LMPD_STOPS_DATA_12.csv", n_max)
  cits <- load_single_file(raw_data_dir, "UniformCitationData.csv", n_max)

  # updated data 2020-08-31
  # same format as LMPD_STOPS_DATA_12.csv above
  stop_data <- load_single_file(raw_data_dir, "stops_data.csv", n_max)
  # same format as UniformCitationData.csv above
  arrests <- load_single_file(raw_data_dir, "arrests.csv", n_max)

  bundle_raw(
    make_ergonomic_colnames(
      bind_rows(
        left_join(stops$data, cits$data, by = "CITATION_CONTROL_NUMBER"),
        left_join(stop_data$data, arrests$data, by = "CITATION_CONTROL_NUMBER")
      )
    ),
    c(
      stops$loading_problems,
      cits$loading_problems,
      stop_data$loading_problems,
      arrests$loading_problems
    )
  )
}


clean <- function(d, helpers) {

  tr_race <- c(
    tr_race,
    "asian/pacific islander" = "asian/pacific islander",
    "middle eastern descent" = "other",
    "indian/india/burmese" = "other",
    "american indian" = "other",
    "alaskan native" = "other"
  )

  d$data %>%
  merge_rows(
    officer_gender,
    officer_race,
    officer_age_range,
    activity_date,
    activity_time,
    activity_location,
    activity_division,
    division,
    activity_beat,
    beat,
    driver_gender,
    persons_sex,
    driver_race,
    persons_race,
    persons_ethnicity,
    driver_age_range,
    persons_age,
    persons_home_city,
    persons_home_state,
    persons_home_zip
  ) %>%
  rename(
    subject_age = persons_age,
    location = activity_location,
    violation = charge_desc
  ) %>%
  add_raw_colname_prefix(
    activity_beat,
    activity_division,
    beat,
    citation_location,
    division,
    driver_age_range,
    driver_race,
    persons_ethnicity,
    persons_race,
    was_vehcile_searched
  ) %>%
  mutate(
    # NOTE: all stops are not null for at least one of the driver_* columns
    # or number_of_passengers or was_vehicle_searched columns, implying
    # it was a vehicle stop
    type = "vehicular",
    date = coalesce(
      parse_date(activity_date, "%m/%d/%Y"),
      parse_date(activity_date, "%Y/%m/%d")
    ),
    time = parse_time(activity_time),
    subject_sex = tr_sex[driver_gender],
    subject_race = tr_race[str_to_lower(raw_driver_race)],
    officer_sex = tr_sex[officer_gender],
    officer_race = tr_race[str_to_lower(officer_race)],
    division = coalesce(raw_activity_division, raw_division),
    beat = coalesce(raw_activity_beat, raw_beat),
    search_conducted = replace_na(tr_yn[raw_was_vehcile_searched], F),
    frisk_performed = replace_na(str_detect(reason_for_search, "TERRY|PAT"), F),
    search_basis = case_when(
      str_detect(reason_for_search, "K9|K-9|DOG") ~ "k9",
      str_detect(
        reason_for_search,
        str_c(
          "BAGGIES",
          "DRUGS",
          "GUN",
          "MARIJUANA",
          "ODOR",
          "PILLS",
          "PIPE",
          "PLAIN VIEW",
          "SMELL",
          sep = "|"
        )
      ) ~ "plain view",
      str_detect(reason_for_search, "CONSENT|CONSE") ~ "consent",
      str_detect(
        reason_for_search,
        str_c(
          "PROB",
          "P/C",
          "PC",
          "P.C.",
          sep = "|"
        )
      ) ~ "probable cause",
      T ~ "other"
    ),
    citation_issued = str_detect(activity_results, "CITATION"),
    warning_issued = str_detect(activity_results, "WARNING"),
    outcome = first_of(
      citation = citation_issued,
      warning = warning_issued
    )
  ) %>%
  helpers$add_lat_lng(
  ) %>%
  standardize(d$metadata)
}
