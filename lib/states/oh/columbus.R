source("lib/schema.R")
source("lib/utils.R")


city <- "columbus"
state <- "oh"
path_prefix <- str_c("data/states/", state, "/", city, "/")


opp_load_raw <- function() {
  raw_csv_path_prefix = str_c(path_prefix, "/raw_csv/")
  d <- read_csv(str_c(raw_csv_path_prefix,
                      "pra_16-1288_vehiclestop2014-2015_sheet_1.csv"),
                na = c("", "NA", "NULL"),
    col_names = c(
      "vehicle_stop_id",
      "stop_date",
      "stop_time",
      "stop_cause",
      "race",
      "sex",
      "age",
      "arrested",
      "searched",
      "obtained_consent",
      "contraband_found",
      "property_seized",
      "san_diego_resident",
      "service_area",
      "agency"
    ),
    col_types = cols(
      vehicle_stop_id       = col_character(),
      stop_date             = col_date(),
      stop_time             = col_time(),
      stop_cause            = col_character(),
      race                  = col_character(),
      sex                   = col_character(),
      age                   = col_integer(),
      arrested              = col_character(),
      searched              = col_character(),
      obtained_consent      = col_character(),
      contraband_found      = col_character(),
      property_seized       = col_character(),
      san_diego_resident    = col_character(),
      service_area          = col_character(),
      agency                = col_character()
    ),
    skip = 1
  )


}

opp_clean <- function(tbl) {
  # TODO(danj): check this map
  tr_race = c(
    "A" = "asian/pacific islander",
    "B" = "black",
    "C" = "other/unknown",
    "D" = "other/unknown",
    "F" = "other/unknown",
    "G" = "other/unknown",
    "H" = "hispanic",
    "I" = "other/unknown",
    "J" = "other/unknown",
    "K" = "other/unknown",
    "L" = "other/unknown",
    "O" = "other/unknown",
    "P" = "other/unknown",
    "S" = "other/unknown",
    "U" = "other/unknown",
    "V" = "other/unknown",
    "W" = "white",
    "X" = "other/unknown",
    "Z" = "other/unknown"
  )
  tr_sex = c(
    F = "female",
    M = "male"
  )
  yn_to_tf = c(
    "Y" = TRUE,
    "F" = FALSE
  )

  tbl %>%
    rename(
      incident_id = vehicle_stop_id,
      incident_date = stop_date,
      incident_time = stop_time,
      reason_for_stop = stop_cause,
      defendant_race = race,
      defendant_sex = sex,
      defendant_age = age,
      search_conducted = searched,
      search_consent = obtained_consent,
      arrest_made = arrested
    ) %>%
    mutate(
      incident_type = factor("vehicular", levels = valid_incident_types),
      incident_location = as.character(NA),
      incident_lat = as.numeric(NA),
      incident_lng = as.numeric(NA),
      defendant_race = factor(tr_race[defendant_race], levels = valid_races),
      defendant_sex = factor(tr_sex[defendant_sex], levels = valid_sexes),
      search_conducted = yn_to_tf[search_conducted],
      search_consent = yn_to_tf[search_consent],
      contraband_found = yn_to_tf[contraband_found],
      property_seized = yn_to_tf[property_seized],
      san_diego_resident = yn_to_tf[san_diego_resident],
      arrest_made = yn_to_tf[arrest_made],
      # NOTE(danj): leaving as NA since we don't have any signal here
      citation_issued = as.logical(NA)
    ) %>%
    replace_na(list(
      defendant_race = "other/unknown",
      search_conducted = FALSE,
      search_consent = FALSE,
      contraband_found = FALSE,
      property_seized = FALSE,
      san_diego_resident = FALSE,
      arrest_made = FALSE
    )) %>%
    mutate(
      # NOTE: mutate this after filling in logical values
      search_type = factor(
        ifelse(
          search_consent,
          "consent",
          ifelse(
            search_conducted,
            "probable cause",
             NA
          )
        ),
        levels = valid_search_types
      )
    ) %>%
    select(
      incident_id,
      incident_type,
      incident_date,
      incident_time,
      incident_location,
      incident_lat,
      incident_lng,
      defendant_race,
      reason_for_stop,
      search_conducted,
      search_type,
      contraband_found,
      arrest_made,
      citation_issued,
      everything()
    )
}


opp_save <- function(tbl) {
  save_clean_csv(tbl, path_prefix, city)
}


opp_load <- function() {
  load_clean_csv(path_prefix, city)
}
