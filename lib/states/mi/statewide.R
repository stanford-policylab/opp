source(here::here("lib", "common.R"))

# NOTE: don't trust data until 2013 (2012 still seems a bit low, but 
# definitely don't use the data before 2012.)
# NOTE: there are some spike abberations 4x/year
# NOTE: race data seems shoddy.

load_raw <- function(raw_data_dir, n_max) {
  d <- load_single_file(raw_data_dir, "data.csv", n_max = n_max)
  bundle_raw(d$data, d$loading_problems)
}


clean <- function(d, helpers) {
  tr_county <- json_to_tr(helpers$load_json("MI_counties.json"))
  tr_race <- c(
    W = "white",
    B = "black",
    H = "hispanic",
    A = "asian/pacific islander",
    I = "other",
    U = "unknown"
  )

  # NOTE: Replacing "NULL" with NA everywhere.
  d$data[d$data == "NULL"] <- NA

  d$data %>%
    add_raw_colname_prefix(
      Race
    ) %>% 
    mutate(
      Warning = parse_logical(Warning)
    ) %>%
    # NOTE: Deduping because each row corresponds to a violation, not to a stop.
    merge_rows(
      ArrestNum,
      CountyCode,
      Department,
      DepartmentNum,
      NearStreet,
      PrimaryOfficerID,
      raw_Race,
      TicketDate,
      UponStreet,
      VehicleID
    ) %>% 
    rename(
      # NOTE: We also have Felony, Misdemeanor, CivilInfraction and several
      # court related columns to help refine the outcome.
      violation = ViolationCode,
      reason_for_stop = Description,
      officer_id = PrimaryOfficerID,
      department_id = DepartmentNum,
      department_name = Department
    ) %>%
    mutate(
      date = date(parse_datetime(TicketDate)),
      time = parse_time(TicketDate, "%Y-%m-%d %H:%M:%S"),
      # TODO: To geocode, we would need to translate CityTownshipCode
      # and add to location.
      # https://app.asana.com/0/456927885748233/727769678078689
      location = str_combine_cols(
        UponStreet,
        NearStreet,
        prefix_right = "near: ",
        sep = " "
      ),
      county_name = fast_tr(CountyCode, tr_county),
      subject_race = fast_tr(raw_Race, tr_race),
      # NOTE: All rows have a non-NULL VehicleID or have a ConfiscatedPlate and
      # a non-zero VehicleImpounded code.
      type = "vehicular",
      arrest_made = !is.na(ArrestNum),
      warning_issued = str_detect("TRUE", Warning),
      # NOTE: All rows have a TicketNum. Here we assume that if any ticket is
      # not a warning, then it is a citation.  But then potentially for outcome,
      # anything that is not an arrest or warning could have a court summons.
      # TODO(walterk): Figure out if we should try to disambiguate the outcome
      # summons and citation cases, leave it as citation, or set as NA. In
      # addition to Warning, we also have Felony, Misdemeanor, CivilInfraction
      # and several court related columns to help refine the outcome.
      # https://app.asana.com/0/456927885748233/733631522707204
      citation_issued = !warning_issued,
      outcome = first_of(
        "arrest" = arrest_made,
        "citation" = citation_issued,
        "warning" = warning_issued
      ),
      speed = SpeedDetected,
      posted_speed = SpeedPosted,
      charged_speed = SpeedCharged
    ) %>%
    standardize(d$metadata)
}
