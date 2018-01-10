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

  data <- left_join(stops, officer, by = c("ofc_badge_no" = "ID #"))

  # TODO(danj): add geocoding
  # data <- add_lat_lng(data, "address", geocodes_path)
	list(data = data, metadata = list(loading_problems = loading_problems))
}


clean <- function(d) {
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
      violation_post_speed = viol_post_spd,
      violation_actual_speed = viol_actl_speed,
      citation_original_release = cit_original_release,
      # TODO(danj): wat is this
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
      officer_hire_date = "HIRE DATE",
      officer_is_active = ACTIVE,
      officer_dob = DOB,
      officer_race = RACE,
      officer_gender = GENDER,
      officer_termination_date = "TERM DATE"
    ) %>%
    mutate(
      accident_occurred = yn_to_tf[Accident],
    )
    # ) %>%
    # standardize(d$metadata)
}
