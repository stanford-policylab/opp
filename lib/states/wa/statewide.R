source(here::here("lib", "common.R"))


load_raw <- function(raw_data_dir, n_max) {
  end_cols <- c(
    "officer_gender",
    "contact_date",
    "contact_hour",
    "highway_type",
    "road_number",
    "milepost",
    "contact_type",
    "driver_race",
    "driver_age",
    "driver_gender",
    "search_type",
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
  
  d_2009_to_2014 <- load_regex(
    raw_data_dir,
    regex = "^[0-9]{1,2}[-][0-9]{4}.csv",
    n_max = n_max,
    col_names = c(
      "employee_last",
      "employee_first",
      "officer_race",
      end_cols
    )
  )
  
  d_2015 <- load_regex(
    raw_data_dir,
    regex = "2015_Redacted.csv$",
    n_max = n_max,
    col_names = c(
      "employee_last",
      "employee_first",
      "officer_race",
      end_cols
    )
  )
  
  d_2016_to_2018 <- load_regex(
    raw_data_dir,
    regex = "^2476",
    n_max = n_max,
    col_names = c(
      "employee_last",
      "employee_first",
      end_cols
    )
  )
  
  d <- list()
  d$data <- bind_rows(d_2009_to_2014$data, d_2015$data, d_2016_to_2018$data)
  d$loading_problems <- list(
    d_2009_to_2014 = d_2009_to_2014$loading_problems,
    d_2015 = d_2015$loading_problems, 
    d_2016_to_2018 = d_2016_to_2018$loading_problems
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

  tr_raw_race = c(
    "1" = "White",
    "2" = "African American",
    "3" = "Native American",
    "4" = "Asian",
    "5" = "Pacific Islander",
    "6" = "East Indian",
    "7" = "Hispanic",
    "8" = "Other"
  )
  
  tr_race = c(
    "White" = "white",
    "African American" = "black",
    "Native American" = "other",
    "Asian" = "asian/pacific islander",
    "Pacific Islander" = "asian/pacific islander",
    "East Indian" = "asian/pacific islander",
    "Hispanic" = "hispanic",
    "Other" = "other"
  )
  
  tr_officer_race = c(
    "AMER IND/AK NATIVE" = "other",
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
    "P1" = NA_character_, # pat down (technically RAS)- marked under frisk_performed
    "P2" = NA_character_, # pat down (technically RAS)- marked under frisk_performed
    "W1" = "other", # Warrant Search
    "W2" = "other",  # Warrant Search
    "-" = NA_character_,
    "NULL" = NA_character_,
    "N" = NA_character_ # No search
  )
  
  tr_contact_type <- c(
    "1" = 'Self-Initiated Contact', 
    "2" = 'Calls for service', 
    "4" = 'Collisions',
    "5" = 'Collisions enf. follow-up', 
    "6" = 'Other enf. follow-up',
    "7" = 'Aggressive driving',
    "8" = 'Road rage',
    "9" = 'Emphasis patrol',
    "10" = 'CMV inspect/weighing', 
    "12" = 'Self-Initiated Physical Assist', 
    "13" = 'Distracted driving',
    "20" = NA_character_
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
        # NOTE: This normalization is to match the normalization done to
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
      county_name = str_c(county_name, " County"),
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
      )
    ) %>% 
    add_raw_colname_prefix(
      officer_race,
      officer_gender,
      driver_race,
      driver_gender,
      enforcements,
      contact_type,
      search_type
    ) %>% 
    mutate(
      date = coalesce(
        parse_date(contact_date, "%Y-%m-%d 00:00:00"),
        parse_date(contact_date, "%m/%d/%Y 0:00"),
        parse_date(contact_date, "%Y/%m/%d")
      ),
      time = parse_time(contact_hour, "%H"),
      subject_age = parse_number(driver_age),
      # convert from numbers to the strings provided in Data_Header_and_Key.pdf
      raw_driver_race = fast_tr(raw_driver_race, tr_raw_race),
      subject_race = fast_tr(raw_driver_race, tr_race),
      subject_sex = fast_tr(raw_driver_gender, tr_sex),
      officer_race = fast_tr(raw_officer_race, tr_officer_race),
      officer_sex = fast_tr(raw_officer_gender, tr_officer_sex),
      officer_first_name = str_trim(employee_first),
      officer_last_name = str_trim(employee_last),
      department_name = "Washington State Patrol",
      type = "vehicular",
      stop_reason = fast_tr(raw_contact_type, tr_contact_type),
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
      # NOTE: A "1" in enforcements corresponds to arrest or citation. In this
      # case, we set arrest_made to NA and citation_issued to TRUE.
      arrest_made = if_else(str_detect(raw_enforcements, "1"), NA, FALSE),
      citation_issued = str_detect(raw_enforcements, "1"),
      warning_issued = str_detect(raw_enforcements, "2|3"),
      outcome = first_of(
        "citation" = citation_issued,
        "warning" = warning_issued
      ),
      contraband_found = str_detect(raw_search_type, "1"),
      # NOTE: "P1" and "P2" correspond to "Pat Down Search", which we are
      # considering to be a protective frisk that does not lead to a further
      # search.
      frisk_performed = raw_search_type %in% c("P1", "P2"),
      search_basis = fast_tr(raw_search_type, tr_search_basis),
      search_conducted = !(is.na(search_basis) | is.na(raw_search_type))
    ) %>%
    standardize(d$metadata)
}
