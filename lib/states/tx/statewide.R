source("common.R")


load_raw <- function(raw_data_dir, n_max) {
  violation_codes <- load_single_file(
    file.path(raw_data_dir, "TXDPS_Lookups"),
    "txdps_lookups_lkup_violation.csv"
  )

  county_codes <- load_single_file(
    file.path(raw_data_dir, "TXDPS_Lookups"),
    "txdps_lookups_lkup_county.csv"
  )
  county_codes$data <- select(
    county_codes$data,
    HA_COUNTY = LK_Code,
    county_name = LK_Description,
    county_fips = FIPS_County_Code
  )

  warnings_2006_to_2017 <- load_regex(raw_data_dir, "warning", n_max = n_max)
  warnings <- left_join(
    warnings_2006_to_2017$data,
    violation_codes$data %>% select(LK_Code, LK_description),
    by = c("AW_VIOLATION_CODE" = "LK_Code")
  ) %>%
  group_by(
    AW_ARREST_KEY
  ) %>%
  summarize(
    warning_reasons = str_c_sort_uniq(LK_description, collapse = "|")
  ) %>%
  ungroup()

  citations_2006_to_2016 <- load_regex(
    raw_data_dir,
    "(200[6-9]|201[0-6]).*citation",
    n_max = n_max
  )
  citations_2017 <- load_regex(
    raw_data_dir,
    "2017.*citation",
    n_max = n_max
  )
  citations_2017$data <- rename_all(citations_2017$data, toupper)
  citations <- bind_rows(
    citations_2006_to_2016$data,
    citations_2017$data
  ) %>%
  left_join(
    select(violation_codes$data, LK_Code, LK_description),
    by = c("AD_VIOLATION_CODE" = "LK_Code")
  ) %>%
  group_by(
    AD_ARREST_KEY
  ) %>%
  summarize(
    citation_reasons = str_c_sort_uniq(LK_description, collapse = "|")
  ) %>%
  ungroup()

  stops_2006_to_2008 <- load_regex(
    raw_data_dir,
    "200[678].*stops",
    n_max = n_max
  )
  stops_2006_to_2008$data <- mutate(
    stops_2006_to_2008$data,
    HA_SEARCHED_boolean = HA_SEARCHED == -1,
    HA_SEARCH_PC_boolean = HA_SEARCH_PC == -1,
    HA_SEARCH_CONCENT_boolean = HA_SEARCH_CONCENT == -1,
    HA_INCIDTO_ARREST_boolean = HA_INCIDTO_ARREST == -1,
    HA_VEHICLE_INVENT_boolean = HA_VEHICLE_INVENT == -1,
    HA_CONTRABAN_boolean = HA_CONTRABAN == -1,
    HA_CONTRAB_DRUGS_boolean = HA_CONTRAB_DRUGS == -1,
    HA_CONTRAB_WEAPON_boolean = HA_CONTRAB_WEAPON == -1
  )
  stops_2009_to_2016 <- load_regex(
    raw_data_dir,
    "(2009|201[0-6]).*stops",
    n_max = n_max
  )
  stops_2017 <- load_regex(
    raw_data_dir,
    "2017.*stops",
    n_max = n_max
  )
  stops_2017$data <- rename_all(stops_2017$data, toupper)
  stops_2009_to_2017 <- bind_rows(
    stops_2009_to_2016$data,
    stops_2017$data
  ) %>%
  mutate(
    HA_SEARCHED_boolean = HA_SEARCHED == 1,
    HA_SEARCH_PC_boolean = HA_SEARCH_PC == 1,
    HA_SEARCH_CONCENT_boolean = HA_SEARCH_CONCENT == 1,
    HA_INCIDTO_ARREST_boolean = HA_INCIDTO_ARREST == 1,
    HA_VEHICLE_INVENT_boolean = HA_VEHICLE_INVENT == 1,
    HA_CONTRABAN_boolean = HA_CONTRABAN == 1,
    HA_CONTRAB_DRUGS_boolean = HA_CONTRAB_DRUGS == 1,
    HA_CONTRAB_WEAPON_boolean = HA_CONTRAB_WEAPON == 1,
    HA_VEH_SEARCH_boolean = HA_VEH_SEARCH == 1
  )

  data <- bind_rows(
    stops_2006_to_2008$data,
    stops_2009_to_2017
  ) %>%
  left_join(
    warnings,
    by = c("HA_ARREST_KEY" = "AW_ARREST_KEY")
  ) %>%
  left_join(
    citations,
    by = c("HA_ARREST_KEY" = "AD_ARREST_KEY")
  ) %>%
  left_join(
    county_codes$data,
    by = "HA_COUNTY"
  )

  loading_problems <- c(
    violation_codes$loading_problems,
    county_codes$loading_problems,
    warnings_2006_to_2017$loading_problems,
    citations_2006_to_2016$loading_problems,
    citations_2017$loading_problems,
    stops_2006_to_2008$loading_problems,
    stops_2009_to_2016$loading_problems,
    stops_2017$loading_problems
  )
  bundle_raw(data, loading_problems)
}


