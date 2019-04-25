source("common.R")


# VALIDATION: [RED] These data sources are extremely disparate and the annual
# report from 2017 reports that there were ~85k and ~89k traffic stops in 2016
# and 2017, respectively (the two years after this data ends). This would
# represent a huge increase from 62k and 59k for 2014 and 2015 in this data.
# TODO(phoebe): can we get updated data, i.e. 2016-2018? Also, if the Annual
# Report is correct, stops went up by more than 30% from 2015 to 2016/7 -- why
# is this?
# https://app.asana.com/0/456927885748233/955159586009897
load_raw <- function(raw_data_dir, n_max) {
  # TODO(phoebe): what are the B/R prefixes?
  # https://app.asana.com/0/456927885748233/574633988593752
  colnames_map <- list(
    "2012" = c(
      "origin",
      "type",
      "citation_number",
      "incident_number",
      "date",
      "time",
      "officer",
      "prtcp_type",
      "sex",
      "race",
      "ethnicity",
      "mv_stop",
      "knew_race",
      "video",
      "search_conducted",
      "search_consent",
      "warning",
      "citation",
      "instanter",
      "arrest",
      "res_status",
      "violation_description",
      "violation_section",
      "class_description",
      "class_code",
      "primary_violation"
    ),
    "2013" = c(
      "origin",
      "prtcp_type",
      "type",
      "result",
      "result_2",
      "number",
      "incident_number",
      "date",
      "time",
      "officer",
      "sex",
      "race",
      "ethnicity",
      "mv_stop",
      "knew_race",
      "search_performed",
      "search_consent",
      "stop_video",
      "arrest",
      "citation",
      "warning",
      "offense",
      "offense_code",
      "accident",
      "mv_stop_comment",
      "violator_city",
      "violator_zip_code",
      "resident",
      "location",
      "arrest_city",
      "contraband",
      "type_of_stop",
      "towit",
      "notes"
    ),
    "2014" = c(
      "origin",
      "officer_result",
      "rp_report_result",
      "citation_number",
      "case_number",
      "date",
      "time",
      "offense",
      "arrest",
      "citation",
      "warning",
      "officer",
      "sex",
      "race",
      "ethnicity",
      "rp_report_race",
      "rp_report_ethnicity",
      "accident",
      "mv_stop",
      "knew_race",
      "search_performed",
      "search_consent",
      "search_consent_2",
      "dvr",
      "offense_2",
      "violator_city",
      "violator_state",
      "violator_zip_code",
      "resident",
      "violation_location",
      "violation_county",
      "contraband",
      "type_of_stop"
    ),
    "2015" = c(
      "source",
      "c_number",
      "incident_number",
      "date",
      "time",
      "officer",
      "badge",
      "prtcp_type",
      "offense_1",
      "result_1",
      "offense_2",
      "result_2",
      "offense_3",
      "result_3",
      "offense_4",
      "result_4",
      "offense_5",
      "result_5",
      "offense_6",
      "result_6",
      "offense_7",
      "result_7",
      "offense_8",
      "result_8",
      "dl_state",
      "sex",
      "race",
      "mod_race",
      "ethnicity",
      "accident",
      "mv_stop",
      "mdvr",
      "arrested",
      "searched",
      "consent",
      "knew_race_before",
      "hair",
      "eyes",
      "height",
      "weight",
      "home_city",
      "home_state",
      "home_zip_code",
      "plano_resident",
      "fam_violation",
      "pers_obs",
      "contraband_found",
      "notes",
      "offense_date",
      "officer_2",
      "badge_2",
      "unit",
      "court_date",
      "speed",
      "speed_limit",
      "make",
      "model",
      "color",
      "vehicle_type",
      "commercial_vehicle",
      "cdl",
      "haz",
      "filler",
      "signed",
      "citation_date",
      "citation_time",
      "download_date",
      "type",
      "prtcp_id",
      "prtcp_type_2",
      "warning",
      "citation",
      "offense_location",
      "arrest_location",
      "arrest_city",
      "violation_section",
      "class_code",
      "class_desc",
      "primary_violation",
      "occur_beat",
      "sector",
      "rd",
      "pob",
      "age",
      "juv",
      "fn",
      "ice/iaq",
      "citizen",
      "resident_status"
    )
  )

  data <- tibble()
	loading_problems <- list()
  all_files <- files_with_recent_year_in_name(raw_data_dir)
  racial_profiling_files <- all_files[str_detect(all_files, "racial")]
  for (fname in racial_profiling_files) {
    # TODO(phoebe): how can we join these in? incident # is populated ~15%
    # https://app.asana.com/0/456927885748233/574633988593748
    # stops_fname <- str_c("all_traffic_stops_", year, "_sheet_1.csv")
    # stops <- read_csv(file.path(raw_data_dir, stops_fname))
		# loading_problems[[stops_fname]] <- problems(stops)
    d <- load_single_file(
      raw_data_dir,
      basename(fname),
      col_names = colnames_map[[str_extract(fname, recent_years_regex())]],
      skip = 1
    )
    data <- bind_rows(data, d$data)
    loading_problems <- c(loading_problems, d$loading_problems)
    if (nrow(data) > n_max) {
      data <- data[1:n_max, ]
      break
    }
  }
  bundle_raw(data, loading_problems)
}



