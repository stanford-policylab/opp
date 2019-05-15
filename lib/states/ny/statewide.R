source(here::here("lib", "common.R"))

load_raw <- function(raw_data_dir, n_max) {
  d <- load_years(raw_data_dir, n_max)
  bundle_raw(d$data, d$loading_problems)
}


clean <- function(d, helpers) {
  tr_race <- c(
    "1 - BLACK" = "black",
    "2 - WHITE" = "white",
    "3 - HISPANIC" = "hispanic",
    "4 - ASIAN - EAST INDIAN" = "asian/pacific islander",
    "5 - NATIVE AMERICAN" = "other/unknown",
    "6 - OTHER" = "other/unknown"
  )
  
  # NOTE: we could maybe assume "1" is male and "2" is female also, but for
  # now those are cast to NA since we weren't given a metadata file
  tr_sex <- c(
    "M" = "male",
    "F" = "female"
  )
  
  d$data %>%
    add_raw_colname_prefix(
      RACE
    ) %>% 
    mutate(
      date = parse_date(str_sub(VIOLATION_DATE, 1, 8), format = "%m/%d/%y"),
      time = parse_time(str_sub(VIO_TIME, 10, 17), format = "%H:%M:%S"),
      subject_age = as.integer(AGE),
      subject_race = tr_race[raw_RACE],
      subject_sex = tr_sex[GENDER],
      county_name = str_c(str_to_title(COUNTY), " County"),
      location = str_c(VIO_STREET, HWY_NUM, HWY_TYPE, sep = "|"),
      vehicle_color = str_to_lower(VEH_COLOR),
      vehicle_make = str_to_lower(MAKE),
      vehicle_model = str_to_lower(MODEL),
      vehicle_type = str_to_lower(VEH_TYPE),
      vehicle_registration_state = REG_STATE,
      vehicle_year = YEAR, 
      violation = LAW_DESCRIPTION,
      speed = as.integer(SPEED), 
      posted_speed = as.integer(POSTED_SPEED),
      type = "vehicular"
    ) %>% 
    standardize(d$metadata)
}