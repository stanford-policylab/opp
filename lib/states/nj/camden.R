source("common.R")

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

  tr_race <- c(tr_race,
    "asian/pacific islndr" = "asian/pacific islander",
    "native hawaiian or other pacific islander" = "asian/pacific islander",
    "unknown" = "other/unknown",
    "american indian or alaska native" = "other/unknown"
  )

  # TODO(phoebe): can we get reason_for_stop/search/contraband fields?
  # https://app.asana.com/0/456927885748233/757611127540101
  d$data %>%
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
      # NOTE: the 30 or so that aren't explicitly tagged appear to be vehicular
      type = if_else_na(
        CFS_Code == "PEDESTRIAN STOP",
        "pedestrian",
        "vehicular"
      ),
      datetime = parse_datetime(`Incident Datetime`),
      date = as.Date(datetime),
      time = format(datetime, "%H:%M:%S"),
      subject_sex = tr_sex[SubjectGender],
      subject_race = tr_race[if_else_na(
        Ethnicity == "Hispanic or Latino",
        "hispanic",
        tolower(Race)
      )],
      subject_dob = parse_date(DateofBirth),
      subject_age = age_at_date(subject_dob, date),
      disposition = tolower(Disposition),
      warning_issued = str_detect(disposition, "warning"),
      # TODO(phoebe): can we get citations? looks like we only have warnings
      # and arrests and "FIELD CONTACT CARD", which means?
      # https://app.asana.com/0/456927885748233/757611127540102
      arrest_made = str_detect(disposition, "arrest"),
      outcome = first_of(
        arrest = arrest_made,
        warning = warning_issued
      )
    ) %>%
    helpers$add_lat_lng(
    ) %>%
    standardize(d$metadata)
}
