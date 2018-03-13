source("common.R")

load_raw <- function(raw_data_dir, n_max) {
	loading_problems <- list()
	r <- function(fname) {
    tbl <- read_csv(
      file.path(raw_data_dir, fname),
      col_types = cols(.default = "c")
    )
    loading_problems[[fname]] <<- problems(tbl)
    tbl
	}
  # TODO(ravi): should we separately process the new data files, even though
  # we'll only have like 6 months of data?
  #
	# NOTE: the updated files have completely new (but consistent) formats
	# ss_new_format <- "ss_july_16_to_sep_17_sheet_2.csv"
	# ts_new_format <- "ts_july_25_to_dec_31_2016_sheet_1.csv" 
  data <- bind_rows(
    r("ss_2008_to_2016_sheet_3.csv"),
    bind_rows(
      r("ts_aug_2008_to_dec_2012_sheet_4.csv"),
      r("ts_jan_2013_to_july_2016_sheet_4.csv")
    )
	)
	if (nrow(data) > n_max) {
		data <- data[1:n_max,]
	}
  bundle_raw(data, loading_problems)
}


clean <- function(d, calculated_features_path) {

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
    "IN*PROG" = "IN PROGRESS",
    "NON*EMER" = "NON EMERGENCY",
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

  # TODO(phoebe): can we get reason_for_stop/search/contraband fields?
  # https://app.asana.com/0/456927885748233/592025853254511
  d$data %>%
    rename(
      subject_age = age,
      # TODO(phoebe): looks like race/sex are always null?
      # https://app.asana.com/0/456927885748233/592025853254512
      subject_race = race,
      subject_sex = sex,
      # TODO(phoebe): what is 'zone'? precinct?
      # https://app.asana.com/0/456927885748233/592025853254514
      precinct = zone,
      officer_id = officerid
    ) %>%
    mutate(
      # TODO(phoebe): what is a SS stop?
      # https://app.asana.com/0/456927885748233/592025853254515
      incident_type = ifelse(naturecode == "TS", "vehicular", "pedestrian"),
      incident_date = parse_date(actdate, "%Y/%m/%d"),
      incident_time = parse_time_int(acttime),
      incident_location = str_trim(
        str_c_na(
          streetnbr,
          street,
          city,
          state,
          sep = ", "
        )
      )
    ) %>%
    add_lat_lng(
      "incident_location",
      calculated_features_path
    ) %>%
    standardize(d$metadata)
}
