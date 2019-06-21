source(here::here("lib", "common.R"))


load_raw <- function(raw_data_dir, n_max) {
  d <- load_regex(raw_data_dir, "^OSHP_", n_max = n_max)
  d_2016_1 <- load_single_file(raw_data_dir, "cad2016.csv", n_max = n_max)
  d_2016_2_to_2017 <- load_regex(raw_data_dir, "^premierone", n_max = n_max)
  
  # Actual split in 2016 appears to be 7/6, but there are some straggler
  # dates with just a few stops
  d$data <- bind_rows(
    d$data, 
    d_2016_1$data %>% 
      filter(as.Date(mdy_hms(DATE_STAMP)) < ymd("2017-07-06")),
    d_2016_2_to_2017$data %>% 
      rename(
        DATE_STAMP = IncidentDate,
        TYPE = IncidentTypeCode
      ) %>% 
      rename_all(str_to_upper) %>% 
      filter(as.Date(mdy_hms(DATE_STAMP)) >= ymd("2017-07-06"))
  )
  d$loading_problems <- c(
    d$loading_problems, 
    d_2016_1$loading_problems,
    d_2016_2_to_2017$loading_problems
  )
  
  bundle_raw(d$data, d$loading_problems)
}

clean <- function(d, helpers) {
  tr_county <- json_to_tr(helpers$load_json("OH_counties.json"))
  tr_violations <- json_to_tr(helpers$load_json("OH_violations.json"))
  # to accommodate 2017, take out periods in violation codes:
  names(tr_violations) <- str_replace_all(names(tr_violations), "\\.", "")
  
  tr_race <- c(
    "1" = "white",
    "2" = "black",
    "3" = "hispanic",
    "4" = "asian/pacific islander",
    "5" = "other",
    "6" = "unknown"
  )
  
  tr_race_raw <- c(
    "1" = "white",
    "2" = "black",
    "3" = "hispanic",
    "4" = "asian",
    "5" = "native american",
    "6" = "unknown"
  )
  
  violations_df <- 
    d$data %>% 
    # violations pre 2017
    filter(!is.na(ORC_STRING)) %>% 
    mutate(
      upper_orc_string = str_replace_all(str_to_upper(ORC_STRING), "\\.", "")
    ) %>% 
    bind_rows(
      d$data %>%
        # violations from 2017
        filter(str_detect(DISPOSITIONS, "\\d{3,}")) %>% 
        mutate(upper_orc_string = stri_join_list(
          str_extract_all(str_to_upper(DISPOSITIONS), 
                          "\\d{3,}[A-Z0-9]+"), 
          sep = ",")
        )
    ) %>% 
    separate_rows(
      upper_orc_string,
      sep = ","
    ) %>%
    mutate(violation = fast_tr(upper_orc_string, tr_violations)) %>% 
    group_by(
      DATE_STAMP, INCIDENT_PK, TYPE, ADDRESS, LATITUDE, LONGITUDE, COUNTY_CODE,
      UNIT, EVENT_NBR, DISP_STRING, ORC_STRING, ASINC_STRING, DISPOSITIONS
    ) %>% 
    summarize(
      violation = str_c_sort_uniq(violation)
    ) %>% 
    ungroup()

  d$data %>%
    left_join(violations_df) %>% 
    rename(
      location = ADDRESS,
      lat = LATITUDE,
      lng = LONGITUDE,
      officer_id = UNIT
    ) %>%
    add_raw_colname_prefix(
      DISP_STRING,
      ORC_STRING, 
      DISPOSITIONS
    ) %>% 
    mutate(
      datetime = parse_datetime(DATE_STAMP, format = "%m/%d/%Y %H:%M:%S"),
      date = as.Date(datetime),
      time = format(datetime, "%H:%M:%S"),
      county_name = fast_tr(COUNTY_CODE, tr_county),
      disp_info = str_c_na(raw_DISP_STRING, raw_DISPOSITIONS, sep = "|"),
      sex_and_race_codes = str_extract(disp_info, "[1-6][FM]"),
      subject_race = fast_tr(substr(sex_and_race_codes, 1, 1), tr_race),
      raw_race = fast_tr(substr(sex_and_race_codes, 1, 1), tr_race_raw),
      subject_sex = fast_tr(substr(sex_and_race_codes, 2, 2), tr_sex),
      # NOTE: The data received in Dec 2015 and Feb 2016 are vehicular stops by
      # the Ohio State Highway Patrol.
      department_name = "Ohio State Highway Patrol",
      type = "vehicular",
      # NOTE: The following are the only disposition codes that clearly indicate
      # arrest or warning. Can't find disposition codes that clearly indicate a
      # citation.
      arrest_made = str_detect(disp_info, "75ARR|75OVI|75WAR|76WAR"),
      warning_issued = str_detect(disp_info, "WARN"),
      outcome = first_of(
        "arrest" = arrest_made,
        "warning" = warning_issued
      ),
      # NOTE: 97 rows are NA; we consider these search F
      search_conducted = str_detect(disp_info, "(^|\\,| )24") & !is.na(disp_info),
      search_basis = first_of(
        "k9" = str_detect(disp_info, "(^|\\,)24C?K"),
        "consent" = str_detect(disp_info, "(^|\\,)24R"),
        "probable cause" = search_conducted
      ),
      contraband_drugs = str_detect(raw_ORC_STRING, "2925") | 
        str_detect(disp_info, "2925"),
      contraband_found = if_else(contraband_drugs, TRUE, NA)
    ) %>%
    standardize(d$metadata)
}
