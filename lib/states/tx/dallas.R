source("common.R")

load_raw <- function(raw_data_dir, n_max) {
  # NOTE: commercial vehicle inspections is not currently processed but exists
  # in the raw_data_dir
  loading_problems <- list()
  r <- function(fname) {
    tbl <- read_csv(file.path(raw_data_dir, fname), n_max = n_max)
    loading_problems[[fname]] <<- problems(tbl)
    tbl
  }

  stops <- r('txdps_2016_statewide_stops.csv')
  citations <- r('txdps_2016_statewide_citation_violations.csv')
  warnings <- r('txdps_2016_statewide_warning_violations.csv')
  weather <- r('txdps_lookups.csv')

  left_join(
    stops,
    citations,
    by = c("HA_ARREST_KEY" = "AD_ARREST_KEY")
  ) %>%
  left_join(
    warnings,
    by = c("HA_ARREST_KEY" = "AW_ARREST_KEY")
  ) %>%
  left_join(
    weather,
    by = c("HA_WEATHER" = "LK_Code")
  ) %>%
  bundle_raw(loading_problems)
}


clean <- function(d, calculated_features_path) {
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
    # TODO(journalist): how can we dedup this correctly?
    # https://app.asana.com/0/456927885748233/475749789858290 
    rename(
      incident_location = HA_ROAD_LOC,
      incident_lat = HA_LATITUDE,
      incident_lng = HA_LONGITUDE,
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
      vehicle_color = HA_VEH_COLOR,
      vehicle_make = HA_VEH_MAKE,
      vehicle_model = HA_VEH_MODEL,
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
      incident_type = "vehicular",
      incident_date = parse_date(incident_date, "%m/%d/%y"),
      incident_lat = as.numeric(incident_lat) / 1E6,
      incident_lng = as.numeric(incident_lng) / 1E6,
      citation_issued = not_null(AD_VIOLATION_CODE),
      warning_issued = not_null(AW_VIOLATION_CODE),
      # TODO(journalist): how can we determine whether an arrest happened?
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
      # TODO(journalist): what should we use as reason for stop?
      # https://app.asana.com/0/456927885748233/475749789858290 
      subject_race = tr_race[subject_race],
      subject_sex = tr_sex[subject_sex],
      contraband_drugs = contraband_is_drugs,
      contraband_weapons = contraband_is_weapon
    ) %>%
    standardize(d$metadata)
}
