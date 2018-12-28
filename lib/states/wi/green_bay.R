source("common.R")


# VALIDATION: [RED] It looks like the PD gave us only a sample.
load_raw <- function(raw_data_dir, n_max) {
  d <- load_single_file(raw_data_dir, "green_bay.csv", n_max)
  bundle_raw(d$data, d$loading_problems)
}


clean <- function(d, helpers) {
  tr_race <- c(
    "BLACK" = "black",
    "HISPANIC" = "hispanic",
    "INDIAN" = "other/unknown",
    "WHITE" = "white"
  )
  # TODO(phoebe): can we get more than 43 records?
  # https://app.asana.com/0/456927885748233/595493946182546
  # TODO(phoebe): can we get reason_for_stop/search/contraband fields?
  # https://app.asana.com/0/456927885748233/595493946182551
  d$data %>%
    rename(
      location = Address,
      arrest_made = Arrest_Jail,
      # TODO(phoebe): how do Charge_Ordinance, Charge_Misdemeanor, and
      # Charge_Felony map to warning, citation, arrest?
      # https://app.asana.com/0/456927885748233/595493946182552
      citation_issued = Charge_Ordinance
    ) %>%
    mutate(
      # TODO(phoebe): looks like these are all only pedestrian stops?
      # https://app.asana.com/0/456927885748233/595493946182546
      type = "pedestrian",
      datetime = parse_datetime(Reported_Date, "%m/%d/%y %H:%M:%S"),
      date = as.Date(datetime),
      time = format(datetime, "%H:%M:%S"),
      subject_race = tr_race[Race],
      subject_sex = tr_sex[Sex],
      subject_dob = parse_datetime(DOB, "%m/%d/%y %H:%M:%S"),
      subject_age = age_at_date(subject_dob, date)
    ) %>%
    helpers$add_lat_lng(
    ) %>%
    helpers$add_shapefiles_data(
    ) %>%
    rename(
      district = DISTRICT,
      sector = Sector
    ) %>%
    standardize(d$metadata)
}
