source("common.R")

load_raw <- function(raw_data_dir, geocodes_path) {
  data <- tibble()
	loading_problems <- list()

  stops_fname = 'orr_20171017191427.csv'
  stops <- read_csv(file.path(raw_data_dir, stops_fname))
  loading_problems[[stops_fname]] <- problems(stops)

  officer_fname = 'orr_-_okcpd_roster_2007-2017_sheet_1.csv'
  officer <- read_csv(file.path(raw_data_dir, officer_fname))
  loading_problems[[officer_fname]] <- problems(stops)

  officer[["ID #"]] <- str_pad(officer[["ID #"]], 4, pad = "0")
  data <- left_join(
    stops,
    officer,
    by = c("ofc_badge_no" = "ID #")
  )
  # TODO(danj)
  # ) %>%
  # add_lat_lng("violLocation", geocodes_path)

	list(data = data, metadata = list(loading_problems = loading_problems))
}


clean <- function(d) {
  # TODO(ravi): check this race mapping
  tr_race_subject = c(
    A = "asian/pacific islander",
    B = "black",
    I = "other/unknown",
    M = "other/unknown",
    O = "other/unknown",
    S = "other/unknown",
    U = "other/unknown",
    W = "white",
    X = "other/unknown"
  )
  tr_race_officer <- c(
    "AMERICAN INDIAN" = "other/unknown",
    "ASIAN" = "asian/pacific islander",
    "BLACK" = "black",
    "HISPANIC" = "hispanic",
    "PACIFIC ISLANDER" = "asian/pacific islander",
    "WHITE" = "WHITE"
  )
  tr_sex_officer <- c(
    MALE = "male",
    FEMALE = "female"
  )
  tr_active <- c(
    ACTIVE = TRUE,
    INACTIVE = FALSE
  )

  d$data %>%
    select(
      -X1  # index column
    ) %>%
    rename(
      citation_number = Citation_No,
      incident_date = violDate,
      incident_time = violTime,
      incident_location = violLocation,
      violation_offense = viol_offense,
      violation_description = OffenseDesc,
      violation_posted_speed = viol_post_spd,
      violation_actual_speed = viol_actl_spd,
      # TODO(journalist): what are these codes?
      citation_original_release = cit_original_release,
      # TODO(ravi): what does orel_Desc mean?
      # categories are CHARGED OUT OF CUSTODY, FIELD RELEASE, JAILED, JUVENILE
      # CENTER RELEASE, and HOSPITAL RELEASE
      orel_description = orel_Desc,
      subject_race = DfndRace,
      subject_sex = DfndSex,
      subject_dob = DfndDOB,
      officer_badge_number = ofc_badge_no,
      officer_agency = ofc_agy,
      officer_name = Officer,
      vehicle_year = veh_year,
      vehicle_color_1 = veh_color_1,
      vehicle_color_2 = veh_color_2,
      vehicle_make = veh_make,
      vehicle_model = veh_model,
      vehicle_style = veh_style,
      vehicle_registration_state = veh_tag_st,
      vehicle_registration_year = veh_tag_yr,
      officer_hire_date = `HIRE DATE`,
      officer_is_active = ACTIVE,
      officer_dob = DOB,
      officer_race = RACE,
      officer_sex = GENDER,
      officer_termination_date = `TERM DATE`
    ) %>%
    mutate(
      incident_id = citation_number,
      incident_type = "vehicular",  # TODO
      incident_date = parse_date(incident_date, "%Y%m%d"),
      incident_time = parse_time(str_pad(incident_time, 4, pad = "0"), "%H%M"),
      accident_occurred = yn_to_tf[Accident],
      subject_race = tr_race_subject[subject_race],
      subject_sex = tr_sex[subject_sex],
      subject_dob = parse_date(subject_dob, "%Y%m%d"),
      officer_is_active = tr_active[officer_is_active],
      officer_dob = parse_date(officer_dob),
      officer_race = tr_race_officer[officer_race],
      reason_for_stop = violation_offense,
      officer_termination_date = parse_date(officer_termination_date),
      citation_issued = TRUE  # these are all citations
    ) %>%
    standardize(d$metadata)
}