clean <- function(d, helpers) {

  tr_race <- c(
    tr_race,
    HIS = "hispanic",
    MDE = "other",
    P = "other"
  )

  # NOTE: 'yes' has more variation in expression, so match on 'no's
  regex_no = regex("N|NO", ignore.case = TRUE)
  is_true <- function(col) { !str_detect(col, regex_no) }

  d$data %>%
  rename(
    vehicle_make = make,
    vehicle_model = model,
    vehicle_color = color,
    beat = occur_beat,
    sector = sector,
    posted_speed = speed_limit,
    raw_race = race,
    raw_contraband = contraband,
    raw_contraband_found = contraband_found
  ) %>%
  # NOTE: officer names are in two formats:
  # (1) <last_name>, <first_initial>
  # (2) <first_initial>. <last_name>
  separate_cols(
    officer = c("officer_first_name_1", "officer_last_name_raw"),
    sep = ", "
  ) %>%
  separate_cols(
    officer_last_name_raw = c("officer_first_name_2", "officer_last_name"),
    sep = ". "
  ) %>%
  mutate(
    # officer_first_name = coalesce(officer_first_name_1, officer_first_name_2),
    officer_id = coalesce(badge, badge_2),
    type = if_else(is_true(mv_stop), "vehicular", "pedestrian"),
    datetime = parse_datetime(date, "%Y/%m/%d %H:%M:%S"),
    date = coalesce(
      parse_date(date, "%Y/%m/%d"),
      parse_date(date, "%m/%d/%Y"),
      as.Date(datetime)
    ),
    time = coalesce(
      parse_time(str_replace(time, "24:00", "00:00"), "%H:%M"),
      parse_time(time, "%H:%M:%S"),
      parse_time(format(datetime, "%H:%M:%S")),
      parse_time_int(time)
    ),
    # TODO(danj): get geolocation data
    # NOTE: each column indpendently is at least 75% null
    location = coalesce(
      location,
      violation_location,
      offense_location,
      arrest_location
    ),
    raw_results = str_c_na(
      officer_result,
      result,
      result_1,
      result_2,
      result_3,
      result_4,
      result_5,
      result_6,
      result_7,
      result_8
    ),
    warning_issued = is_true(warning) | str_detect(raw_results, "WARN"),
    citation_issued = !is.na(citation_number)
      | is_true(citation)
      | str_detect(raw_results, "CIT"),
    arrest_made = is_true(coalesce(arrest, arrested))
      | str_detect(raw_results, "ARR"),
    outcome = first_of(
      arrest = arrest_made,
      citation = citation_issued,
      warning = warning_issued
    ),
    raw_ethnicity = str_to_lower(ethnicity),
    subject_race = tr_race[if_else_na(raw_ethnicity == "his", "HIS", raw_race)],
    subject_sex = tr_sex[sex],
    subject_age = age,
    search_conducted = is_true(coalesce(
      search_conducted,
      search_performed,
      searched
    )),
    search_consent = is_true(coalesce(
      search_consent,
      search_consent_2,
      consent
    )),
    # NOTE: curiously, every search was search constent in this dataset
    search_basis = first_of(
      "consent" = is_true(search_consent),
      "probable cause" = search_conducted  # default
    ),
    contraband_drugs = str_detect_na(raw_contraband, "DRUG|MARI")
      | str_detect_na(raw_contraband_found, "DRUG|MARI"),
    contraband_weapons = str_detect_na(raw_contraband, "WEAPON")
      | str_detect_na(raw_contraband_found, "WEAPON"),
    contraband_found = str_detect_na(raw_contraband, "DRUG|MARI|WEAPON|OTHE")
      | str_detect_na(raw_contraband_found, "DRUG|MARI|WEAPON|OTHE"),
    # NOTE: offense seems to be the closest thing to the violation
    # violation_description is 73.81% null
    # primary_violation is 99.35% null
    # offense is 49.69% null
    # type is 98.16% null
    # NOTE: coalesce rather than join since they seem to be redundant
    violation = str_c_na(
      violation_description,
      primary_violation,
      offense,
      offense_1,
      offense_2,
      offense_3,
      offense_4,
      offense_5,
      offense_6,
      offense_7,
      offense_8
    )
  ) %>%
  helpers$add_lat_lng(
  ) %>%
  helpers$add_shapefiles_data(
  ) %>%
  mutate(
    beat = coalesce(beat, as.character(BEAT)),
    sector = coalesce(sector, as.character(SECTOR))
  ) %>%
  filter(
    # NOTE: there is only one aberrant date from 2016
    date != as.Date("2016-12-26")
  ) %>%
  merge_rows(
    date,
    time,
    location,
    officer_id,
    subject_age,
    subject_race,
    subject_sex
  ) %>%
  standardize(d$metadata)
}
