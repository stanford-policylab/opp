source("common.R")

load_raw <- function(raw_data_dir, n_max) {
  data <- tibble()
	loading_problems <- list()

  stops_fname = 'orr_20171017191427.csv'
  stops <- read_csv(file.path(raw_data_dir, stops_fname), n_max = n_max)
  loading_problems[[stops_fname]] <- problems(stops)

  officer_fname = 'orr_-_okcpd_roster_2007-2017_sheet_1.csv'
  officer <- read_csv(file.path(raw_data_dir, officer_fname))
  loading_problems[[officer_fname]] <- problems(officer)

  officer[["ID #"]] <- str_pad(officer[["ID #"]], 4, pad = "0")
  data <- left_join(
    stops,
    officer,
    by = c("ofc_badge_no" = "ID #")
  ) %>%
  bundle_raw(loading_problems)
}


clean <- function(d, helpers) {
  # TODO(ravi): check this race mapping
  tr_race = c(
    A = "asian/pacific islander",
    B = "black",
    I = "other/unknown",
    M = "other/unknown",
    O = "other/unknown",
    S = "other/unknown",
    U = "other/unknown",
    W = "white",
    X = "other/unknown"
  )

  d$data %>%
    rename(
      date = violDate,
      time = violTime,
      location = violLocation,
      subject_race = DfndRace,
      subject_sex = DfndSex,
      subject_dob = DfndDOB,
      reason_for_stop = OffenseDesc,
      officer_id = ofc_badge_no,
      # NOTE: veh_color_2 is null 99.8% of the time
      vehicle_color = veh_color_1,
      vehicle_make = veh_make,
      vehicle_model = veh_model,
      # TODO(phoebe): what is veh_tag_st TU? roughly 10% are these
      # https://app.asana.com/0/456927885748233/521735743717410
      vehicle_registration_state = veh_tag_st,
      vehicle_year = veh_year
    ) %>%
    helpers$add_lat_lng(
    ) %>%
    # TODO(ravi): check these classifications
    # https://app.asana.com/0/456927885748233/521735743717408
    helpers$add_type(
    ) %>%
    filter(
      type != "other"
    ) %>%
    mutate(
      # NOTE: these are all citations
      citation_issued = TRUE,
      outcome = "citation",
      date = parse_date(date, "%Y%m%d"),
      time = parse_time_int(time),
      subject_race = tr_race[subject_race],
      subject_sex = tr_sex[subject_sex],
      subject_dob = parse_date(subject_dob, "%Y%m%d")
    ) %>%
    standardize(d$metadata)
}
