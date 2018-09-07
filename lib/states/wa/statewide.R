source("common.R")


load_raw <- function(raw_data_dir, n_max) {
  d <- load_all_csvs(
    raw_data_dir,
    n_max = n_max,
    col_names = c(
      "employee_last",
      "employee_first",
      "officer_race_raw",
      "officer_gender",
      "contact_date",
      "contact_hour",
      "highway_type",
      "road_number",
      "milepost",
      "contact_type_orig",
      "driver_race_orig",
      "driver_age_raw",
      "driver_gender_raw",
      "search_type_orig",
      "violation_1",
      "enforcement_1",
      "violation_2",
      "enforcement_2",
      "violation_3",
      "enforcement_3",
      "violation_4",
      "enforcement_4",
      "violation_5",
      "enforcement_5",
      "violation_5_dup",
      "enforcement_5_dup",
      "violation_6",
      "enforcement_6",
      "violation_7",
      "enforcement_7",
      "violation_8",
      "enforcement_8",
      "violation_9",
      "enforcement_9",
      "violation_10",
      "enforcement_10",
      "violation_11",
      "enforcement_11",
      "violation_12",
      "enforcement_12"
    )
  )
  bundle_raw(d$data, d$loading_problems)
}


clean <- function(d, helpers) {
  # TODO: Migrate in the code to generate wa_location.csv from the old
  # openpolicing codebase:
  # https://github.com/5harad/openpolicing/blob/master/src/processing/scripts/WA_map_locations.R
  # https://app.asana.com/0/456927885748233/808677867930132
  wa_location <- helpers$load_csv("wa_location.csv")

  tr_violation <- json_to_tr(helpers$load_json("WA_violations.json"))

  tr_race = c(
    "1" = "white",
    "2" = "black",
    "3" = "other/unknown", # Native American
    "4" = "asian/pacific islander", # Asian
    "5" = "asian/pacific islander", # Pacific Islander
    "6" = "asian/pacific islander", # East Indian
    "7" = "hispanic",
    "8" = "other/unknown" # Other
  )

  tr_officer_race = c(
    "AMER IND/AK NATIVE" = "other/unknown",
    "ASIAN/PI" = "asian/pacific islander",
    "BLACK" = "black",
    "HISPANIC" = "hispanic",
    "WHITE" = "white"
  )

  tr_officer_sex = c(
    "1" = "male",
    "2" = "female"
  )

  tr_search_basis = c(
    "A1" = "other", # Incident to Arrest
    "A2" = "other", # Incident to Arrest
    "C1" = "consent",
    "C2" = "consent",
    "I1" = "other", # Impound Search
    "I2" = "other", # Impound Search
    "K1" = "k9",
    "K2" = "k9",
    "W1" = "other",
    "W2" = "other"
  )

  # NOTE: Replacing "NULL" with NA everywhere.
  d$data[d$data == "NULL" | d$data == "-"] <- NA

  d$data %>%
    # NOTE: Removing weigh stations stops (W). These are not normal traffic
    # stops; they are all related to truck weigh station violations.
    filter(
      highway_type != "W"
    ) %>%
    mutate(
      # NOTE: Normalize road numbers to properly join with wa_location.
      road_number = str_pad(road_number, 3, pad = "0"),
      road_number = str_replace_all(
        road_number,
        # NOTE: This normailization is to match the normalization done to
        # generate wa_location in the old openpolicing project; matches the WA
        # mile marker database road numbers.
        c("^97A$" = "097AR", "^28B$" = "028", "^20S$" = "020SPANACRT")
      ),
      milepost_id = str_c(
        highway_type,
        road_number,
        milepost,
        sep = '-'
      )
    ) %>%
    left_join(
      wa_location,
      by = "milepost_id"
    ) %>%
    rename(
      location = milepost_id,
      lat = latitude,
      lng = longitude
    ) %>%
    mutate(
      date = coalesce(
        parse_date(contact_date, "%Y-%m-%d %H:%M:%S"),
        parse_date(contact_date, "%m/%d/%Y %H:%M")
      ),
      time = parse_time(contact_hour, "%H"),
      subject_age = parse_number(driver_age_raw),
      subject_race = fast_tr(driver_race_orig, tr_race),
      subject_sex = fast_tr(driver_gender_raw, tr_sex),
      officer_race = fast_tr(officer_race_raw, tr_officer_race),
      officer_sex = fast_tr(officer_gender, tr_officer_sex),
      officer_first_name = str_trim(employee_first),
      officer_last_name = str_trim(employee_last),
      # NOTE: The data received up until Oct 2016 are vehicular stops by the
      # Washington State Patrol.
      department_name = "Washington State Patrol",
      type = "vehicular",
      violation = str_c_na(
        fast_tr(violation_1, tr_violation),
        fast_tr(violation_2, tr_violation),
        fast_tr(violation_3, tr_violation),
        fast_tr(violation_4, tr_violation),
        fast_tr(violation_5, tr_violation),
        fast_tr(violation_6, tr_violation),
        fast_tr(violation_7, tr_violation),
        fast_tr(violation_8, tr_violation),
        fast_tr(violation_9, tr_violation),
        fast_tr(violation_10, tr_violation),
        fast_tr(violation_11, tr_violation),
        fast_tr(violation_12, tr_violation),
        sep = '|'
      ),
      enforcements = str_c_na(
        enforcement_1,
        enforcement_2,
        enforcement_3,
        enforcement_4,
        enforcement_5,
        enforcement_6,
        enforcement_7,
        enforcement_8,
        enforcement_9,
        enforcement_10,
        enforcement_11,
        enforcement_12,
        sep = '|'
      ),
      # NOTE: A "1" in enforcements corresponds to arrest or citation. In this
      # case, we set arrest_made to NA and citation_issued to TRUE.
      arrest_made = if_else(str_detect(enforcements, "1"), NA, FALSE),
      citation_issued = str_detect(enforcements, "1"),
      warning_issued = str_detect(enforcements, "2|3"),
      outcome = first_of(
        "citation" = citation_issued,
        "warning" = warning_issued
      ),
      contraband_found = str_detect(search_type_orig, "1"),
      frisk_performed = if_else(
        is.na(search_type_orig),
        NA,
        # NOTE: "P1" and "P2" correspond to "Pat Down Search", which we are
        # considering to be a protective frisk that does not lead to a further
        # search.
        search_type_orig %in% c("P1", "P2")
      ),
      search_conducted = if_else(
        search_type_orig %in% names(tr_search_basis),
        TRUE,
        if_else(search_type_orig == "N", FALSE, NA)
      ),
      search_basis = fast_tr(search_type_orig, tr_search_basis)
    ) %>%
    standardize(d$metadata)
}
