source("common.R")

load_raw <- function(raw_data_dir, n_max) {
  d <- load_single_file(
    raw_data_dir,
    "data.csv",
    na = c("", "NA","NULL", "N/A"),
    col_types = cols(.default = "c", Search = "d"),
    n_max = n_max
  )

  troops <- load_single_file(raw_data_dir, "csp_troops.csv")
  counties <- load_single_file(raw_data_dir, "counties.csv")

  # NOTE: Some column names are duplicated
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

  # NOTE: A row in the data is a citation. There may be multiple citations in
  # a stop. Group by the situational details of the stop and summarize to
  # create a single row for a stop. For search_conducted and contraband_found
  # fields, >99.9% all stops in group have same value.
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
      LocationMilePost
    ) %>%
    summarize(
      StatuteDesc = str_c(StatuteDesc, collapse = "|"),
      SearchBase = first(SearchBase),
      TroopID = first(TroopID),
      driver_gender = first(driver_gender),
      Ethnicity = first(Ethnicity),
      officer_gender = first(officer_gender),
      Make = first(Make),
      Model = first(Model),
      Year = first(Year),
      PlateState = first(PlateState),
      Arrest = if_else(
        length(unique(Arrest)) == 1,
        first(Arrest),
        NA_character_
      ),
      Citation = if_else(
        length(unique(Citation)) == 1,
        first(Citation),
        NA_character_
      ),
      Search = if_else(
        length(unique(Search)) == 1,
        first(Search),
        NA_character_
      ),
      SearchContraband = if_else(
        length(unique(SearchContraband)) == 1,
        first(SearchContraband),
        NA_character_
      ),
      WrittenWarning = if_else(
        length(unique(WrittenWarning)) == 1,
        first(WrittenWarning),
        NA_character_
      ),
      OralWarning = if_else(
        length(unique(OralWarning)) == 1,
        first(OralWarning),
        NA_character_
      )
    ) %>%
    ungroup(
    ) %>%
    left_join(
      troops$data,
      by = c("TroopID" = "Troop")
    ) %>%
    left_join(
      counties$data
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
    Z = "unknown/other"
  )

  tr_sex <- c(
    Male = "male",
    Female = "female"
  )

  tr_search_basis = c(
    "Incident to Arrest" = "other",
    "Probable Cause" = "probable cause",
    "Consent" = "consent"
  )

  d$data %>%
    rename(
      department_name = `Office Location`,
      department_id = TroopID,
      vehicle_make = Make,
      vehicle_model = Model,
      vehicle_year = Year,
      violation = StatuteDesc
    ) %>%
    mutate(
      # NOTE: Source data all describe state police traffic stops.
      stop_type = "vehicular",
      location = str_c_na(LocationMilePost, LocationRoad, LocationCounty, sep = ", "),
      date = parse_date(IncidentDate, "%Y-%m-%d"),
      # NOTE: Timestamp contains fractional seconds, though the fractional part
      # is always 0. The seconds are also commonly 0, suggesting they are not
      # recorded consistently.
      time = parse_time(str_sub(1, 8, IncidentTime), "%H:%M:%S"),
      dob = parse_date(DOB, "%Y-%m-%d"),
      subject_age = age_at_date(dob, date),
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
      search_conducted = (!is.na(d$SearchBase))
        | ((d$Search == "1") & (!is.na(d$Search))),
      search_type = tr_search_basis[SearchBase]
    ) %>%
    standardize(d$metadata)
}