clean <- function(d, helpers) {
  tr_race <- c(
    A = "asian/pacific islander",
    B = "black",
    H = "hispanic",
    W = "white",
    # NOTE: In line with census definitions, we define middle eastern as white
    # This is in contrast to old OPP definitions, which classified as other
    M = "white", # Middle Eastern
    U = "other/unknown",
    O = "other/unknown",
    I = "other/unknown"
  )

  # NOTE: Normalizes a name for joining the dataset with last name race
  # statistics.
  normalize_name <- function(x) {
    x <- str_to_lower(str_trim(x))
    # NOTE: Removing punctuation.
    x <- str_replace_all(x, ",|\\.", "")
    # NOTE: Removing suffix.
    x <- str_replace_all(x, " jr$| sr$| i$| ii$| iii$| iv$| v$| vi$", "")
    x <- str_replace_all(x, "\\-", " ")
    pieces <- str_split(x, " ")
    sapply(pieces, function(y) y[length(y)])
  }

  # NOTE: Dataset with race statistics for last names to help correct race, in
  # particular, hispanic not being correctly recorded. Source:
  # http://www.census.gov/topics/population/genealogy/data/2000_surnames.html
  # NOTE: Replacing "(S)" with NA everywhere; "(S)" represents values suppressed
  # for confidentiality.
  surnames <- helpers$load_csv("surnames.csv", na = c("", "NA", "(S)"))
  surnames <- select(surnames,
    name,
    pcthispanic
  ) %>%
  filter(
    str_length(name) > 0
  ) %>%
  mutate(
    normalized_last_name = str_to_lower(name),
    pH = coalesce(parse_number(pcthispanic) / 100, 0)
  )

  pre_dedup <- rename(
    d$data,
    district = HA_DISTRICT,
    precinct = HA_PRECINCT,
    region = HA_REGION,
    officer_id = HA_OFFICER_ID,
    officer_last_name = HA_N_TROOPER,
    search_conducted = HA_SEARCHED_boolean,
    search_vehicle = HA_VEH_SEARCH_boolean,
    contraband_found = HA_CONTRABAN_boolean,
    contraband_drugs = HA_CONTRAB_DRUGS_boolean,
    contraband_weapons = HA_CONTRAB_WEAPON_boolean,
    vehicle_color = HA_VEH_COLOR,
    vehicle_make = HA_VEH_MAKE,
    vehicle_model = HA_VEH_MODEL,
    vehicle_type = HA_VEHICLE_TYPE,
    vehicle_year = HA_VEH_YEAR
  ) %>%
  mutate(
    date = parse_date(HA_ARREST_DATE, "%m/%d/%y %H:%M:%S"),
    time = parse_time(HA_ARREST_DATE, "%m/%d/%y %H:%M:%S"),
    location = str_combine_cols(
      HA_ROUTE,
      HA_MILEPOST,
      prefix_left = "route: ",
      prefix_right = "milepost: ",
      sep=", "
    ),
    lat = parse_number(HA_LATITUDE) / 1e6,
    lng = parse_number(HA_LONGITUDE) / 1e6,
    subject_first_name = str_to_title(HA_N_FIRST_DRVR),
    subject_last_name = str_to_title(HA_N_LAST_DRVR),
    normalized_last_name = normalize_name(HA_N_LAST_DRVR),
    subject_race_recorded = fast_tr(str_sub(HA_RACE_SEX, 1, 1), tr_race),
    subject_sex = fast_tr(str_sub(HA_RACE_SEX, 2, 2), tr_sex),
    # NOTE: Only vehicular traffic stops were requested in the data request.
    type = "vehicular",
    violation = str_c_na(warning_reasons, citation_reasons, sep = "|"),
    citation_issued = !is.na(citation_reasons),
    warning_issued = !is.na(warning_reasons),
    # TODO(walterk): We don't know from the data if an arrest was made. Figure
    # out if outcome should be NA or if we should take the most severe of
    # citation and warning.
    # https://app.asana.com/0/456927885748233/770496398010352
    outcome = first_of(
      "citation" = citation_issued,
      "warning" = warning_issued
    ),
    search_basis = first_of(
      "consent" = HA_SEARCH_CONCENT_boolean,
      "probable cause" = HA_SEARCH_PC_boolean,
      "other" = HA_INCIDTO_ARREST_boolean | HA_VEHICLE_INVENT_boolean
    ),
    contraband_found = contraband_found | contraband_drugs | contraband_weapons
  ) %>%
  left_join(
    surnames,
    by = "normalized_last_name"
  ) %>%
  mutate(
    # NOTE: If the race is white or NA, and the last name is more than 75%
    # likely to be hispanic, we set race as hispanic.
    subject_race = if_else(
      (subject_race_recorded %in% c("white", "other/unknown") | is.na(subject_race_recorded))
      & !is.na(pH)
      & pH > 0.75,
      "hispanic",
      subject_race_recorded
    )
  )

  duplicates <- select(
    pre_dedup,
    date,
    time,
    county_fips,
    HA_RACE_SEX,
    HA_MILEPOST,
    officer_id,
    subject_first_name,
    subject_last_name
  ) %>%
  duplicated()

  cleaned <- filter(
    pre_dedup,
    !duplicates
  ) %>%
  standardize(d$metadata)
}
