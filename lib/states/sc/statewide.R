source("common.R")


load_raw <- function(raw_data_dir, n_max) {
  d <- load_all_csvs(raw_data_dir, n_max = n_max)
  bundle_raw(d$data, d$loading_problems)
}


clean <- function(d, helpers) {
  # NOTE: Replacing "NULL" with NA everywhere.
  d$data[d$data == "NULL"] <- NA
  
  tr_race = c(
    "White" = "white",
    "Black" = "black",
    "Hispanic" = "hispanic",
    "Amerindian" = "other/unknown",
    "Asian" = "asian/pacific islander",
    "Multi-Race" = "other/unknown",
    "Other" = "other/unknown",
    "Unknown" = "other/unknown"
  )

  d$data %>%
    rename(
      county_name = County,
      subject_age = `Defendent Age`,
      officer_id = `Officer Badge Number`,
      officer_age = `Officer Age`,
      officer_last_name = `Officer Name`,
      department_id = PoliceDivision,
      reason_for_stop = ContactReason
    ) %>%
    mutate(
      date = parse_date(DateIssued, "%m/%d/%Y"),
      location = str_c_na(HighwayType, HighwayNum, sep = " "),
      lat = parse_number(LatitudeDec),
      lat = if_else(lat == 0, NA_real_, lat),
      lng = parse_number(LongitudeDec),
      lng = if_else(lng == 0, NA_real_, lng),
      subject_race = fast_tr(Race, tr_race),
      subject_sex = fast_tr(Sex, tr_sex),
      officer_race = fast_tr(`Officer Race`, tr_race),
      # NOTE: Data received in Aug 2016 was vehicular stops.
      type = "vehicular",
      violation = str_c_na(SectionNum, OffenseCode, sep = " "),
      arrest_made = FelonyArrest == "1" | Jailed == "1",
      citation_issued = `Contact Type` == "Citation",
      # NOTE: The other main value of "Contact Type" is "Public Contact". It is
      # unclear whether a warning is issued in the case of "Public Contact".
      outcome = first_of(
        "arrest" = arrest_made,
        "citation" = citation_issued
      ),
      contraband_drugs = ContrabandDrugs == "1"
        | ContrabandDrugParaphenalia == "1",
      contraband_weapons = ContrabandWeapons == "1",
      contraband_found = contraband_drugs | contraband_weapons,
      search_person = SubjectSearched == "1" | PassengerSearched == "1",
      search_vehicle = VehicleSearched == "1",
      search_conducted = Searched == "1" | search_person | search_vehicle
    ) %>%
    standardize(d$metadata)
}
