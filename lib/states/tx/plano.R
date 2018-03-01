source("common.R")

load_raw <- function(raw_data_dir, n_max) {
  data <- tibble()
	loading_problems <- list()
  # TODO(phoebe): what are the B/R prefixes?
  # https://app.asana.com/0/456927885748233/574633988593752
  colnames_map <- list(
    "2012" = c(
      "origin",
      "incident_type",
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
  for (year in 2012:2015) {
    # TODO(phoebe): how can we join these in? incident # is populated ~15%
    # https://app.asana.com/0/456927885748233/574633988593748
    # stops_fname <- str_c("all_traffic_stops_", year, "_sheet_1.csv")
    # stops <- read_csv(file.path(raw_data_dir, stops_fname))
		# loading_problems[[stops_fname]] <- problems(stops)
    profiles_fname <- str_c("racial_profiling_data_", year, "_sheet_1.csv")
    profiles <- read_csv(
      file.path(raw_data_dir, profiles_fname),
      col_names = colnames_map[[as.character(year)]],
      col_types = cols(.default = "c"),
      skip = 1
    )
    data <- bind_rows(data, profiles)
    loading_problems[[profiles_fname]] <- problems(profiles)
    if (nrow(data) > n_max) {
      data <- data[1:n_max, ]
      break
    }
  }
  bundle_raw(data, loading_problems)
}



clean <- function(d, calculated_features_path) {

  tr_race <- c(
    A = "asian/pacific islander",
    B = "black",
    HIS = "other/unknown",
    I = "other/unknown",
    MDE = "other/unknown",
    P = "other/unknown",
    U = "other/unknown",
    W = "white"
  )

  # NOTE: 'yes' has more variation in expression, so match on 'no's
  regex_no = regex("N|NO", ignore.case = TRUE)
  is_true <- function(col) { !str_detect(col, regex_no) }

  d$data %>%
    rename(
      # NOTE: offense seems to be the closest thing to reason for stop
      # violation_description is 73.81% null
      # primary_violation is 99.35% null
      # type is 98.16% null
      # offense is 49.69% null
      reason_for_stop = offense,
      notes = notes,
      vehicle_make = make,
      vehicle_model = model,
      vehicle_color = color,
      beat = occur_beat
      # TODO(phoebe): is sector precinct?
      # https://app.asana.com/0/456927885748233/578330939300966
    ) %>%
    mutate(
      incident_type = ifelse(is_true(mv_stop), "vehicular", "pedestrian"),
      incident_date = coalesce(
        parse_date(date, "%Y/%m/%d"),
        parse_date(date, "%m/%d/%Y"),
        as.Date(parse_datetime(date, "%Y/%m/%d %H:%M:%S"))
      ),
      incident_time = coalesce(
        parse_time(time, "%H:%M"),
        parse_time(time, "%H:%M:%S"),
        parse_time(
          format(
            parse_datetime(time, "%Y/%m/%d %H:%M:%S"),
            "%H:%M:%S"
          )
        ),
        parse_time_int(time)
      ),
      # TODO(danj): get geolocation data
      # NOTE: each column indpendently is at least 75% null
      incident_location = coalesce(
        location,
        violation_location,
        offense_location,
        arrest_location
      ),
      warning_issued = is_true(warning),
      citation_issued = coalesce(
        !is.na(citation_number),
        is_true(citation)
      ),
      arrest_made = is_true(
        coalesce(
          arrest,
          arrested
        )
      ),
      incident_outcome = first_of(
        arrest = arrest_made,
        citation = citation_issued,
        warning = warning_issued
      ),
      subject_race = tr_race[race],
      subject_sex = tr_sex[sex],
      subject_age = age,
      search_conducted = is_true(
        coalesce(
          search_conducted,
          search_performed,
          searched
        )
      ),
      search_consent = is_true(
        coalesce(
          search_consent,
          search_consent_2,
          consent
        )
      ),
      # NOTE: curiously, every search was search constent in this dataset
      search_type = first_of(
        "consent" = is_true(search_consent),
        "probable cause" = search_conducted  # default
      ),
      contraband_found = is_true(
        coalesce(
          contraband,
          contraband_found
        )
      )
    ) %>%
    standardize(d$metadata)
}
