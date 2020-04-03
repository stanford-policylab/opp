source("common.R")


# VALIDATION: [YELLOW] The Seattle PD doesn't appear to put out Annual Reports
# or statistics on all traffic stops, but the numbers seem reasonable given the
# population. Unfortunately, a lot of relevant demographic data appears to be
# missing.

# NOTE: The Seattle PD has a smaller dataset focused only on Terry stops here:
# https://www.seattle.gov/police/information-and-data/terry-stops
load_raw <- function(raw_data_dir, n_max) {
  d <- load_years(raw_data_dir, n_max)
  colnames(d$data) <- make_ergonomic(colnames(d$data))
  types <- load_single_file(raw_data_dir, "types.csv")
  tr_type <- translator_from_tbl(types$data, "type_code", "translation")
  mutate(
    d$data,
    type_description = tr_type[type]
  ) %>%
  bundle_raw(c(d$loading_problems, types$loading_problems))
}


clean <- function(d, helpers) {

  vehicle <- helpers$load_json("vehicle.json")
  ped_pattern <- paste(c(
    "DISTURBANCE",
    "FOOT",
    "HARAS",
    "MISCHIEF",
    "NARCOTIC",
    "NOISE",
    "PROPERTY",
    "PROSTITUT",
    "SEX",
    "SHOTS",
    "WELFARE"
  ), collapse = "|")

  # NOTE: pri in original dataset means 'priority'
  d$data %>%
  # NOTE: when rin is null, almost every column is null, so filter out
  filter(
    !is.na(rin)
  ) %>%
  helpers$add_lat_lng(
    "address"
  ) %>%
  helpers$add_shapefiles_data(
  ) %>%
  rename(
    location = address,
    violation = mir_description,
    precinct = first_prec,
    disposition = disposition_description
  ) %>%
  separate_cols(
    poss_race_sex = c("subject_race", "subject_sex"),
    sep = 1
  ) %>%
  separate_cols(
    date_time = c("date", "time"),
    officer_no_1 = c("officer_id", "officer_name"),
    officer_name = c("officer_last_name", "officer_first_name"),
    sep = " "
  ) %>%
  mutate(
    type = if_else(
      str_detect(violation, "PEDESTRIAN")
      | (str_detect(violation, "PURSUIT")
         & !is.na(type_description)
         & str_detect(type_description, ped_pattern))
      | (str_detect(violation, "MISCELLANEOUS")
         & !is.na(type_description)
         & str_detect(type_description, ped_pattern)),
      "pedestrian",
      "vehicular"
    ),
    date = parse_date(date, "%Y/%m/%d"),
    officer_last_name = str_replace_all(officer_last_name, ",", ""),
    officer_first_name = str_replace_all(officer_first_name, ",", ""),
    officer_first_name = str_trim(officer_first_name),
    # officer_no is not unique, so combine with last name to get hash
    officer_id_hash = simple_map(
        str_c(officer_id, officer_last_name),
        simple_hash
    ),
    subject_race = tr_race[subject_race],
    subject_sex = tr_sex[subject_sex],
    subject_dob = parse_date(subj_dob, "%Y%m%d"),
    arrest_made = str_sub(disposition, 1, 1) == "A",
    # NOTE: includes criminal and non-criminal citations
    citation_issued = str_detect(disposition, "CITATION"),
    warning_issued = str_detect(disposition, "WARN"),
    outcome = first_of(
      arrest = arrest_made,
      citation = citation_issued,
      warning = warning_issued
    ),
    v = coalesce(veh, vehcile),
    vehicle_color = str_extract(v, str_c(vehicle$colors, collapse = "|")),
    vehicle_make = str_extract(v, str_c(vehicle$makes, collapse = "|")),
    vehicle_model = str_extract(v, str_c(vehicle$models, collapse = "|")),
    vehicle_year = str_extract(v, "\\d{4}"),
    vehicle_registration_state =
      str_extract(v, str_c(valid_states, collapse = "|"))
  ) %>%
  rename(
    raw_type_description = type_description,
    raw_vehicle_description = v
  ) %>%
  standardize(d$metadata)
}
