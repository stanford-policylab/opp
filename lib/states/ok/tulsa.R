source("common.R")


# VALIDATION: [YELLOW] Tulsa's 2016 Annual Report doesn't list traffic
# statistics, but does list calls for service and arrests; these figures seem
# to be on the right order of magnitude relative to the number of calls for
# service.
load_raw <- function(raw_data_dir, n_max) {
  d <- load_years(raw_data_dir, n_max = n_max)
  bundle_raw(d$data, d$loading_problems)
}


clean <- function(d, helpers) {

  tr_race <- c(
    tr_race,
    "C" = "other",
    "D" = "other",
    "E" = "other",
    "F" = "other",
    "G" = "other",
    "K" = "other",
    "L" = "other",
    "M" = "other",
    "N" = "other",
    "P" = "other",
    "R" = "other",
    "S" = "other",
    "T" = "other",
    "V" = "other",
    "Y" = "other"
  )
  # TODO(phoebe): can we get outcome (warning, citation, arrest)?
  # https://app.asana.com/0/456927885748233/642528085814343
  # TODO(phoebe): can we get search/contraband fields?
  # https://app.asana.com/0/456927885748233/642528085814345
  # TODO(phoebe): what is CHARGEPARA and CHARGESECTION? Can we get a data
  # dictionary?
  # https://app.asana.com/0/456927885748233/642528085814346
	# TODO(phoebe): can we get beat/precinct or shapefiles for those?
	# https://app.asana.com/0/456927885748233/642528085814347
  colnames(d$data) <- tolower(colnames(d$data))
  d$data %>%
  merge_rows(
    violationdate,
    violation_location,
    officerdiv,
    race,
    sex
  ) %>%
  rename(
    violation = charge,
    location = violation_location,
    speed = vehspeed,
    posted_speed = vehspeedlimit,
    vehicle_color = color,
    vehicle_make = make,
    vehicle_model = model,
    vehicle_registration_state = tagstate,
    raw_race = race,
    division = officerdiv
  ) %>%
  mutate(
    datetime = coalesce(
      parse_datetime(violationdate, "%Y/%m/%d %H:%M:%S"),
      parse_datetime(violationdate, "%Y/%m/%d")
    ),
    date = as.Date(datetime),
    time = format(datetime, "%H:%M:%S"),
    subject_race = tr_race[raw_race],
    subject_sex = tr_sex[sex],
    vehicle_year = format_two_digit_year(year)
  ) %>%
  helpers$add_lat_lng(
  ) %>%
  helpers$add_type(
    "violation"
  ) %>%
  standardize(d$metadata)
}
