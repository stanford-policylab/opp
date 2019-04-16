source("common.R")

load_raw <- function(raw_data_dir, n_max) {
  d <- load_single_file(
    raw_data_dir,
    "Vehicle_and_Pedestrian_Stop_Data_2010_to_Present.csv",
    n_max = n_max
  )
  d$data <- make_ergonomic_colnames(d$data)
  bundle_raw(d$data, d$loading_problems)
}


clean <- function(d, helpers) {

  tr_race <- c(
    "AMERICAN INDIAN" = "other",
    "ASIAN" = "asian/pacific islander",
    "BLACK" = "black",
    "HISPANIC" = "hispanic",
    "OTHER" = "other",
    "WHITE" = "white"
  )
  # TODO(phoebe): can we get reason_for_stop/search/contraband fields?
  # https://app.asana.com/0/456927885748233/1115427454091539
  # TODO(phoebe): what does post_stop_activity_indicator mean?
  # https://app.asana.com/0/456927885748233/1115427454091540
  # TODO(phoebe): can we get outcome data?
  # https://app.asana.com/0/456927885748233/1115427454091541 
  # TODO(phoebe): can we get location data?
  # https://app.asana.com/0/456927885748233/1115427454091542 
  d$data %>%
    merge_rows(
      stop_date,
      stop_time,
      reporting_district,
      division_description_1,
      division_description_2,
      officer_1_serial_number,
      officer_2_serial_number,
      descent_description,
      sex_code,
      stop_type
    ) %>%
    rename(
      # NOTE: there is a second officer, which is null 29% of the time and not
      # added here, but is available in the raw data
      officer_id = officer_1_serial_number,
      district = reporting_district,
      region = division_description_1
    ) %>%
    mutate(
      # NOTE: there are only vehicular and pedestrian stops
      type = if_else(stop_type == "VEH", "vehicular", "pedestrian"),
      date = parse_date(stop_date, "%m/%d/%Y"),
      time = parse_time(stop_time),
      subject_sex = tr_sex[sex_code],
      subject_race = tr_race[descent_description]
    ) %>%
    rename(
      raw_descent_description = descent_description
    ) %>%
    standardize(d$metadata)
}
