source(here::here("lib", "common.R"))


load_raw <- function(raw_data_dir, n_max) {
  d <- load_regex(raw_data_dir, "^connecticut", n_max = n_max)
  bundle_raw(d$data, d$loading_problems)
}


clean <- function(d, helpers) {
  tr_county <- json_to_tr(helpers$load_json("CT_counties.json"))

  tr_race <- c(
    A = "asian/pacific islander",
    B = "black",
    H = "hispanic",
    W = "white",
    # Native American
    I = "other/unknown"
  )

  tr_search_basis <- c(
    C = "consent",
    O = "probable cause",
    # inventory
    I = "other"
  )

  d$data %>%
    add_raw_colname_prefix(
      SubjectRaceCode,
      SubjectEthnicityCode,
      SearchAuthorizationCode,
      InterventionDispositionCode
    ) %>% 
    rename(
      subject_age = SubjectAge,
      officer_id = ReportingOfficerIdentificationID,
      department_name = `Department Name`
    ) %>%
    mutate(
      date = as.Date(parse_datetime(InterventionDateTime)),
      # NOTE: The time 00:00 appears more than 10x over the next most frequent
      # time (minute granularity).
      time = parse_time(InterventionTime, "%H:%M"),
      location = str_c_na(
        InterventionLocationDescriptionText,
        InterventionLocationName,
        sep=", "
      ),
      lat = parse_coord(InterventionLocationLatitude),
      lat = replace(lat, lat == 0, NA_real_),
      lng = -1 * abs(parse_coord(InterventionLocationLongitude)),
      lng = replace(lng, lng == 0, NA_real_),
      county_name = fast_tr(tolower(InterventionLocationName), tr_county),
      subject_race = tr_race[if_else(
        raw_SubjectEthnicityCode == "H",
        "H",
        raw_SubjectRaceCode
      )],
      subject_sex = tr_sex[SubjectSexCode],
      contraband_found = ContrabandIndicator == "True",
      search_vehicle = VehicleSearchedIndicator == "True",
      search_conducted = search_vehicle | raw_SearchAuthorizationCode != "N",
      # 5 NA search instances, cast to false
      search_conducted = replace_na(search_conducted, FALSE),
      search_basis = tr_search_basis[raw_SearchAuthorizationCode]
    ) %>%
    # NOTE: Some rows belong to the same stop.  We dedup below with a group_by
    # and aggregate to potentially have multiple violations and multiple
    # reasons for stop.  For the outcome, we take the most severe outcome.
    merge_rows(
      contraband_found,
      county_name,
      CustodialArrestIndicator,
      date,
      department_name,
      lat,
      lng,
      location,
      officer_id,
      search_basis,
      search_conducted,
      search_vehicle,
      subject_age,
      subject_race,
      raw_SubjectRaceCode,
      raw_SubjectEthnicityCode,
      subject_sex,
      time
    ) %>%
    rename(
      # NOTE: There is also StatutatoryCitationPostStop which is the violation
      # the individual was cited for.
      violation = StatuteCodeIdentificationID,
      reason_for_stop = StatutoryReasonForStop,
      multi_outcome = raw_InterventionDispositionCode
    ) %>%
    mutate(
      arrest_made = CustodialArrestIndicator == "True"
        | str_detect(multi_outcome, "U"),
      summons_issued = str_detect(multi_outcome, "M"),
      citation_issued = str_detect(multi_outcome, "I"),
      warning_issued = str_detect(multi_outcome, "W|V"),
      outcome = first_of(
        "arrest" = arrest_made,
        "summons" = summons_issued,
        "citation" = citation_issued,
        "warning" = warning_issued
      ),
      type = if_else(
        # NOTE: Inferring type "vehicular" based on search_vehicle and whether
        # the violation section is of the form 14-XXX.
        # See: https://www.cga.ct.gov/2015/pub/title_14.htm
        search_vehicle | str_detect(violation, "(^|\\|)14(-.*)?($|\\|)"),
        "vehicular",
        NA_character_
      )
    ) %>%
    standardize(d$metadata)
}
