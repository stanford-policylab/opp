source(here::here("lib", "common.R"))

load_raw <- function(raw_data_dir, n_max) {
  #  Vehicle dictionaries
  wi_vehiclebodystyle <- load_single_file(
    file.path(raw_data_dir, "dictionaries"),
    "jennifer_mobley_-_codes-vehiclebodystyle_sheet_1.csv"
  )
  wi_vehiclemake_1 <- load_single_file(
    file.path(raw_data_dir, "dictionaries"),
    "jennifer_mobley_-_tracs_10-codes-vehiclemake_sheet_1.csv"
  )
  wi_vehiclemake_2 <- load_single_file(
    file.path(raw_data_dir, "dictionaries"),
    "jennifer_mobley_-_tracs_7.3-codes-vehiclemake_sheet_1.csv"
  )
  add_vehicle_make <- function(data, vehiclemake) {
    left_join(
      data,
      vehiclemake$data,
      by = c("make" = "CodeValue")
    ) %>%
    rename(vehicle_make = CodeText)
  }

  # Warnings data
  wi_warn_1 <- load_single_file(
    raw_data_dir,
    "tracs10_trafficstops_outcomewarnings.csv",
    n_max = n_max
  )
  wi_warn_2 <- load_single_file(
    raw_data_dir,
    "tracs7.3_trafficstops_outcomewarnings.csv",
    n_max = n_max
  )
  wi_warn <- bind_rows(
    # First warnings data
    add_vehicle_make(
      wi_warn_1$data,
      wi_vehiclemake_1
    ) %>%
    rename(StatuteDescription = WarningStatuteDescription),
    # Second warnings data
    rename(
      wi_warn_2$data,
      IndividualMultiKey = individualMultiKey,
      IndividualGrp_lnk = UnitGrp_IndividualGrp_lnk,
      summaryDateOccurred = summaryDateOccured,
      VehicleCompanyName = vehicleNameCompany,
      # NOTE: Every last cell in source ends with a lot of extraneous
      # commas, including the header. Get rid of all of these.
      StatuteDescription = `WarningStatuteDescription,,,,,,,,,,,,,,,,`
    ) %>%
    mutate(
      StatuteDescription = str_replace(StatuteDescription, ",+$", "")
    ) %>%
    add_vehicle_make(wi_vehiclemake_2)
  )

  # Citations data
  wi_cit_1 <- load_single_file(
    raw_data_dir,
    "tracs10_trafficstops_outcomecitations.csv",
    n_max = n_max
  )
  wi_cit_2 <- load_single_file(
    raw_data_dir,
    "tracs7.3_trafficstops_outcomecitations.csv",
    n_max = n_max
  )
  wi_cit <- bind_rows(
    # First citations data
    add_vehicle_make(wi_cit_1$data, wi_vehiclemake_1),
    # Second citations data
    rename(
      wi_cit_2$data,
      # NOTE: Make names consistent with wi_cit_1 for binding rows.
      IndividualMultiKey = individualMultiKey,
      IndividualGrp_lnk = UnitGrp_IndividualGrp_lnk,
      summaryDateOccurred = summaryDateOccured,
      VehicleCompanyName = vehicleNameCompany
    ) %>%
    add_vehicle_make(wi_vehiclemake_2)
  ) %>%
  rename(StatuteDescription = CitationStatuteDescription)

  # County dictionary
  wi_county <- load_single_file(
    file.path(raw_data_dir, "dictionaries"),
    "jennifer_mobley_-_codes-county.csv"
  )

  bind_rows(
    wi_warn,
    wi_cit
  ) %>%
  # NOTE: Each row represents a single violation for a stop; an entire stop
  # may span multiple rows. Collapse to one row per stop, combining
  # violations into a list. Note that we're grouping by all the columns
  # except for those containing statute info, so that each group represents
  # a single stop and the items within that group represent individual charges
  # alleged in that stop.
  group_by(
    summaryDateOccurred,
    summaryTimeOccurred,
    onHighwayDirection,
    onHighwayName,
    fromAtStreetName,
    agencyJurisdiction,
    agencyDOTOfficerIdentificationNumber,
    agencyOfficerNameFirst,
    agencyOfficerNameLast,
    agencyNameDepartment,
    agencyBFUNCAgencyCode,
    race,
    sex,
    longitude,
    latitude,
    countyDMV,
    individualSearchConducted,
    vehicleSearchConducted,
    individualContraband,
    vehicleContraband,
    summaryOutcome,
    bodyStyle,
    vehicle_make,
    color,
    model,
    modelYear,
    individualSearchBasis,
    vehicleSearchBasis,
    registrationIssuanceState
  ) %>%
  summarize(
    all_violations = str_c_na(StatuteDescription, collapse = "|")
  ) %>%
  ungroup(
  ) %>%
  # NOTE: County column mostly uses two-digit codes, but some use the format
  # `<NAME> - <CODE>`. Normalize column to use two-digit codes to join with
  # county data.
  mutate(
    county_code = gsub("[^0-9]", "", countyDMV)
  ) %>%
  left_join(
    wi_county$data,
    by = c("county_code" = "CodeValue")
  ) %>%
  left_join(
    wi_vehiclebodystyle$data,
    by = c("bodyStyle" = "CodeValue")
  ) %>%
  rename(
    vehicle_type = Alias
  ) %>%
  bundle_raw(c(
    wi_warn_1$loading_problems,
    wi_warn_2$loading_problems,
    wi_cit_1$loading_problems,
    wi_cit_2$loading_problems,
    wi_county$loading_problems,
    wi_vehiclemake_1$loading_problems,
    wi_vehiclemake_2$loading_problems,
    wi_vehiclebodystyle$loading_problems
  ))
}


