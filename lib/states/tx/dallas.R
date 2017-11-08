source("lib/schema.R")
source("lib/utils.R")


path_prefix <- "data/states/tx/dallas/"


opp_load <- function() {
  tbls <- list()
  raw_csv_path_prefix = str_c(path_prefix, "/raw_csv/")
  # TODO(danj): do we want commercial vehicle inspections (CVE)?
  stops <- read_csv(str_c(raw_csv_path_prefix,
                          'txdps_2016_statewide_stops.csv'))
  citations <- read_csv(str_c(raw_csv_path_prefix,
                              'txdps_2016_statewide_citation_violations.csv'))
  warnings <- read_csv(str_c(raw_csv_path_prefix,
                             'txdps_2016_statewide_warning_violations.csv'))
  weather <- read_csv(str_c(raw_csv_path_prefix,
                            'txdps_lookups.csv'))

  left_join(stops, citations, by = c("HA_ARREST_KEY" = "AD_ARREST_KEY")
  ) %>%
  left_join(warnings, by = c("HA_ARREST_KEY" = "AW_ARREST_KEY")
  ) %>%
  left_join(weather, by = c("HA_WEATHER" = "LK_Code")
  )
}


opp_clean <- function(tbl) {
  date_fmt = "%m/%d/%y %H:%M:%S"
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
  tr_sex <- c(
    F = "female",
    M = "male"
  )
  tbl %>%
    rename(
      # TODO(danj): we need translations of these
      citation_code = AD_VIOLATION_CODE,
      citation_prefix = AD_VIOLATION_PREFIX,
      warning_code = AW_VIOLATION_CODE,
      warning_prefix = AW_VIOLATION_PREFIX,
      defendant_address = HA_A_ADDRESS_DRVR,
      # TODO(danj): what is jge?
      jge_address = HA_A_ADDRESS_JGE,
      is_accident = HA_ACCIDENT,
      defendant_city = HA_A_CITY_DRVR,
      jge_city = HA_A_CITY_JGE,
      alleged_speed = HA_ALLEGED_SPEED,
      arrest_date = HA_ARREST_DATE,
      incident_id = HA_ARREST_KEY,
      defendant_state = HA_A_STATE_DRVR,
      jge_state = HA_A_STATE_JGE,
      defendant_zipcode = HA_A_ZIP_DRVR,
      jge_zipcode = HA_A_ZIP_JGE,
      is_commercial_vehicle = HA_COMM_VEHICLE,
      is_construction_zone = HA_CONSTRUCTION_ZONE,
      contraband_found = HA_CONTRABAN,
      contraband_is_currency = HA_CONTRAB_CURRENCY,
      contraband_is_drugs = HA_CONTRAB_DRUGS,
      contraband_is_other = HA_CONTRAB_OTHER,
      contraband_is_weapon = HA_CONTRAB_WEAPON,
      county_code = HA_COUNTY,
      court_code = HA_COURT,
      day_of_week = HA_DAY_OF_WEEK,
      court_date = HA_D_COURT,
      district = HA_DISTRICT,
      gross_vehicle_weight = HA_GVWR,
      # TODO(danj): some of these heights are not valid..
      height = HA_HEIGHT,
      search_incident_to_arrest = HA_INCIDTO_ARREST,
      is_fugitive_arrest = HA_INT1,
      is_interstate = HA_INTERSTATE,
      is_intrastate = HA_INTRASTATE,
      judge_id = HA_JUDGE_KEY,
      incident_lat = HA_LATITUDE,
      incident_lng = HA_LONGITUDE,
      milepost = HA_MILEPOST,
      month = HA_MONTH,
      defendant_first_name = HA_N_FIRST_DRVR,
      judge_name = HA_N_JUDGE,
      defendant_last_name = HA_N_LAST_DRVR,
      defendant_middle_name = HA_N_MIDDLE_DRVR,
      officer_name = HA_N_TROOPER,
      officer_id = HA_OFFICER_ID,
      other_conditions = HA_OTH_CONDITIONS,
      other_location = HA_OTH_LOC,
      owner_lessee = HA_OWNER_LESSEE,
      has_passengers = HA_PASSENGERS,
      # TODO(danj): what is this?
      defendant_p_hm = HA_P_HM_DRVR,
      judge_p = HA_P_JUDGE,
      posted_speed = HA_POSTED_SPEED,
      precinct = HA_PRECINCT,
      # TODO(danj): what is this?
      defendant_p_wk = HA_P_WK_DRVR,
      quarter_of_year = HA_QTR_DAY,
      race_sex = HA_RACE_SEX,
      citation_issued = HA_REASON_CITA,
      warning_issued = HA_REASON_WARN,
      region = HA_REGION,
      road_class = HA_ROAD_CLASS,
      incident_location = HA_ROAD_LOC,
      route = HA_ROUTE,
      search_consent = HA_SEARCH_CONCENT,
      search_conducted = HA_SEARCHED,
      search_probable_cause = HA_SEARCH_PC,
      # TODO(danj): what is this?
      service = HA_SERVICE,
      sgt_area = HA_SGT_AREA,
      road_type = HA_STR1,
      ticket_number = HA_TICKET_NUMBER,
      ticket_status = HA_TICKET_STATUS,
      ticket_type = HA_TICKET_TYPE,
      # TODO(danj): what is this?
      traffic_category = HA_TRAFFIC,
      race_known_prior_to_stop = HA_UPLOAD_FLAG,
      vehicle_color = HA_VEH_COLOR,
      # TODO(danj): what is this?
      vehicle_invent = HA_VEHICLE_INVENT,
      vehicle_type = HA_VEHICLE_TYPE,
      vehicle_make = HA_VEH_MAKE,
      vehicle_model = HA_VEH_MODEL,
      search_vehicle = HA_VEH_SEARCH,
      vehicle_year = HA_VEH_YEAR,
      weather_code = HA_WEATHER,
      weather_description = LK_Description,
      workers_present = HA_WORKERS_PRESENT,
      year = HA_YEAR
    ) %>%
    separate(
      race_sex, c("defendant_race", "defendant_sex"),
      sep = 1, extra = "merge"
    ) %>%
    mutate(
      is_accident = as.logical(is_accident),
      arrest_date = parse_date(arrest_date, date_fmt),
      defendant_state = factor(defendant_state, levels = valid_states),
      jge_state = factor(jge_state, levels = valid_states),
      is_commercial_vehicle = as.logical(is_commercial_vehicle),
      is_construction_zone = as.logical(is_construction_zone),
      contraband_found = as.logical(contraband_found),
      is_contraband_currency = as.logical(contraband_is_currency),
      is_contraband_drugs = as.logical(contraband_is_currency),
      is_contraband_other = as.logical(contraband_is_other),
      is_contraband_weapon = as.logical(contraband_is_weapon),
      court_date = parse_date(court_date, date_fmt),
      search_incident_to_arrest = as.logical(search_incident_to_arrest),
      is_fugitive_arrest = as.logical(is_fugitive_arrest),
      is_interstate = as.logical(is_interstate),
      is_intrastate = as.logical(is_intrastate),
      incident_lat = incident_lat / 1E6,
      incident_lng = incident_lng / 1E6,
      has_passengers = as.logical(has_passengers),
      defendant_race = factor(tr_race[defendant_race], levels = valid_races),
      defendant_sex = factor(tr_sex[defendant_sex], levels = valid_sexes),
      citation_issued = as.logical(citation_issued),
      warning_issued = as.logical(warning_issued),
      search_consent = as.logical(search_consent),
      search_probable_cause = as.logical(search_probable_cause),
      search_conducted = as.logical(search_conducted),
      race_known_prior_to_stop = as.logical(race_known_prior_to_stop),
      search_vehicle = as.logical(search_vehicle),
      workers_present = as.logical(workers_present),
      incident_type = factor("vehicular", levels = valid_incident_types),
      incident_date = date(arrest_date),
      incident_time = format(arrest_date, "%H:%M:%S"),
      # TODO(danj): what could we use here?
      reason_for_stop = NA,
      search_type = factor(
        c("consent",
          "probable cause",
          "incident to arrest"
        )[min(which(c(
          search_consent,
          search_probable_cause,
          search_incident_to_arrest
          )))
        ],
        levels = valid_search_types
      ),
      # TODO(danj): logic check
      arrest_made = !citation_issued && !warning_issued
    ) %>%
    select(
      # NOTE: drop unused foreign keys
      -c(LK_Lookup_Key, FA_Code)
    ) %>%
    select(
      incident_id,
      incident_type,
      incident_date,
      incident_time,
      incident_location,
      incident_lat,
      incident_lng,
      defendant_race,
      reason_for_stop,
      search_conducted,
      search_type,
      contraband_found,
      arrest_made,
      citation_issued,
      everything()
    )
}


opp_save <- function(tbl) {
  save_clean_csv(tbl, path_prefix, "dallas")
}
