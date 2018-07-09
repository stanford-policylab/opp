source("common.R")

load_raw <- function(raw_data_dir, n_max) {
  d <- load_single_file(
    raw_data_dir,
    "SaintPaul_Traffic_Stop_Dataset.csv",
    n_max = n_max
  )
  bundle_raw(d$data, d$loading_problems)
}


clean <- function(d, helpers) {

  tr_race <- c(
    "Asian" = "asian/pacific islander",
    "Black" = "black",
    "Hispanic" = "hispanic",
    "Native American" = "other/unknown",
    "White" = "white"
  )

  d$data %>%
    rename(
      police_grid_number = `POLICE GRID NUMBER`,
      subject_age = `AGE OF DRIVER`
    ) %>%
    extract_and_add_decimal_lat_lng(
      "LOCATION OF STOP BY POLICE GRID"
    ) %>%
    mutate(
      datetime = parse_datetime(`DATE OF STOP`, "%m/%d/%Y %I:%M:%S %p"),
      date = as.Date(datetime),
      time = format(datetime, "%H:%M:%S"),
      # NOTE: all stops either involved driver or vehicle, so vehicular
      type = "vehicular",
      citation_issued = tr_yn[`CITATION ISSUED?`],
      frisk_performed = tr_yn[`DRIVER FRISKED?`],
      search_vehicle = tr_yn[`VEHICLE SEARCHED?`],
      search_conducted = frisk_performed | search_vehicle,
      # TODO(phoebe): can we get other outcomes?
      # https://app.asana.com/0/456927885748233/573247093484092
      outcome = first_of(
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
