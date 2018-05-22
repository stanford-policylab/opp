source("common.R")

load_raw <- function(raw_data_dir, n_max) {
  # NOTE: commercial vehicle inspections is not currently processed but exists
  # in the raw_data_dir; same with some of their lookup tables:
  # txdps_lookups_lkup_lw_bus_cat.csv
  # txdps_lookups_lkup_lw_bus_class.csv
  # txdps_lookups_lkup_sids_reas_stop.csv
  # txdps_lookups_lkup_sids_vehicle_type.csv
  loading_problems <- list()
  r <- function(fname) {
    tbl <- read_csv(
      file.path(raw_data_dir, fname),
      col_types = cols(.default = "c"),
      n_max = n_max
    )
    loading_problems[[fname]] <<- problems(tbl)
    tbl
  }
  add_lookup <- function(tbl, name, join_col = str_c("HA_", toupper(name))) {
    fname <- str_c("txdps_lookups_lkup_", name, ".csv")
    join_on <- c("LK_Code")
    names(join_on) <- c(join_col)
    left_join(
      tbl,
      r(fname) %>%
        select(LK_Code, LK_Description) %>%
        rename_with_str("LK_Description", name),
      by = join_on
    )
  }

  violation_codes <- r('txdps_lookups_lkup_violation.csv') %>%
    select(LK_Code, LK_description)

  left_join(
    r('txdps_2016_statewide_stops.csv'),
    r('txdps_2016_statewide_citation_violations.csv'),
    by = c("HA_ARREST_KEY" = "AD_ARREST_KEY")
  ) %>%
  left_join(
    r('txdps_2016_statewide_warning_violations.csv'),
    by = c("HA_ARREST_KEY" = "AW_ARREST_KEY")
  ) %>%
  left_join(
    violation_codes %>%
      rename_with_str("LK_description", "citation_violation"),
    by = c("AD_VIOLATION_CODE" = "LK_Code") 
  ) %>%
  left_join(
    violation_codes %>%
      rename_with_str("LK_description", "warning_violation"),
    by = c("AW_VIOLATION_CODE" = "LK_Code") 
  ) %>%
  mutate(
    violation = coalesce(citation_violation, warning_violation)
  ) %>%
  add_lookup("county") %>%
  add_lookup("court") %>%
  add_lookup("day_of_week") %>%
  add_lookup("race_sex") %>%
  add_lookup("road_class") %>%
  add_lookup("service") %>%
  add_lookup("ticket_type") %>%
  add_lookup("traffic") %>%
  add_lookup("vehicle_color", "HA_VEH_COLOR") %>%
  add_lookup("vehicle_make", "HA_VEH_MAKE") %>%
  add_lookup("vehicle_model", "HA_VEH_MODEL") %>%
  add_lookup("vehicle_type") %>%
  add_lookup("weather") %>%
  bundle_raw(loading_problems)
}


clean <- function(d, helpers) {
  tr_race <- c(
    A = "asian/pacific islander",
    B = "black",
    H = "hispanic",
    I = "other/unknown",
    M = "other/unknown",
    O = "other/unknown",
    U = "other/unknown",
    W = "white"
  )

  d$data %>%
    # TODO(journalist): how can we dedup this correctly? merging causes null
    # rates to skyrocket
    # https://app.asana.com/0/456927885748233/475749789858290 
    # NOTE: yields about the same as merging on HA_ARREST_KEY, 1.8M rows
    # merge_rows(
    #   HA_OFFICER_ID,
    #   HA_ROAD_LOC,
    #   HA_ARREST_DATE
    # ) %>%
    # NOTE: yields about 1.8M rows
    # merge_rows(
    #   HA_ARREST_KEY
    # ) %>%
    rename(
      incident_location = HA_ROAD_LOC,
      incident_lat = HA_LATITUDE,
      incident_lng = HA_LONGITUDE,
      # TODO(phoebe): what are HA_REGION and HA_DISTRICT?
      # https://app.asana.com/0/456927885748233/553393937447381
      precinct = HA_PRECINCT,
      search_conducted = HA_SEARCHED,
      search_consent = HA_SEARCH_CONCENT,
      search_probable_cause = HA_SEARCH_PC,
      search_incident_to_arrest = HA_INCIDTO_ARREST,
      contraband_found = HA_CONTRABAN,
      contraband_is_currency = HA_CONTRAB_CURRENCY,
      contraband_is_drugs = HA_CONTRAB_DRUGS,
      contraband_is_other = HA_CONTRAB_OTHER,
      contraband_is_weapon = HA_CONTRAB_WEAPON,
      officer_id = HA_OFFICER_ID,
      vehicle_year = HA_VEH_YEAR
    ) %>%
    mutate_each(
      funs(as.logical),
      search_conducted,
      search_consent,
      search_probable_cause,
      search_incident_to_arrest,
      contraband_found,
      contraband_is_currency,
      contraband_is_drugs,
      contraband_is_other,
      contraband_is_weapon
    ) %>%
    separate_cols(
      HA_ARREST_DATE = c("incident_date", "incident_time")
    ) %>%
    separate_cols(
      HA_RACE_SEX = c("subject_race", "subject_sex"),
      sep = 1
    ) %>%
    mutate(
      # NOTE: top 100 violations all appear vehicle related
      incident_type = "vehicular",
      incident_date = parse_date(incident_date, "%m/%d/%y"),
      incident_lat = as.numeric(incident_lat) / 1E6,
      incident_lng = as.numeric(incident_lng) / 1E6,
      citation_issued = !is.na(AD_VIOLATION_CODE),
      warning_issued = !is.na(AW_VIOLATION_CODE),
      # TODO(phoebe): how can we determine whether an arrest happened?
      # https://app.asana.com/0/456927885748233/475749789858290 
      arrest_made = !citation_issued && !warning_issued,
      incident_outcome = first_of(
        arrest = arrest_made,
        citation = citation_issued,
        warning = warning_issued
      ),
      search_type = first_of(
        "consent" = search_consent,
        "probable cause" = search_probable_cause,
        "non-discretionary" = search_incident_to_arrest,
        "probable cause" = search_conducted # default
      ),
      # TODO(phoebe): what should we use as reason for stop?
      # https://app.asana.com/0/456927885748233/475749789858290 
      subject_race = tr_race[subject_race],
      subject_sex = tr_sex[subject_sex],
      contraband_drugs = contraband_is_drugs,
      contraband_weapons = contraband_is_weapon
    ) %>%
    standardize(d$metadata)
}
