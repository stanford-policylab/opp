source(here::here("lib", "common.R"))

load_raw <- function(raw_data_dir, n_max) {
  # NOTE: 2014 data come from three sheets of a spreadsheet. Only the first
  # sheet has column headers. The second and third sheets have one and two
  # extra variables, respectively. They are unlabeled, but we know their
  # labels from the original analysis. We add NAs for these variables in the
  # sheets where they are missing, and standardize the column headers between
  # all of them.
  nh14_1 <- load_single_file(
    raw_data_dir,
    "NewHampshire_2014_redacted_eTicket_file_NHSP_sheet1.csv",
    n_max = n_max
  )
  nh14_1a <- nh14_1$data %>%
    add_column(
      DEF_COMPANY = NA_character_,
      .after = "CITATION_SOURCE_TXT"
    ) %>%
    add_column(
      DEF_BIRTH_DATE = NA_character_,
      .after = "GENDER_CDE"
    ) %>%
    add_column(
      STATE_CDE = NA_character_,
      .after = "WEIGHT_IN_POUNDS"
    )

  nh14_2 <- load_single_file(
    raw_data_dir,
    "NewHampshire_2014_redacted_eTicket_file_NHSP_sheet2.csv",
    col_names = FALSE,
    n_max = n_max
  )
  nh14_2a <- nh14_2$data %>%
    add_column(
      DEF_BIRTH_DATE = NA_character_,
      .after = "X46"
    ) %>%
    add_column(
      STATE_CDE = NA_character_,
      .after = "X50"
    )
  colnames(nh14_2a) <- colnames(nh14_1a)

  nh14_3 <- load_single_file(
    raw_data_dir,
    "NewHampshire_2014_redacted_eTicket_file_NHSP_sheet3.csv",
    col_names = FALSE,
    n_max = n_max
  )
  nh14_3a <- nh14_3$data
  colnames(nh14_3a) <- colnames(nh14_1a)

  nh14 <- rbind(nh14_1a, nh14_2a, nh14_3a)

  # NOTE: 2015 data come from three sheets of a spreadsheet. Only the first
  # sheet has column labels, but the sheets all have consistent variables.
  # Compared with 2014, they are all missing the DEF_COMPANY variable, which
  # we add and fill with NA.
  nh15_1 <- load_single_file(
    raw_data_dir,
    "NewHampshire_2015_eticket_totals_by_trooper_sheet1.csv",
    n_max = n_max
  )
  nh15_2 <- load_single_file(
    raw_data_dir,
    "NewHampshire_2015_eticket_totals_by_trooper_sheet2.csv",
    col_names = colnames(nh15_1$data),
    n_max = n_max
  )
  nh15_3 <- load_single_file(
    raw_data_dir,
    "NewHampshire_2015_eticket_totals_by_trooper_sheet3.csv",
    col_names = colnames(nh15_1$data),
    n_max = n_max
  )

  nh15 <- rbind(
      nh15_1$data,
      nh15_2$data,
      nh15_3$data
    ) %>%
    add_column(
      DEF_COMPANY = NA_character_,
      .after = "CITATION_SOURCE_TXT"
    )

  nh <- rbind(nh14, nh15) %>% 
    select(
      INFRACTION_DATE, INFRACTION_TIME, INFRACTION_COUNTY_NAME, 
      INFRACTION_CITY_NME, INFRACTION_LOCATION_TXT, GENDER_CDE, DEF_BIRTH_DATE, 
      RACE_CDE, LATITUDE, LONGITUDE, LICENSE_STATE_CDE, AIRCRAFT_EVENT_ID,
      INFRACTION_RSA_CDE, DMV_INFRACTION_REASON_CDE, CITATION_RESPONSE_DSC
    ) 

  loading_problems <- c(
    nh14_1$loading_problems,
    nh14_2$loading_problems,
    nh14_3$loading_problems,
    nh15_1$loading_problems,
    nh15_2$loading_problems,
    nh15_3$loading_problems
  )

  bundle_raw(nh, loading_problems)
}


clean <- function(d, helpers) {
  # NOTE: Race data is a mess. This translator maps all variations that occur
  # more than 10 times in the data. This covers 99.9% of non-NA rows; note,
  # however, that more than a third of the race entries are NA anyway.
  tr_race <- c(
    "MID EAST" = "white",
    "MIDDLE EAS" = "white",
    "W" = "white",
    "WH" = "white",
    "WHI" = "white",
    "WHIE" = "white",
    "WHIL" = "white",
    "WHILE" = "white",
    "WHITEQ" = "white",
    "WHT" = "white",
    "WHTE" = "white",
    "WHTIE" = "white",
    "B" = "black",
    "BLACK" = "black",
    "BLACK/" = "black",
    "BLACK/AFRI" = "black",
    "BLK" = "black",
    "HIS" = "hispanic",
    "LAT" = "hispanic",
    "AIN" = "asian/pacific islander",
    "ASI" = "asian/pacific islander",
    "PIS" = "asian/pacific islander",
    "AKN" = "other/unknown",
    "ALASKA NAT" = "other/unknown",
    "I" = "other/unknown",
    "INDIAN" = "other/unknown",
    "M" = "other/unknown",
    "NHI" = "other/unknown",
    "O" = "other/unknown",
    "U" = "other/unknown",
    "UNK" = "other/unknown"
  )


  # TODO(phoebe): can we get reason_for_stop/search/contraband/arrest_made
  # fields?
  # https://app.asana.com/0/456927885748233/729261812716291
  d$data %>%
    # Remove duplicates
    merge_rows(
      INFRACTION_DATE, INFRACTION_TIME, INFRACTION_COUNTY_NAME, 
      INFRACTION_CITY_NME, INFRACTION_LOCATION_TXT, GENDER_CDE, DEF_BIRTH_DATE, 
      RACE_CDE, LATITUDE, LONGITUDE, LICENSE_STATE_CDE, AIRCRAFT_EVENT_ID
    ) %>%
    add_raw_colname_prefix(
      RACE_CDE,
      CITATION_RESPONSE_DSC
    ) %>% 
    rename(
      violation = DMV_INFRACTION_REASON_CDE
    ) %>%
    mutate(
      date = parse_date(INFRACTION_DATE, "%m/%d/%Y"),
      time = parse_time(INFRACTION_TIME, "%I:%M %p"),
      location = str_c_na(
        INFRACTION_LOCATION_TXT,
        INFRACTION_CITY_NME,
        sep=", "
      ),
      county_name = str_c(str_to_title(INFRACTION_COUNTY_NAME), " County"),
      lat = parse_coord(LATITUDE),
      lng = parse_coord(LONGITUDE),
      subject_dob = parse_date(DEF_BIRTH_DATE, "%m/%d/%Y"),
      subject_age = age_at_date(subject_dob, date),
      subject_race = fast_tr(raw_RACE_CDE, tr_race),
      subject_sex = fast_tr(GENDER_CDE, tr_sex),
      # NOTE: only vehicular stops in data
      type = "vehicular",
      citation_issued = str_detect(raw_CITATION_RESPONSE_DSC, "PBM"),
      warning_issued = str_detect(raw_CITATION_RESPONSE_DSC, "W"),
      outcome = first_of(
        summons = str_detect(raw_CITATION_RESPONSE_DSC, "MA"),
        citation = citation_issued,
        warning = warning_issued
      )
    ) %>%
    standardize(d$metadata)
}
