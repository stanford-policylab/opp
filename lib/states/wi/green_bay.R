source("common.R")

load_raw <- function(raw_data_dir, n_max) {
  fname <- "green_bay.csv"
  data <- read_csv(file.path(raw_data_dir, fname), n_max = n_max)
  loading_problems <- list()
  loading_problems[[fname]] <- problems(data)
  bundle_raw(data, loading_problems)
}


clean <- function(d, helpers) {
  tr_race <- c(
    "BLACK" = "black",
    "HISPANIC" = "hispanic",
    "INDIAN" = "other/unknown",
    "WHITE" = "white"
  )
  tr_sex <- c(
    "MALE" = "male",
    "FEMALE" = "female"
  )
  # TODO(phoebe): can we get more than 43 records?
  # https://app.asana.com/0/456927885748233/595493946182546
  # TODO(phoebe): can we get reason_for_stop/search/contraband fields?
  # https://app.asana.com/0/456927885748233/595493946182551
  d$data %>%
    rename(
      incident_location = Address,
      arrest_made = Arrest_Jail,
      # TODO(phoebe): how do Charge_Ordinance, Charge_Misdemeanor, and
      # Charge_Felony map to warning, citation, arrest?
      # https://app.asana.com/0/456927885748233/595493946182552
      citation_issued = Charge_Ordinance
    ) %>%
    mutate(
      # TODO(phoebe): looks like these are all only pedestrian stops?
      # https://app.asana.com/0/456927885748233/595493946182546
      incident_type = "pedestrian",
      incident_datetime = parse_datetime(Reported_Date, "%m/%d/%y %H:%M:%S"),
      incident_date = as.Date(incident_datetime),
      incident_time = format(incident_datetime, "%H:%M:%S"),
      subject_race = tr_race[Race],
      subject_sex = tr_sex[Sex],
      subject_dob = parse_datetime(DOB, "%m/%d/%y %H:%M:%S")
    ) %>%
    helpers$add_lat_lng(
    ) %>%
    standardize(d$metadata)
}
