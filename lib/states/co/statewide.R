source(here::here("lib", "common.R"))

load_raw <- function(raw_data_dir, n_max) {
  d <- load_single_file(
    raw_data_dir,
    "data.csv",
    na = c("", "NA","NULL", "N/A"),
    col_types = cols(.default = "c"),
    n_max = n_max
  )
  d_2016 <- load_single_file(
    raw_data_dir,
    "2016_data.csv",
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
  colnames(d$data)[107] <- "subject_last_name"
  colnames(d$data)[108] <- "subject_first_name"
  colnames(d$data)[105] <- "traffic_stop_id_3"
  colnames(d$data)[112] <- "subject_gender"
  colnames(d$data)[138] <- "officer_id"
  colnames(d$data)[139] <- "traffic_stop_id_4"
  colnames(d$data)[142] <- "officer_last_name"
  colnames(d$data)[143] <- "officer_first_name"
  colnames(d$data)[146] <- "officer_gender"

  d$data %>%
    # filter(year(IncidentDate) < 2016) %>%
    mutate_at(vars(LocationCounty), as.character) %>%
    bind_rows(
      d_2016$data %>%
        mutate_at(vars(Warrant, ActivityID), as.character) %>% 
        rename(Age = AGE) %>% 
        mutate(
          Ethnicity = if_else(Ethnicity == "HIS", "H", Race),
          # change / to - in order to match main data pull, for parsing
          IncidentDate = str_replace_all(IncidentDate, "/", "-")
        ) %>% 
        # NOTE: d$data goes through march 2016 and has search data, d_2016 has 
        # the full year of 2016, but does not have search data, so we use the 
        # richer data (d$data) for the longest time periods possible
        filter(as.yearmon(IncidentDate) >= "Apr 2016") 
    ) %>%
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
        select(LocationCounty, county_name) %>% 
        mutate(LocationCounty = as.character(LocationCounty)),
      by = "LocationCounty"
    ) %>%
    # NOTE: fill in 2017 county with LocationCounty, 
    # which is name, not code (like the other years)
    mutate(
      county_name = if_else(
        is.na(county_name), 
        str_c(LocationCounty, " County"), 
        county_name
      )
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
    AI = "asian/pacific islander",
    AP = "asian/pacific islander",
    B = "black",
    H = "hispanic",
    I = "other",
    U = "unknown",
    W = "white",
    Z = "other",
    # include translations for 2017 data
    BLK = "black",
    NAN = "other",
    ORI = "asian/pacific islander",
    PAI = "asian/pacific islander",
    UNK = "unkown",
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
  d$data %>%
    rename(
      subject_middle_name = MiddleName,
      subject_drivers_license = DL,
      subject_drivers_license_state = DLState,
      vehicle_license_plate = Plate,
      vehicle_registration_state = PlateState
    ) %>%
    merge_rows(
      officer_id,
      officer_first_name,
      officer_last_name,
      subject_first_name,
      subject_middle_name,
      subject_last_name,
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
    add_raw_colname_prefix(
      Ethnicity
    ) %>% 
    mutate(
      # NOTE: Source data all should describe state police traffic stops.
      type = "vehicular",
      location = str_c_na(LocationMilePost, LocationRoad, LocationCounty, sep = ", "),
      date = parse_date(IncidentDate, "%Y-%m-%d"),
      # NOTE: Timestamp contains fractional seconds, though the fractional part
      # is always 0. The seconds are also commonly 0, suggesting they are not
      # recorded consistently.
      time = parse_time(str_sub(1, 8, IncidentTime), "%H:%M:%S"),
      subject_dob = parse_date(DOB, "%Y-%m-%d"),
      subject_age = age_at_date(subject_dob, date),
      subject_race = fast_tr(raw_Ethnicity, tr_race),
      subject_sex = fast_tr(subject_gender, tr_sex),
      officer_sex = fast_tr(officer_gender, tr_sex),
      # TODO: The original analysis suggests outcome / arrest data after
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
      violation = StatuteDesc,
      # NOTE: missing specific contraband type column.
      contraband_found = SearchContraband == "1",
      search_conducted = if_else(
        # Ensure that the large chunk of missing search data stays NA,
        # but for any NAs in the good data, cast to FALSE
        year(date) == 2016 & month(date) >= 4,
        NA,
        !is.na(SearchBase) | coalesce(Search == "1" | Search == "TRUE", FALSE)
      ),
      search_basis = fast_tr(SearchBase, tr_search_basis)
    ) %>%
    standardize(d$metadata)
}
