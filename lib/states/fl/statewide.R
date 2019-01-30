source(here::here("lib", "common.R"))
# NOTE: don't trust first half of 2010; looks like there was a ramp-up period
# as they begun to collect data. Things look fine starting in June 2010

load_raw <- function(raw_data_dir, n_max) {
  old_loaded <- load_regex(raw_data_dir, "^TSDR", n_max = n_max)
  old_loaded$data$schema_type = "TSDR"

  new_loaded <- load_regex(raw_data_dir, "^SRIS", n_max = n_max)
  new_loaded$data$schema_type = "SRIS"
  new_loaded$data <- rename(new_loaded$data, Ethnicity = ethnicity)
  
  data <- bind_rows(old_loaded$data, new_loaded$data)
  loading_problems <- c(
    old_loaded$loading_problems,
    new_loaded$loading_problems
  )
  bundle_raw(data, loading_problems)
}


clean <- function(d, helpers) {

  # NOTE: Replacing "NULL" with NA everywhere.
  d$data[d$data == "NULL"] <- NA

  old_data <- filter(d$data, schema_type == "TSDR") 

  # NOTE: There are also duplicate rows due to multiple violations per stop.
  # Some pertain to different passengers, and hence we sometimes cannot uniquely
  # identify the race of the driver.
  old_data <- old_data %>%
    merge_rows(ReportDateTime, County, OfficerIDNo) %>% 
    select(raw_row_number, ReportDateTime, County, OfficerIDNo, City, Race, Ethnicity,
           Sex, Age, VehicleTagNo, VehicleTagNoState, OfficerOrgUnit, OfficerAgency,
           OfficerName, Comments)
  
  print("Old data processed.")
  
  # NOTE: We do a similar deduplication as above for old_data.
  new_data <-
    d$data %>%
      filter(
        schema_type == "SRIS",
        !is.na(ReportDateTime)
      ) %>%
      merge_rows(ReportDateTime, County, OfficerIDNo) %>% 
      select(raw_row_number, ReportDateTime, County, OfficerIDNo, City, Race, Ethnicity, 
             Off_Age_At_Stop, Off_YrsExp_At_Stop, Off_Sex, Off_Race, OfficerOrgUnit, 
             ReasonForStop, starts_with("EnforcementAction"), starts_with("Violation"), 
             SearchType, starts_with("SearchRationale"), Comments) %>% 
      mutate(
        EnforcementAction1 = str_replace_all(EnforcementAction1, "NOT INDICATED", NA_character_),
        EnforcementAction1 = str_replace_all(EnforcementAction1, "NOT APPLICABLE", NA_character_),
        EnforcementAction2 = str_replace_all(EnforcementAction2, "NOT INDICATED", NA_character_),
        EnforcementAction2 = str_replace_all(EnforcementAction2, "NOT APPLICABLE", NA_character_),
        EnforcementAction3 = str_replace_all(EnforcementAction3, "NOT INDICATED", NA_character_),
        EnforcementAction3 = str_replace_all(EnforcementAction3, "NOT APPLICABLE", NA_character_),
        Violation1 = str_replace_all(Violation1, "NOT INDICATED", NA_character_),
        Violation1 = str_replace_all(Violation1, "NOT APPLICABLE", NA_character_),
        Violation2 = str_replace_all(Violation2, "NOT INDICATED", NA_character_),
        Violation2 = str_replace_all(Violation2, "NOT APPLICABLE", NA_character_),
        Violation3 = str_replace_all(Violation3, "NOT INDICATED", NA_character_),
        Violation3 = str_replace_all(Violation3, "NOT APPLICABLE", NA_character_),
        SearchRationale1 = str_replace_all(SearchRationale1, "NOT INDICATED", NA_character_),
        SearchRationale1 = str_replace_all(SearchRationale1, "NOT APPLICABLE", NA_character_),
        SearchRationale2 = str_replace_all(SearchRationale2, "NOT INDICATED", NA_character_),
        SearchRationale2 = str_replace_all(SearchRationale2, "NOT APPLICABLE", NA_character_),
        SearchRationale3 = str_replace_all(SearchRationale3, "NOT INDICATED", NA_character_),
        SearchRationale3 = str_replace_all(SearchRationale3, "NOT APPLICABLE", NA_character_),
        EnforcementAction = str_c_na(
          EnforcementAction1, 
          EnforcementAction2,
          EnforcementAction3,
          sep = "|"
        ),
        Violation = str_c_na(
          Violation1, 
          Violation2, 
          Violation3,
          sep = "|"
        ),
        SearchRationale = str_c_na(
          SearchRationale1,
          SearchRationale2,
          SearchRationale3,
          sep = "|"
        )
      )
  
  print("New data processed.")
  
  # NOTE: We join the data because some stops are in both old_data and new_data.
  joined_data <- full_join(
    old_data %>% 
      mutate(
        ReportDateTime = str_replace_all(ReportDateTime, "/", "-")
      ),
    new_data %>% 
      mutate(
        ReportDateTime = str_sub(ReportDateTime, 1, 19)
      ),
    by = c(
      "ReportDateTime",
      "City",
      "County",
      "OfficerIDNo",
      "Race",
      "Ethnicity"
    ),
    suffix = c("_old", "_new")
  )

  print("Old and new data joined.")
  
  joined_data %>%
    rename(
      location = City,
      county_name = County,
      subject_age = Age,
      officer_id = OfficerIDNo,
      officer_age = Off_Age_At_Stop,
      officer_last_name = OfficerName,
      officer_years_of_service = Off_YrsExp_At_Stop,
      department_name = OfficerAgency,
      violation = Violation,
      reason_for_search = SearchRationale,
      vehicle_registration_state = VehicleTagNoState
    ) %>%
    mutate(
      raw_row_number = str_c_na(raw_row_number_old, raw_row_number_new, sep = "|"),
      date = coalesce(
        parse_date(ReportDateTime, "%Y-%m-%d %H:%M:%S"),
        parse_date(ReportDateTime, "%Y-%m-%d")
      ),
      time = coalesce(
        parse_time(ReportDateTime, "%Y-%m-%d %H:%M:%S"),
        parse_time(ReportDateTime, "%Y-%m-%d")
      ),
      subject_race = if_else(
        !is.na(Ethnicity) & str_detect(Ethnicity, "H"),
        "hispanic",
        fast_tr(Race, tr_race)
      ),
      subject_sex = fast_tr(Sex, tr_sex),
      unit = if_else(
        is.na(OfficerOrgUnit_new),
        OfficerOrgUnit_old,
        OfficerOrgUnit_new
      ),
      officer_race = fast_tr(Off_Race, tr_race),
      officer_sex = fast_tr(Off_Sex, tr_sex),
      # NOTE: Only vehicular traffic stops were requested in the data request.
      type = "vehicular",
      arrest_made = str_detect(
        tolower(EnforcementAction),
        "felony arrest|misdemeanor arrest"
      ),
      citation_issued = str_detect(Comments_old, "Citation")
        | str_detect(
          tolower(EnforcementAction),
          # NOTE: These are all actually citations per Florida PD's
          # clarification.
          "infraction arrest|ucc issued|dver issued"
        ),
      warning_issued = str_detect(Comments_old, "Warning")
        | str_detect(
          tolower(EnforcementAction),
          "warning"
        ),
      outcome = first_of(
        "arrest" = arrest_made,
        "citation" = citation_issued,
        "warning" = warning_issued
      ),
      search_basis = first_of(
        "plain view" = str_detect(SearchType, "PLAIN VIEW"),
        "consent" = str_detect(SearchType, "CONSENT SEARCH CONDUCTED"),
        "probable cause" = str_detect(SearchType, "PROBABLE CAUSE"),
        "other" = str_detect(
          SearchType,
          "SEARCH INCIDENT TO ARREST|SEARCH WARRANT|INVENTORY"
        )
      ),
      search_conducted = if_else(
        !is.na(search_basis),
        TRUE,
        if_else(
          str_detect(
            SearchType,
            "NO SEARCH REQUESTED|NO SEARCH / CONSENT DENIED"
          ),
          FALSE,
          NA
        )
      ),
      frisk_performed = str_detect(SearchType, "STOP AND FRISK")
      # NOTE: Regarding contraband_found, there is data on items seized, but it
      # is not really clear how much this is as a result of a search.
    ) %>%
    standardize(d$metadata)
}
