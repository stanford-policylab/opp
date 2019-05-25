source(here::here("lib", "common.R"))
# NOTE: don't trust first half of 2010; looks like there was a ramp-up period
# as they begun to collect data. Things look fine starting in June 2010

load_raw <- function(raw_data_dir, n_max) {
  old_loaded <- load_regex(raw_data_dir, "^TSDR", n_max = n_max)
  old_loaded$data$schema_type = "TSDR"

  new_loaded <- load_regex(raw_data_dir, "^SRIS", n_max = n_max)
  new_loaded$data$schema_type = "SRIS"
  new_loaded$data <- rename(new_loaded$data, Ethnicity = ethnicity)
  
  d <- load_regex(raw_data_dir, "^florida_20", n_max = n_max)
  d$data <- d$data %>% 
    unite("OfficerName", OfficerNameFirst, OfficerNameLast, sep = " ")
  d$data$schema_type = "16_to_18"
  
  data <- bind_rows(old_loaded$data, new_loaded$data, d$data)
  loading_problems <- c(
    old_loaded$loading_problems,
    new_loaded$loading_problems,
    d$loading_problems
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
    select(
      raw_row_number, ReportDateTime, County, OfficerIDNo, City, Race, Ethnicity,
      Sex, Age, VehicleTagNo, VehicleTagNoState, OfficerOrgUnit, OfficerAgency,
      OfficerName, Comments
    ) %>% 
    merge_rows(ReportDateTime, County, OfficerIDNo)
  
  print("Old data processed.")
  
  # NOTE: We do a similar deduplication as above for old_data.
  new_data <-
    d$data %>%
      filter(
        schema_type == "SRIS",
        !is.na(ReportDateTime)
      ) %>%
      select(
        raw_row_number, ReportDateTime, County, OfficerIDNo, City, Race, Ethnicity, 
        Off_Age_At_Stop, Off_YrsExp_At_Stop, Off_Sex, Off_Race, OfficerOrgUnit, 
        ReasonForStop, starts_with("EnforcementAction"), starts_with("Violation"), 
        SearchType, starts_with("SearchRationale"), Comments
      ) %>% 
      merge_rows(ReportDateTime, County, OfficerIDNo) %>% 
      mutate(
        EnforcementAction1 = str_replace_all(
          EnforcementAction1, "NOT INDICATED", NA_character_
        ),
        EnforcementAction1 = str_replace_all(
          EnforcementAction1, "NOT APPLICABLE", NA_character_
        ),
        EnforcementAction2 = str_replace_all(
          EnforcementAction2, "NOT INDICATED", NA_character_),
        EnforcementAction2 = str_replace_all(
          EnforcementAction2, "NOT APPLICABLE", NA_character_
        ),
        EnforcementAction3 = str_replace_all(
          EnforcementAction3, "NOT INDICATED", NA_character_
        ),
        EnforcementAction3 = str_replace_all(
          EnforcementAction3, "NOT APPLICABLE", NA_character_
        ),
        Violation1 = str_replace_all(Violation1, "NOT INDICATED", NA_character_),
        Violation1 = str_replace_all(Violation1, "NOT APPLICABLE", NA_character_),
        Violation2 = str_replace_all(Violation2, "NOT INDICATED", NA_character_),
        Violation2 = str_replace_all(Violation2, "NOT APPLICABLE", NA_character_),
        Violation3 = str_replace_all(Violation3, "NOT INDICATED", NA_character_),
        Violation3 = str_replace_all(Violation3, "NOT APPLICABLE", NA_character_),
        SearchRationale1 = str_replace_all(
          SearchRationale1, "NOT INDICATED", NA_character_
        ),
        SearchRationale1 = str_replace_all(
          SearchRationale1, "NOT APPLICABLE", NA_character_
        ),
        SearchRationale2 = str_replace_all(
          SearchRationale2, "NOT INDICATED", NA_character_
        ),
        SearchRationale2 = str_replace_all(
          SearchRationale2, "NOT APPLICABLE", NA_character_
        ),
        SearchRationale3 = str_replace_all(
          SearchRationale3, "NOT INDICATED", NA_character_
        ),
        SearchRationale3 = str_replace_all(
          SearchRationale3, "NOT APPLICABLE", NA_character_
        ),
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
          SearchRationale4,
          sep = "|"
        )
      ) %>% 
      select(-ends_with("1"), -ends_with("2"), -ends_with("3"), -ends_with("4"))
  
  print("Updated data processed.")
  
  data_16_to_18 <- 
    d$data %>%
    filter(
      schema_type == "16_to_18"
    ) %>%
    select(
      raw_row_number, ReportDateTime, County, OfficerIDNo, Race, 
      OfficerOrgUnit, ReasonForStop, starts_with("EnforcementAction"), 
      starts_with("Violation"), SearchType, starts_with("SearchRationale")
    ) %>% 
    merge_rows(ReportDateTime, County, OfficerIDNo) %>% 
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
        SearchRationale4,
        sep = "|"
      )
    ) %>% 
    select(-ends_with("1"), -ends_with("2"), -ends_with("3"), -ends_with("4"))
  
  print("New years of data processed.")
  
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
  ) %>% 
    full_join(
      data_16_to_18 %>% 
        mutate(
          ReportDateTime = str_replace_all(ReportDateTime, "/", "-")
        ),
      by = c(
          "ReportDateTime",
          "County",
          "OfficerIDNo",
          "Race",
          "EnforcementAction",
          "Violation",
          "SearchRationale",
          "ReasonForStop",
          "SearchType"
        ),
      suffix = c("_10_to_16", "_16_to_18")
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
      reason_for_stop = ReasonForStop,
      vehicle_registration_state = VehicleTagNoState
    ) %>%
    add_raw_colname_prefix(
      Race,
      Ethnicity,
      EnforcementAction,
      SearchType
    ) %>% 
    mutate(
      raw_row_number = str_c_na(
        raw_row_number_old, 
        raw_row_number_new,
        raw_row_number,
        sep = "|"),
      date = coalesce(
        parse_date(ReportDateTime, "%Y-%m-%d %H:%M:%S"),
        parse_date(ReportDateTime, "%Y-%m-%d")
      ),
      time = coalesce(
        parse_time(ReportDateTime, "%Y-%m-%d %H:%M:%S"),
        parse_time(ReportDateTime, "%Y-%m-%d")
      ),
      subject_race = if_else(
        !is.na(raw_Ethnicity) & str_detect(raw_Ethnicity, "H"),
        "hispanic",
        fast_tr(raw_Race, tr_race)
      ),
      subject_sex = fast_tr(Sex, tr_sex),
      county_name = str_c(str_to_title(county_name), " County"),
      unit = if_else(
        is.na(OfficerOrgUnit_new),
        OfficerOrgUnit_old,
        OfficerOrgUnit_new
      ),
      officer_race = fast_tr(Off_Race, tr_race),
      officer_sex = fast_tr(Off_Sex, tr_sex),
      # NOTE: Only vehicular traffic stops were requested in the data request.
      type = "vehicular",
      notes = str_c_na(Comments_old, Comments_new, sep = ";"),
      arrest_made = str_detect(notes, fixed("arrest", ignore_case = T)) 
        | str_detect(
            raw_EnforcementAction,
            # Note: Infraction Arrest we think is just a citation (quite common)
            fixed("felony arrest|misdemeanor arrest", ignore_case = T)
          ),
      citation_issued = 
        str_detect(notes, fixed("citation", ignore_case = T))
        | str_detect(raw_EnforcementAction,
            # NOTE: These are all actually citations per Florida PD's
            # clarification.
            fixed("infraction arrest|ucc issued|dver issued", ignore_case = T)
          ),
      warning_issued = str_detect(notes, fixed("warning", ignore_case = T))
        | str_detect(raw_EnforcementAction, fixed("warning", ignore_case = T)),
      outcome = first_of(
        "arrest" = arrest_made,
        "citation" = citation_issued,
        "warning" = warning_issued
      ),
      search_basis = first_of(
        "plain view" = str_detect(
          raw_SearchType, fixed("PLAIN VIEW", ignore_case = T)
        ),
        "consent" = str_detect(
          raw_SearchType, fixed("CONSENT SEARCH CONDUCTED", ignore_case = T)
        ),
        "probable cause" = str_detect(
          raw_SearchType, fixed("PROBABLE CAUSE", ignore_case = T)
        ),
        "other" = str_detect(
          raw_SearchType,
          fixed("SEARCH INCIDENT TO ARREST|SEARCH WARRANT|INVENTORY", ignore_case = T)
        )
      ),
      search_conducted = if_else(
        !is.na(search_basis),
        TRUE,
        if_else(
          str_detect(
            raw_SearchType,
            "NO SEARCH REQUESTED|NO SEARCH / CONSENT DENIED"
          ),
          FALSE,
          NA
        )
      ),
      frisk_performed = str_detect(
        raw_SearchType, fixed("STOP AND FRISK", ignore_case = T)
      )
      # NOTE: Regarding contraband_found, there is data on items seized, but it
      # is not really clear how much this is as a result of a search.
    ) %>%
    standardize(d$metadata)
}
