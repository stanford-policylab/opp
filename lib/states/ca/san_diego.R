source("common.R")

load_raw <- function(raw_data_dir, n_max) {
  d <- load_single_file(
    raw_data_dir,
    "pra_16-1288_vehiclestop2014-2015_sheet_1.csv",
    n_max
  )
  bundle_raw(d$data, d$loading_problems)
}


clean <- function(d, helpers) {
  # TODO(ravi): check this map
  # https://app.asana.com/0/456927885748233/519045240013538
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

  tr_stop_cause = c(
    "MUNI, County, H&S Code" = "MUNI, County, H&S Code",
    "Muni, County, H&S Code" = "MUNI, County, H&S Code",
    "Suspect Info (I.S., Bulletin, Log)" = "Suspect Info",
    "UNI, &County, H&&S Code" = "MUNI, County, H&S Code",
    "&Equipment Violation" = "Equipment Violation",
    "&Moving Violation" = "Moving Violation",
    "&Radio Call/Citizen Contact" = "Radio Call/Citizen Contact",
    "CAUSE NOT LISTED ACTION NOT LISTED" = "None",
    "Equipment Violation" = "Equipment Violation",
    "Moving Violation" = "Moving Violation",
    "NA" = "None",
    "NOT MARKED" = "None",
    "NOTHING MARKED" = "None",
    "NULL" = "None",
    "No Cause Specified on a Card" = "None",
    "Other" = "None",
    "Pedestrian" = "Pedestrian",
    "Personal Knowledge/Informant" = "Personal Knowledge/Informant",
    "Personal Observ/Knowledge" = "Personal Observation/Informant",
    "Radio Call/Citizen Contact" = "Radio Call/Citizen Contact",
    "Suspect Info" = "Suspect Info",
    "none listed" = "None",
    "none noted" = "None",
    "not listed" = "None",
    "not marked  not marked" = "None",
    "not marked" = "None",
    "not noted" = "None",
    "not secified" = "None"
  )

  # TODO(phoebe): can we get location?
  # https://app.asana.com/0/456927885748233/569484839430728
  d$data %>%
    rename(
      date = StopDate,
      time = StopTime,
      subject_age = age,
      search_conducted = Searched,
      search_consent = ObtainedConsent,
      contraband_found = ContrabandFound,
      arrest_made = Arrested,
      service_area = ServArea,
      department_name = Agency
    ) %>%
    apply_translator_to(
      tr_yn,
      "search_conducted",
      "search_consent",
      "contraband_found",
      "arrest_made"
    ) %>%
    mutate(
      type = "vehicular",
      outcome = ifelse(arrest_made, "arrest", NA),
      subject_race = tr_race[Race],
      subject_sex = tr_sex[Sex],
      search_type = first_of(
        "consent" = search_consent,
        "probable cause" = search_conducted 
      ),
      reason_for_stop = tr_stop_cause[StopCause]
    ) %>%
    # TODO(danj): add shapefile data once we get location
    # https://app.asana.com/0/456927885748233/681325483960257
    standardize(d$metadata)
}
