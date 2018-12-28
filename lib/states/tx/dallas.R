source("common.R")


# VALIDATION: [RED] For the year of 2016, the only year received, there were
# 1.8M rows after deduping on the primary key HA_ARREST_KEY. This number is too
# high, given that the population is only 1.2M as of the 2010 census, as this
# would suggest everyone in Dallas was stopped on average once in 2016; see
# TODOs for outstanding tasks
load_raw <- function(raw_data_dir, n_max) {
  # NOTE: commercial vehicle inspections is not currently processed but exists
  # in the raw_data_dir; same with some of their lookup tables:
  # txdps_lookups_lkup_lw_bus_cat.csv
  # txdps_lookups_lkup_lw_bus_class.csv
  # txdps_lookups_lkup_sids_reas_stop.csv
  # txdps_lookups_lkup_sids_vehicle_type.csv
  loading_problems <- list()
  r <- function(fname) {
    d <- load_single_file(raw_data_dir, fname, n_max)
    loading_problems <<- c(loading_problems, d$loading_problems)
    d$data
  }
  add_lookup <- function(tbl, name, join_col = str_c("HA_", toupper(name))) {
    fname <- str_c("txdps_lookups_lkup_", name, ".csv")
    join_on <- c("LK_Code")
    names(join_on) <- c(join_col)
    left_join(
      tbl,
      select(
        r(fname),
        LK_Code,
        LK_Description
      ) %>%
      rename(!!name := LK_Description),
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
    rename(violation_codes, !!"citation_violation" := LK_description),
    by = c("AD_VIOLATION_CODE" = "LK_Code") 
  ) %>%
  left_join(
    rename(violation_codes, !!"warning_violation" := LK_description),
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
    rename(
      key = HA_ARREST_KEY,
      location = HA_ROAD_LOC,
      lat = HA_LATITUDE,
      lng = HA_LONGITUDE,
      precinct = HA_PRECINCT,
      district = HA_DISTRICT,
      region = HA_REGION,
      search_conducted = HA_SEARCHED,
      search_consent = HA_SEARCH_CONCENT,
      search_probable_cause = HA_SEARCH_PC,
      search_incident_to_arrest = HA_INCIDTO_ARREST,
      contraband_drugs = HA_CONTRAB_DRUGS,
      contraband_weapons = HA_CONTRAB_WEAPON,
      contraband_found = HA_CONTRABAN,
      officer_id = HA_OFFICER_ID,
      speed = HA_ALLEGED_SPEED,
      posted_speed = HA_POSTED_SPEED,
      vehicle_year = HA_VEH_YEAR
    ) %>%
    apply_translator_to(
      tr_int_str_to_bool,
      "contraband_drugs",
      "contraband_found",
      "contraband_weapons",
      "search_conducted",
      "search_consent",
      "search_incident_to_arrest",
      "search_probable_cause"
    ) %>%
    separate_cols(
      HA_ARREST_DATE = c("date", "time")
    ) %>%
    separate_cols(
      HA_RACE_SEX = c("subject_race", "subject_sex"),
      sep = 1
    ) %>%
    mutate(
      # NOTE: top 100 violations all appear vehicle related
      type = "vehicular",
      date = parse_date(date, "%m/%d/%y"),
      lat = as.numeric(lat) / 1E6,
      lng = as.numeric(lng) / 1E6,
      citation_issued = !is.na(AD_VIOLATION_CODE),
      warning_issued = !is.na(AW_VIOLATION_CODE),
      # TODO(phoebe): how can we determine whether an arrest happened?
      # https://app.asana.com/0/456927885748233/475749789858290 
      outcome = first_of(
        citation = citation_issued,
        warning = warning_issued
      ),
      search_basis = first_of(
        "consent" = search_consent,
        "other" = search_incident_to_arrest,
        "probable cause" = search_probable_cause | search_conducted # default
      ),
      # TODO(phoebe): what should we use as reason for stop?
      # https://app.asana.com/0/456927885748233/475749789858290 
      subject_race = tr_race[subject_race],
      subject_sex = tr_sex[subject_sex]
    ) %>%
    # NOTE: select only desired columns to reduce cost of merging rows
    select_(
      .dots = c("key", intersect(names(schema), colnames(.)))
    ) %>%
    # TODO(phoebe): even deduping on the primary key leaves 1.8M million rows
    # for a population of ~1.2M in one year; this can't be right
    # https://app.asana.com/0/456927885748233/548816045773955
    merge_rows(
      key
    ) %>%
    standardize(d$metadata)
}
