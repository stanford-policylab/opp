source("common.R")


load_raw <- function(raw_data_dir, n_max) {
  violation_codes <- load_single_file(
    str_c(raw_data_dir, "TXDPS_Lookups", sep = "/"),
    "txdps_lookups_lkup_violation.csv"
  )

  county_codes <- load_single_file(
    str_c(raw_data_dir, "TXDPS_Lookups", sep = "/"),
    "txdps_lookups_lkup_county.csv"
  )
  county_codes$data <- county_codes$data %>%
    select(
      HA_COUNTY = LK_Code,
      county_name = LK_Description,
      county_fips = FIPS_County_Code
    )

  warnings_2006_2017 <- load_regex(raw_data_dir, "warning.*\\.csv$", n_max = n_max)
  warnings <- warnings_2006_2017$data %>%
    left_join(
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

  citations_2006_2016 <- load_regex(
    raw_data_dir,
    "(200[6-9]|201[0-6])citation.*\\.csv$",
    n_max = n_max
  )
  citations_2017 <- load_regex(
    raw_data_dir,
    "2017.*citation.*\\.csv$",
    n_max = n_max
  )
  citations_2017$data <- citations_2017$data %>%
    rename_all(
      toupper
    )
  citations <- bind_rows(
    citations_2006_2016$data,
    citations_2017$data
  ) %>%
    left_join(
      violation_codes$data %>% select(LK_Code, LK_description),
      by = c("AD_VIOLATION_CODE" = "LK_Code")
    ) %>%
    group_by(
      AD_ARREST_KEY
    ) %>%
    summarize(
      citation_reasons = str_c_sort_uniq(LK_description, collapse = "|")
    ) %>% 
    ungroup()

  stops_2006_2008 <- load_regex(
    raw_data_dir,
    "200[678].*stops.*\\.csv$",
    n_max = n_max
  )
  stops_2006_2008$data <- stops_2006_2008$data %>%
    mutate(
      HA_SEARCHED_boolean = HA_SEARCHED == -1,
      HA_SEARCH_PC_boolean = HA_SEARCH_PC == -1,
      HA_SEARCH_CONCENT_boolean = HA_SEARCH_CONCENT == -1,
      HA_INCIDTO_ARREST_boolean = HA_INCIDTO_ARREST == -1,
      HA_VEHICLE_INVENT_boolean = HA_VEHICLE_INVENT == -1,
      HA_CONTRABAN_boolean = HA_CONTRABAN == -1,
      HA_CONTRAB_DRUGS_boolean = HA_CONTRAB_DRUGS == -1,
      HA_CONTRAB_WEAPON_boolean = HA_CONTRAB_WEAPON == -1
    )
  stops_2009_2016 <- load_regex(
    raw_data_dir,
    "(2009|201[0-6]).*stops.*\\.csv$",
    n_max = n_max
  )
  stops_2017 <- load_regex(
    raw_data_dir,
    "2017.*stops.*\\.csv$",
    n_max = n_max
  )
  stops_2017$data <- stops_2017$data %>%
    rename_all(
      toupper
    )
  stops_2009_2017 <- bind_rows(
    stops_2009_2016$data,
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
    stops_2006_2008$data,
    stops_2009_2017
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
    warnings_2006_2017$loading_problems,
    citations_2006_2016$loading_problems,
    citations_2017$loading_problems,
    stops_2006_2008$loading_problems,
    stops_2009_2016$loading_problems,
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
    U = "other/unknown",
    O = "other/unknown",
    I = "other/unknown",
    M = "other/unknown" # Middle Eastern
  )

  # NOTE: Normalizes a name for joining the dataset with last name race
  # statistics.
  normalize_name <- function(x) {
    x <- tolower(str_trim(x))
    # NOTE: Removing punctuation.
    x <- str_replace_all(x, ",|\\.", "")
    # NOTE: Removing suffix.
    x <- str_replace_all(x, " jr$| sr$| i$| ii$| iii$| iv$|  v$| vi$", "")
    x <- str_replace_all(x, "\\-", " ")
    pieces <- str_split(x, " ")
    sapply(pieces, function(y) y[length(y)])
  }

  # NOTE: Dataset with race statistics for last names to help correct race, in
  # particular, hispanic not being correctly recorded.
  surnames <- helpers$load_csv("surnames.csv")
  # NOTE: Replacing "(S)" with NA everywhere.
  surnames[surnames == "(S)"] <- NA
  surnames <- surnames %>%
    select(
      name,
      pcthispanic
    ) %>%
    mutate(
      normalized_last_name = tolower(name),
      pH = coalesce(parse_number(pcthispanic) / 100, 0)
    ) %>%
    filter(
      str_length(normalized_last_name) > 0
    )

  pre_dedup <- d$data %>%
    rename(
      district = HA_DISTRICT,
      precinct = HA_PRECINCT,
      region = HA_REGION,
      officer_id = HA_OFFICER_ID,
      officer_last_name = HA_N_TROOPER,
      search_vehicle = HA_VEH_SEARCH_boolean,
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
      search_conducted = if_else(
        !is.na(search_basis),
        TRUE,
        HA_SEARCHED_boolean
      ),
      contraband_found = if_else(
        search_conducted,
        HA_CONTRABAN_boolean,
        NA
      ),
      contraband_drugs = if_else(
        contraband_found,
        HA_CONTRAB_DRUGS_boolean,
        NA
      ),
      contraband_weapons = if_else(
        contraband_found,
        HA_CONTRAB_WEAPON_boolean,
        NA
      )
    ) %>%
    left_join(
      surnames,
      by = "normalized_last_name"
    ) %>%
    mutate(
      subject_race = if_else(
        (subject_race_recorded == "White" | is.na(subject_race_recorded))
        & !is.na(pH)
        & pH > 0.75,
        "Hispanic",
        subject_race_recorded
      )
    )

  duplicates <- pre_dedup %>%
    select(
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

  cleaned <- pre_dedup %>%
    filter(
      !duplicates
    ) %>%
    standardize(d$metadata)
}
