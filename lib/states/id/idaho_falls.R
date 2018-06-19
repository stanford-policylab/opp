source("common.R")


load_raw <- function(raw_data_dir, n_max) {
  # TODO(ravi): should we separately process the new data files, even though
  # we'll only have like 6 months of data?
  # https://app.asana.com/0/456927885748233/592025853254509
	# NOTE: the updated files have completely new (but consistent) formats
	# ss_new_format <- "ss_july_16_to_sep_17_sheet_2.csv"
	# ts_new_format <- "ts_july_25_to_dec_31_2016_sheet_1.csv" 
  d <- load_regex(
    raw_data_dir,
    str_c(
      "ss_2008_to_2016_sheet_3.csv",
      "ts_aug_2008_to_dec_2012_sheet_4.csv",
      "ts_jan_2013_to_july_2016_sheet_4.csv",
      sep = "|"
    ),
    n_max
  )
  bundle_raw(d$data, d$loading_problems)
}


clean <- function(d, helpers) {

  # TODO(phoebe): can we get deeper explanations of these, like what do they
  # really mean (also, what's a reptspec?)? Can we translate these to outcome,
  # i.e. warning, citation, arrest?
  # https://app.asana.com/0/456927885748233/592025853254510
  reptspec_tr <- c(
    "CIRCUMST" = "CIRCUMSTANCE",
    "CITIZEN" = "CITIZEN",
    "COMPLAIN" = "COMPLAINT",
    "DRUG-LAB" = "DRUG-LAB",
    "HAZARD" = "HAZARD",
    "IN*PROG" = "IN-PROGRESS",
    "NON*EMER" = "NON-EMERGENCY",
    "OFFICER" = "OFFICER",
    "OTHER" = "OTHER",
    "OTHER-AG" = "OTHER AGENCY",
    "PAST" = "PAST",
    "PD" = "PROPERTY DAMAGE",
    "PERSON" = "PERSON",
    "PI" = "PERSONAL INJURY",
    "SAT" = "SATURATION",
    "VEHICLE" = "VEHICLE"
  )

  # NOTE: reason_for_stop/search/contraband fields aren't recorded unless
  # a case is opened
  d$data %>%
    rename(
      subject_age = age,
      # NOTE: race and sex are not on the ID driver's license
      # the only extant values must have been filled in manually
      # i.e. getting race and sex for the remaining stops is not possible
      subject_race = race,
      subject_sex = sex,
      officer_id = officerid,
      division = emdivision
    ) %>%
    mutate(
      # NOTE: TS is Traffic Stop; SS is Subject Stop
      type = ifelse(naturecode == "TS", "vehicular", "pedestrian"),
      date = parse_date(actdate, "%Y/%m/%d"),
      time = parse_time_int(acttime),
      location = str_trim(
        str_c_na(
          streetnbr,
          street,
          city,
          state,
          sep = ", "
        )
      )
    ) %>%
    helpers$add_lat_lng(
    ) %>%
    standardize(d$metadata)
}
