source("common.R")

load_raw <- function(raw_data_dir, n_max) {
  d <- load_single_file(
    raw_data_dir,
    "data.csv",
    na = c("", "NA","NULL", "N/A"),
    col_types = cols(.default = "c"),
    n_max = n_max
  )
  d_2017 <- load_single_file(
    raw_data_dir,
    "2017_data.csv",
    na = c("", "NA","NULL", "N/A"),
    col_types = cols(.default = "c"),
    n_max = n_max
  )
  
  troops <- load_single_file(raw_data_dir, "csp_troops.csv")
  counties <- load_single_file(raw_data_dir, "counties.csv")

  # NOTE: Some column names are missing; add them here. Other column names are
  # duplicated, so we use a numeric suffix.
  colnames(d$data)[1  ] <- "id_1"
  colnames(d$data)[78 ] <- "id_2"
  colnames(d$data)[79 ] <- "traffic_stop_id_1"
  colnames(d$data)[86 ] <- "id_3"
  colnames(d$data)[87 ] <- "traffic_stop_id_2"
  colnames(d$data)[104] <- "id_4"
  colnames(d$data)[107] <- "driver_last_name"
  colnames(d$data)[108] <- "driver_first_name"
  colnames(d$data)[105] <- "traffic_stop_id_3"
  colnames(d$data)[112] <- "driver_gender"
  colnames(d$data)[138] <- "officer_id"
  colnames(d$data)[139] <- "traffic_stop_id_4"
  colnames(d$data)[142] <- "officer_last_name"
  colnames(d$data)[143] <- "officer_first_name"
  colnames(d$data)[146] <- "officer_gender"

  d$data %>%
    bind_rows(
      d_2017$data %>% 
        rename(Age = AGE) %>% 
        mutate(
          Ethnicity = if_else(Ethnicity == "HIS", "H", Race),
          # change / to - in order to match main data pull, for parsing
          IncidentDate = str_replace_all(IncidentDate, "/", "-")
        )
    ) %>% 
    left_join(
      counties$data %>% 
        select(LocationCounty, county_name),
      by = "LocationCounty"
    ) %>%
    left_join(
      troops$data,
      by = c("TroopID" = "Troop")
    ) %>%
    bundle_raw(c(
      d$loading_problems,
      troops$loading_problems,
      counties$loading_problems
    ))
}


clean <- function(d, helpers) {
  tr_race <- c(
    A = "asian/pacific islander",
    AI = "unknown/other",
    AP = "asian/pacific islander",
    B = "black",
    H = "hispanic",
    I = "unknown/other",
    U = "unknown/other",
    W = "white",
    Z = "unknown/other",
    # include translations for 2017 data
    BLK = "black",
    NAN = "unknown/other",
    ORI = "asian/pacific islander",
    PAI = "asian/pacific islander",
    UNK = "unkown/other",
    WHT = "white"
  )

  tr_search_basis <- c(
    "Incident to Arrest" = "other",
    "Probable Cause" = "probable cause",
    "Consent" = "consent"
  )

  # NOTE: A row in the data is a citation. There may be multiple citations in
  # a stop. Group by the situational details of the stop and summarize to
  # create a single row for a stop. For search_conducted and contraband_found
  # fields, >99.9% all stops in group have same value. 
  # ALS: (not sure what this means or if it's still valid post contraband switch)
  d$data %>%
    group_by(
      officer_id,
      officer_first_name,
      officer_last_name,
      driver_first_name,
      driver_last_name,
      IncidentDate,
      IncidentTime,
      DOB,
      LocationCounty,
      # NOTE: county_name comes from counties.csv, a dictionary provided by the
      # department that converts LocationCounty 1-64 to county name
      county_name,
      LocationRoad,
      LocationMilePost
    ) %>%
    summarize(
      violation = str_c(StatuteDesc, collapse = "|"),
      SearchBase = first(SearchBase),
      department_id = first(TroopID),
      driver_gender = first(driver_gender),
      Ethnicity = first(Ethnicity),
      officer_gender = first(officer_gender),
      vehicle_make = first(Make),
      vehicle_model = first(Model),
      vehicle_year = first(Year),
      PlateState = first(PlateState),
      department_name = first(`Office Location`),
      # NOTE: For the remainder of the columns we take the unique value in the
      # group of rows, or return NA if there are multiple distinct values.
      # We use NA because we don't know what the right value should be.
      Arrest = unique_value(Arrest),
      Citation = unique_value(Citation),
      Search = unique_value(Search),
      SearchContraband = unique_value(SearchContraband),
      WrittenWarning = unique_value(WrittenWarning),
      OralWarning = unique_value(OralWarning)
    ) %>%
    ungroup(
    ) %>%
    mutate(
      # NOTE: Source data all describe state police traffic stops.
      type = "vehicular",
      location = str_c_na(LocationMilePost, LocationRoad, LocationCounty, sep = ", "),
      date = parse_date(IncidentDate, "%Y-%m-%d"),
      # NOTE: Timestamp contains fractional seconds, though the fractional part
      # is always 0. The seconds are also commonly 0, suggesting they are not
      # recorded consistently.
      time = parse_time(str_sub(1, 8, IncidentTime), "%H:%M:%S"),
      subject_dob = parse_date(DOB, "%Y-%m-%d"),
      subject_age = age_at_date(subject_dob, date),
      subject_race = tr_race[Ethnicity],
      subject_sex = tr_sex[driver_gender],
      officer_sex = tr_sex[officer_gender],
      # TODO(jnu): The original analysis suggests outcome / arrest data after
      # 2013 is bad. Follow up on this to clarify what's wrong and remove it
      # here as necessary.
      # https://app.asana.com/0/456927885748233/747485709822349
      arrest_made = Arrest == "1",
      citation_issued = Citation == "1",
      warning_issued = WrittenWarning == "1" | OralWarning == "1",
      outcome = first_of(
        warning = warning_issued,
        citation = citation_issued,
        arrest = arrest_made
      ),
      # NOTE: missing specific contraband type column.
      contraband_found = SearchContraband == "1",
      search_conducted = !is.na(SearchBase) | coalesce(Search == "1", FALSE),
      search_basis = tr_search_basis[SearchBase]
    ) %>%
    standardize(d$metadata)
}
