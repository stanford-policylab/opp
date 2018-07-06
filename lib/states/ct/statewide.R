source("common.R")


load_raw <- function(raw_data_dir, n_max) {
  d <- load_regex(
    raw_data_dir,
    "^connecticut",
    n_max = n_max
  )
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
    I = "other" # inventory
  )

  multi_to_string <- function(x) {
    str_c(str_sort(unique(x)), collapse=",")
  }

  d$data %>%
    rename(
      subject_age = SubjectAge,
      officer_id = ReportingOfficerIdentificationID,
      department_name = `Department Name`
    ) %>%
    mutate(
      date = date(parse_datetime(InterventionDateTime)),
      # NOTE: The time 00:00 appears more than 10x over the next most frequent
      # time (minute granularity). Opting to convert 00:00 to NA.
      time = if_else(
        InterventionTime != "00:00",
        parse_time(InterventionTime, "%H:%M"),
        NA_real_
      ),
      location = str_c_na(
        InterventionLocationDescriptionText,
        InterventionLocationName,
        sep=", "
      ),
      # TODO(walterk): Modify Joe's parse_coord to be able to parse coords like
      # "41 22 35.2308" once his PR lands:
      # https://github.com/stanford-policylab/opp/pull/12
      lat = parse_coord(InterventionLocationLatitude),
      lat = replace(lat, lat == 0, NA_real_),
      lng = -1 * abs(parse_coord(InterventionLocationLongitude)),
      lng = replace(lng, lng == 0, NA_real_),
      county_name = fast_tr(tolower(InterventionLocationName), tr_county),
      subject_race = tr_race[if_else(
        SubjectEthnicityCode == "H",
        "H",
        SubjectRaceCode
      )],
      subject_sex = tr_sex[SubjectSexCode],
      contraband_found = ContrabandIndicator == "True",
      search_vehicle = VehicleSearchedIndicator == "True",
      search_conducted = search_vehicle | SearchAuthorizationCode != "N",
      search_basis = tr_search_basis[SearchAuthorizationCode]
    ) %>%
    # NOTE: Some rows belong to the same stop.  We dedup below with a group_by
    # and aggregate to potentially have multiple violations and multiple
    # reasons for stop.  For the outcome, we take the most severe outcome.
    group_by(
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
      subject_sex,
      time
    ) %>%
    summarize(
      # NOTE: There is also StatutatoryCitationPostStop which is the violation
      # the individual was cited for.
      violation = multi_to_string(StatuteCodeIdentificationID),
      reason_for_stop = multi_to_string(StatutoryReasonForStop),
      multi_outcome = multi_to_string(InterventionDispositionCode)
    ) %>%
    ungroup(
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
        search_vehicle | grepl("(^|,)14(-.*)?($|,)", violation),
        "vehicular",
        NA_character_
      )
    ) %>%
    standardize(d$metadata)
}
