source(here::here("lib", "common.R"))


load_raw <- function(raw_data_dir, n_max) {
  d <- load_all_csvs(raw_data_dir, n_max = n_max)
  colnames(d$data) <- make_ergonomic(colnames(d$data))
  # Add orig camel case to match calculated features of contraband classification
  d$data <- mutate(d$data, ContrabandDesc = contrabanddesc)
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
    add_raw_colname_prefix(
      officer_race,
      race,
      sex,
      sectionnum, 
      offensecode,
      contact_type,
      contrabanddesc
    ) %>% 
    rename(
      county_name = county,
      subject_age = defendent_age,
      officer_id = officer_badge_number,
      officer_age = officer_age,
      officer_last_name = officer_name,
      department_id = policedivision,
      reason_for_stop = contactreason
    ) %>%
    helpers$add_contraband_type(
      "ContrabandDesc"
    ) %>%
    mutate(
      date = parse_date(dateissued, "%m/%d/%Y"),
      location = str_c_na(highwaytype, highwaynum, sep = " "),
      county_name = str_c(county_name, " County"),
      lat = parse_number(latitudedec),
      lat = if_else(lat == 0, NA_real_, lat),
      lng = parse_number(longitudedec),
      lng = if_else(lng == 0, NA_real_, lng),
      subject_race = fast_tr(raw_race, tr_race),
      subject_sex = fast_tr(raw_sex, tr_sex),
      officer_race = fast_tr(raw_officer_race, tr_race),
      # NOTE: Data received in Aug 2016 was mostly vehicular stops.
      type = if_else(reason_for_stop == "Pedestrian", "pedestrian", "vehicular"),
      violation = str_c_na(raw_sectionnum, raw_offensecode, sep = " "),
      arrest_made = felonyarrest == "1" | jailed == "1",
      citation_issued = raw_contact_type == "Citation",
      # TODO(phoebe): The other main value of "Contact Type" is "Public
      # Contact". It is unclear whether a warning is issued in the case of
      # "Public Contact". This needs to be clarified.
      # https://app.asana.com/0/456927885748233/778596457530887
      outcome = first_of(
        "arrest" = arrest_made,
        "citation" = citation_issued
      ),
      contraband_drugs = contraband_drugs == "1" | contrabanddrugs == "1"
        | contrabanddrugparaphenalia == "1",
      contraband_weapons = contraband_weapons == "1" | contrabandweapons == "1",
      # NOTE: Including `!is.na(ContrabandDesc)` was discussed at length. This
      # mimics the processing decision of the old analysis, in addition to staying
      # true to the department's definition of contraband. Without that inclusion,
      # contraband recovery is low enough to raise skepticism, and includes many,
      # many zeros, especially for hispanic recovery.
      # TODO: Seems like there are very few instances when ContrabandDesc,
      # which is a free field, indicates either no search was conducted or no
      # contraband was recovered, etc. Does not seem large enough that trends would
      # change, but may be worth in the future doing some work to extract contraband
      # vs no contraband from this ContrabandDesc field.
      contraband_found = contraband_drugs | contraband_weapons 
        | contraband == "1" | !is.na(ContrabandDesc),
      search_person = subjectsearched == "1" | passengersearched == "1",
      search_vehicle = vehiclesearched == "1",
      # NOTE: 4 "searched" are NA. We assume these to be False
      search_conducted = !is.na(searched) & 
        (searched == "1" | search_person | search_vehicle),
      # An additional one row NA from search person/vehicle; cast to FALSE
      search_conducted = replace_na(search_conducted, FALSE),
      # NOTE: mimics old opp
      contraband_found = if_else(search_conducted & is.na(contraband_found), 
                                 FALSE, contraband_found)
    ) %>%
    standardize(d$metadata)
}
