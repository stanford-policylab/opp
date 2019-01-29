source(here::here("lib", "common.R"))


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
  tr_sex = c(
    "F" = "female",
    "M" = "male"
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
    helpers$add_contraband_type(
      "ContrabandDesc"
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
      # NOTE: Data received in Aug 2016 was mostly vehicular stops.
      type = if_else(reason_for_stop == "Pedestrian", "pedestrian", "vehicular"),
      violation = str_c_na(SectionNum, OffenseCode, sep = " "),
      arrest_made = FelonyArrest == "1" | Jailed == "1",
      citation_issued = `Contact Type` == "Citation",
      # TODO(phoebe): The other main value of "Contact Type" is "Public
      # Contact". It is unclear whether a warning is issued in the case of
      # "Public Contact". This needs to be clarified.
      # https://app.asana.com/0/456927885748233/778596457530887
      outcome = first_of(
        "arrest" = arrest_made,
        "citation" = citation_issued
      ),
      contraband_drugs = contraband_drugs == "1" | ContrabandDrugs == "1"
        | ContrabandDrugParaphenalia == "1",
      contraband_weapons = contraband_weapons == "1" | ContrabandWeapons == "1",
      # NOTE: Including `!is.na(ContrabandDesc)` was discussed at length. This
      # mimics the processing decision of the old analysis, in addition to staying
      # true to the department's definition of contraband. Without that inclusion,
      # contraband recovery is low enough to raise skepticism, and includes many,
      # many zeros, especially for hispanic recovery.
      # TODO(amy): Seems like there are very few instances when ContrabandDesc,
      # which is a free field, indicates either no search was conducted or no
      # contraband was recovered, etc. Does not seem large enough that trends would
      # change, but may be worth in the future doing some work to extract contraband
      # vs no contraband from this ContrabandDesc field.
      contraband_found = contraband_drugs | contraband_weapons 
        | Contraband == "1" | !is.na(ContrabandDesc),
      search_person = SubjectSearched == "1" | PassengerSearched == "1",
      search_vehicle = VehicleSearched == "1",
      search_conducted = Searched == "1" | search_person | search_vehicle,
      # NOTE: mimics old opp
      contraband_found = if_else(search_conducted & is.na(contraband_found), FALSE, contraband_found)
    ) %>%
    standardize(d$metadata)
}
