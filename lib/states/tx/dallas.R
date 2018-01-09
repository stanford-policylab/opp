source("common.R")

load_raw <- function(raw_data_dir, geocodes_path) {
  # NOTE: commercial vehicle inspections is not currently processed but exists
  # in the raw_data_dir
  loading_problems <- list()
  r <- function(fname) {
    tbl <- read_csv(file.path(raw_data_dir, fname))
    loading_problems[[fname]] <- problems(tbl)
    tbl
  }
  stops <- r('txdps_2016_statewide_stops.csv')
  citations <- r('txdps_2016_statewide_citation_violations.csv')
  warnings <- r('txdps_2016_statewide_warning_violations.csv')
  weather <- r('txdps_lookups.csv')

  data <- left_join(
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
  )

  list(data = data, metadata = list(loading_problems = loading_problems))
}


clean <- function(d) {
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
  # TODO(journalist): what should we use as reason for stop?
  # https://app.asana.com/0/456927885748233/475749789858290 
  d$data %>%
    rename(
      # TODO(journalist): we need translations of these
      # https://app.asana.com/0/456927885748233/475749789858290
      citation_code = AD_VIOLATION_CODE,
      citation_prefix = AD_VIOLATION_PREFIX,
      warning_code = AW_VIOLATION_CODE,
      warning_prefix = AW_VIOLATION_PREFIX,
      subject_address = HA_A_ADDRESS_DRVR,
      # TODO(journalist): what is jge?
      # https://app.asana.com/0/456927885748233/475749789858290 
      jge_address = HA_A_ADDRESS_JGE,
      is_accident = HA_ACCIDENT,
      subject_city = HA_A_CITY_DRVR,
      jge_city = HA_A_CITY_JGE,
      alleged_speed = HA_ALLEGED_SPEED,
      arrest_datetime = HA_ARREST_DATE,
      stop_id = HA_ARREST_KEY,
      subject_state = HA_A_STATE_DRVR,
      jge_state = HA_A_STATE_JGE,
      subject_zipcode = HA_A_ZIP_DRVR,
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
      # NOTE: some of these heights are invalid
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
      subject_first_name = HA_N_FIRST_DRVR,
      judge_name = HA_N_JUDGE,
      subject_last_name = HA_N_LAST_DRVR,
      subject_middle_name = HA_N_MIDDLE_DRVR,
      officer_name = HA_N_TROOPER,
      officer_id = HA_OFFICER_ID,
      other_conditions = HA_OTH_CONDITIONS,
      other_location = HA_OTH_LOC,
      owner_lessee = HA_OWNER_LESSEE,
      has_passengers = HA_PASSENGERS,
      # TODO(journalist): what is this?
      # https://app.asana.com/0/456927885748233/475749789858290 
      subject_p_hm = HA_P_HM_DRVR,
      judge_p = HA_P_JUDGE,
      posted_speed = HA_POSTED_SPEED,
      precinct = HA_PRECINCT,
      # TODO(journalist): what is this?
      # https://app.asana.com/0/456927885748233/475749789858290
      subject_p_wk = HA_P_WK_DRVR,
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
      # TODO(journalist): what is this?
      # https://app.asana.com/0/456927885748233/475749789858290
      service = HA_SERVICE,
      sgt_area = HA_SGT_AREA,
      road_type = HA_STR1,
      ticket_number = HA_TICKET_NUMBER,
      ticket_status = HA_TICKET_STATUS,
      ticket_type = HA_TICKET_TYPE,
      # TODO(journalist): what is this?
      # https://app.asana.com/0/456927885748233/475749789858290
      traffic_category = HA_TRAFFIC,
      race_known_prior_to_stop = HA_UPLOAD_FLAG,
      vehicle_color = HA_VEH_COLOR,
      # TODO(journalist): what is this?
      # https://app.asana.com/0/456927885748233/475749789858290 
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
    separate_cols(
      race_sex = c("subject_race", "subject_sex"),
      sep = 1
    ) %>%
    separate_cols(
      arrest_datetime = c("incident_date", "incident_time")
    ) %>%
    mutate_each(
      funs(as.logical),
      is_accident,
      is_commercial_vehicle,
      is_construction_zone,
      contraband_found,
      contraband_is_currency,
      contraband_is_drugs,
      contraband_is_other,
      contraband_is_weapon,
      search_incident_to_arrest,
      is_fugitive_arrest,
      is_interstate,
      is_intrastate,
      has_passengers,
      citation_issued,
      warning_issued,
      search_consent,
      search_conducted,
      search_probable_cause,
      race_known_prior_to_stop,
      workers_present
    ) %>%
    mutate(
      # NOTE: the stop_ids are a combination of a unique prefix and a one
      # character suffix corresponding to the warning/citation/arrest code
      # there are multiple stop_ids per incident, which is the unique prefix
      incident_id = str_sub(stop_id, 1, str_length(stop_id) - 1),
      incident_date = parse_date(incident_date, "%m/%d/%y"),
      incident_time = parse_time(incident_time, "%H:%M:%S"),
      is_accident = as.logical(is_accident),
      subject_state = factor(subject_state, levels = valid_states),
      jge_state = factor(jge_state, levels = valid_states),
      court_date = parse_date(court_date, date_fmt),
      incident_lat = incident_lat / 1E6,
      incident_lng = incident_lng / 1E6,
      subject_race = tr_race[subject_race],
      subject_sex = tr_sex[subject_sex],
      incident_type = "vehicular",
      search_type = first_of(
        "consent" = search_consent,
        "probable cause" = search_probable_cause,
        "incident to arrest" = search_incident_to_arrest
      ),
      # TODO(journalist): how can we determine whether an arrest happened?
      # https://app.asana.com/0/456927885748233/475749789858290 
      arrest_made = !citation_issued && !warning_issued,
      incident_outcome = first_of(
        arrest = arrest_made,
        citation = citation_issued,
        warning = warning_issued
      )
    ) %>%
    select(
      # NOTE: drop unused foreign keys
      -c(LK_Lookup_Key, FA_Code)
    ) %>%
    # TODO(danj): what is stop id? how are these duplicated?
    # merge_rows(
    #   incident_id
    # ) %>%
    standardize(d$metadata)
}
