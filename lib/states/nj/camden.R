source("common.R")


# VALIDATION: [YELLOW] For 2013 and 2018 there is only half of the year of
# data. The Camden PD doesn't appear to have released any annual report
# recently, so it's hard to validate these numbers. They are a little high some
# years relative to the population, but crime in Camden has also been high, so
# these may be reasonable figures
load_raw <- function(raw_data_dir, n_max) {
  d <- load_years(raw_data_dir, n_max)
  mutate(
    d$data,
    case_number = coalesce(`Case number`, Casenumber)
  ) %>%
  select(
    -`Case number`,
    -Casenumber,
    -X17,
    -X18,
    -X19
  ) %>%
  bundle_raw(d$loading_problems)
}


clean <- function(d, helpers) {

  tr_race <- c(
    tr_race,
    "asian/pacific islndr" = "asian/pacific islander",
    "native hawaiian or other pacific islander" = "asian/pacific islander",
    "american indian or alaska native" = "other"
  )

  # TODO(phoebe): can we get reason_for_stop/search/contraband fields?
  # https://app.asana.com/0/456927885748233/757611127540101
  d$data %>%
  merge_rows(
    case_number,
    `Incident Datetime`,
    IncidentLocation,
    OfficerName,
    SubjectGender,
    Race,
    Ethnicity,
    DateofBirth,
    VehicleYear,
    Color,
    Make,
    Model
  ) %>%
  rename(
    location = IncidentLocation,
    vehicle_registration_state = `License State`,
    vehicle_year = VehicleYear,
    vehicle_color = Color,
    vehicle_make = Make,
    vehicle_model = Model,
    # NOTE: all officer names are in last name since there are punctuation or
    # spaces between the first and last names
    officer_last_name = OfficerName,
    unit = Unit
  ) %>%
  mutate(
    # NOTE: There are TRAFFIC STOP and PEDESTRIAN STOP and what looks like
    # some accidental free form text for this column, but most reference
    # patrol so classifying as vehicular
    type = if_else_na(
      CFS_Code == "PEDESTRIAN STOP",
      "pedestrian",
      "vehicular"
    ),
    datetime = parse_datetime(`Incident Datetime`, "%Y/%m/%d %H:%M:%S"),
    date = as.Date(datetime),
    time = format(datetime, "%H:%M:%S"),
    subject_sex = tr_sex[SubjectGender],
    subject_race = tr_race[if_else_na(
      Ethnicity == "Hispanic Or Latino",
      "hispanic",
      tolower(Race)
    )],
    subject_dob = parse_date(DateofBirth),
    disposition = tolower(Disposition),
    # NOTE: FIELD CONTACT CARD just records the event when no action was
    # taken
    warning_issued = str_detect(disposition, "warning"),
    # NOTE: according to the PD, summons is a citation
    citation_issued = str_detect(disposition, "summons"),
    arrest_made = str_detect(disposition, "arrest"),
    outcome = first_of(
      arrest = arrest_made,
      citation = citation_issued,
      warning = warning_issued
    )
  ) %>%
  rename(
    raw_ethnicity = Ethnicity,
    raw_race = Race
  ) %>%
  helpers$add_lat_lng(
  ) %>%
  standardize(d$metadata)
}
