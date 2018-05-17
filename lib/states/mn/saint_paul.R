source("common.R")

load_raw <- function(raw_data_dir, n_max) {
	loading_problems <- list()
  fname <- "SaintPaul_Traffic_Stop_Dataset.csv" 
  data <- read_csv(file.path(raw_data_dir, fname), n_max = n_max)
  loading_problems[[fname]] <- problems(data)
  bundle_raw(data, loading_problems)
}


clean <- function(d, helpers) {
  tr_race <- c(
    "Asian" = "asian/pacific islander",
    "Black" = "black",
    "Hispanic" = "hispanic",
    "Native American" = "other/unknown",
    "White" = "white",
    "No Data" = NA
  )
  tr_sex <- c(
    "Female" = "female",
    "Male" = "male",
    "No Data" = NA
  )
  yn_to_tf <- c(
    "No" = FALSE,
    "Yes" = TRUE,
    "No Data" = NA
  )

  d$data %>%
    rename(
      # TODO(phoebe): does POLICE GRID NUMBER mean precinct?
      # https://app.asana.com/0/456927885748233/573247093484091
      precinct = `POLICE GRID NUMBER`,
      subject_age = `AGE OF DRIVER`
    ) %>%
    extract_and_add_lat_lng(
      "LOCATION OF STOP BY POLICE GRID"
    ) %>%
    mutate(
      # NOTE: all stops are vehicular
      dt = parse_datetime(`DATE OF STOP`, "%m/%d/%Y %I:%M:%S %p"),
      incident_date = as.Date(dt),
      incident_time = format(dt, "%H:%M:%S"),
      incident_type = "vehicular",
      citation_issued = yn_to_tf[`CITATION ISSUED?`],
      frisk_performed = yn_to_tf[`DRIVER FRISKED?`],
      search_vehicle = yn_to_tf[`VEHICLE SEARCHED?`],
      search_conducted = frisk_performed | search_vehicle,
      # TODO(phoebe): can we get other outcomes?
      # https://app.asana.com/0/456927885748233/573247093484092
      incident_outcome = first_of(
        citation = citation_issued
      ),
      # TODO(phoebe): can we get contraband?
      # https://app.asana.com/0/456927885748233/573247093484095
      # TODO(phoebe): can we get location?
      # https://app.asana.com/0/456927885748233/573247093484094
      # TODO(phoebe): can we get reason for stop?
      # https://app.asana.com/0/456927885748233/573247093484093
      subject_race = tr_race[`RACE OF DRIVER`],
      subject_sex = tr_sex[`GENDER OF DRIVER`]
    ) %>%
    standardize(d$metadata)
}