clean <- function(d, helpers) {

  d$data %>%
    rename(
      department_id = agencyBFUNCAgencyCode,
      department_name = agencyNameDepartment,
      county_name = CountyName,
      officer_first_name = agencyOfficerNameFirst,
      officer_last_name = agencyOfficerNameLast,
      vehicle_model = model,
      vehicle_color = color,
      vehicle_registration_state = registrationIssuanceState,
      vehicle_year = modelYear,
      violation = all_violations
    ) %>%
    mutate(
      # NOTE: Date and time columns are both full `datetime` columns, but only
      # the relevant half of each is useful. That is, for the date column all
      # times are midnight and for the time column all dates are Jan 1, 1900.
      # In addition, some time values only use HH:MM instead of HH:MM:SS; but
      # even if seconds are given, they are always :00.
      date_raw = parse_date(str_sub(summaryDateOccurred, 1, 10), "%Y-%m-%d"),
      # NOTE: There are a few dates that can't possibly be correct given the
      # years the source files represent. Eliminate them.
      date = if_else(year(date_raw) < 2010, as.Date(NA), date_raw),
      time = coalesce(
        parse_time(summaryTimeOccurred, "%H:%M"),
        parse_time(str_sub(summaryTimeOccurred, 12, 19), "%H:%M:%S")
      ),
      location = str_c_na(
        onHighwayDirection,
        onHighwayName,
        fromAtStreetName,
        county_name
      ),
      lat = as.numeric(latitude),
      lng = as.numeric(longitude),
      # NOTE: Sources only include vehicle stops.
      type = "vehicular",
      subject_race = tr_race[race],
      subject_sex = tr_sex[sex],
      # NOTE: Outcome codes come from data dictionary. A stop may have one or
      # more of these codes.
      arrest_made = str_detect(summaryOutcome, "5"),
      citation_issued = str_detect(summaryOutcome, "4"),
      warning_issued = str_detect(summaryOutcome, "[23]"),
      outcome = first_of(
        arrest = arrest_made,
        citation = citation_issued,
        warning = warning_issued
      ),
      search_person = tr_yn[individualSearchConducted],
      search_vehicle = tr_yn[vehicleSearchConducted],
      search_conducted = search_person | search_vehicle,
      # NOTE: Search codes come from data dictionary. There is no code for
      # "plain view."
      search_basis = first_of(
        "consent" = str_detect(individualSearchBasis, "1")
          | str_detect(vehicleSearchBasis, "1"),
        "probable cause" = str_detect(individualSearchBasis, "2")
          | str_detect(vehicleSearchBasis, "2"),
        "other" = str_detect(individualSearchBasis, "[34569]")
          | str_detect(vehicleSearchBasis, "[34569]")
      ),
      # NOTE: Contraband codes come from data dictionary:
      #03,"ILLICIT DRUG(S)/PARAPHERNALIA"
      #05,INTOXICANT(S)
      #01,WEAPON(S)
      #04,"EVIDENCE OF A CRIME"
      #06,"STOLEN GOODS"
      #02,"EXCESSIVE CASH"
      #00,NONE
      #99,OTHER
      contraband_drugs = str_detect(individualContraband, "3")
        | str_detect(vehicleContraband, "3"),
      contraband_weapons = str_detect(individualContraband, "1")
        | str_detect(vehicleContraband, "1"),
      contraband_alcohol = str_detect(individualContraband, "5")
      | str_detect(vehicleContraband, "5"),
      contraband_other = str_detect(individualContraband, "4|6|2|99")
      | str_detect(vehicleContraband, "4|6|2|99"),
      contraband_found = contraband_drugs | contraband_weapons | contraband_alcohol | contraband_other
    ) %>%
    standardize(d$metadata)
}
