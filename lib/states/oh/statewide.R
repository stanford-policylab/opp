source("common.R")


load_raw <- function(raw_data_dir, n_max) {
  d <- load_regex(raw_data_dir, "\\.csv$", n_max = n_max)
  bundle_raw(d$data, d$loading_problems)
}


clean <- function(d, helpers) {
  tr_county <- json_to_tr(helpers$load_json("OH_counties.json"))
  tr_violations <- json_to_tr(helpers$load_json("OH_violations.json"))

  tr_race <- c(
    "1" = "white",
    "2" = "black",
    "3" = "hispanic",
    "4" = "asian/pacific islander",
    "5" = "other/unknown",
    "6" = "other/unknown"
  )

  violations_frame <- d$data %>%
    select(
      INCIDENT_PK,
      ORC_STRING
    ) %>%
    separate_rows(
      ORC_STRING,
      sep = ","
    ) %>%
    mutate(
      upper_orc_string = toupper(ORC_STRING),
      violation = fast_tr(upper_orc_string, tr_violations),
      violation = str_c_na(upper_orc_string, violation, sep = ": "),
      violation = replace(violation, violation == "", NA_character_)
    ) %>%
    group_by(
      INCIDENT_PK
    ) %>%
    summarize(
      violation = str_c_sort_uniq(violation)
    ) %>%
    ungroup()

  d$data %>%
    rename(
      location = ADDRESS,
      lat = LATITUDE,
      lng = LONGITUDE,
      officer_id = UNIT
    ) %>%
    mutate(
      date = parse_date(DATE_STAMP, format = "%m/%d/%Y %H:%M:%S"),
      time = parse_time(DATE_STAMP, format = "%m/%d/%Y %H:%M:%S"),
      county_name = fast_tr(COUNTY_CODE, tr_county),
      sex_and_race_codes = str_extract(DISP_STRING, "[1-6][FM]"),
      subject_race = fast_tr(substr(sex_and_race_codes, 1, 1), tr_race),
      subject_sex = fast_tr(substr(sex_and_race_codes, 2, 2), tr_sex),
      # NOTE: The data received in Dec 2015 and Feb 2016 are vehicular stops by
      # the Ohio State Highway Patrol.
      department_name = "Ohio State Highway Patrol",
      type = "vehicular",
      arrest_made = str_detect(DISP_STRING, "75ARR|75OVI|75WAR|76WAR"),
      warning_issued = str_detect(DISP_STRING, "WARN"),
      outcome = first_of(
        "arrest" = arrest_made,
        "warning" = warning_issued
      ),
      # TODO(walterk): If contraband_drugs is TRUE, this corresponds to 
      # "Possession of controlled substances". search_conducted might be TRUE or
      # FALSE in this case which seems to be inconsistent. The meaning here
      # needs to be resolved.
      # https://app.asana.com/0/456927885748233/767331124176505
      contraband_drugs = str_detect(ORC_STRING, "2925"),
      contraband_found = if_else(contraband_drugs, TRUE, NA),
      search_conducted = str_detect(DISP_STRING, "24"),
      search_basis = first_of(
        "k9" = str_detect(DISP_STRING, "24C?K"),
        "consent" = str_detect(DISP_STRING, "24R")
      )
    ) %>%
    left_join(
      violations_frame,
      by = "INCIDENT_PK"
    ) %>%
    standardize(d$metadata)
}
