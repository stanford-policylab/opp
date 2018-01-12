source("common.R")

load_raw <- function(raw_data_dir, geocodes_path) {
  data <- tibble()
	loading_problems <- list()
  r <- function(fname) {
    tbl <- read_csv(file.path(raw_data_dir, fname))
    loading_problems[[fname]] <<- problems(tbl)
    tbl
  }

  f1 = "jenna_fowler_013117_-_stocktonpd_cad_tstops_2012_2013_sheet_1.csv"
  f2 = "jenna_fowler_013117_-_stocktonpd_cad_tstops__2014_july_2016_sheet_1.csv"
  f3 = "jenna_fowler_013117_-_stocktonpd_trafficstopsurvey_2012_july_2016_sheet_1.csv"
  f4 = "jenna_fowler_013117_-_stocktonpd_trafficstopsurvey_aug_dec2016_sheet_1.csv"
  f5 = "jenna_fowler_013117_-_stocktonpd_tstops_aug_dec2016_sheet_1.csv"

  data <- add_lat_lng(data, "address", geocodes_path)

	list(data = data, metadata = list(loading_problems = loading_problems))
}


clean <- function(d) {
  d$data %>%
    select(
      -empty
    ) %>%
    rename(
      incident_id = rin,
      incident_location = address,
      # TODO(journalist): clarify relationship between
      # mir_and_description, disposition_description, type
      # https://app.asana.com/0/456927885748233/462732257741348 
      reason_for_stop = mir_and_description
    ) %>%
    filter(
      !is.na(incident_id)
    ) %>%
    separate_cols(
      possible_race_and_sex = c("subject_race", "subject_sex"),
      sep = 1
    ) %>%
    separate_cols(
      datetime = c("incident_date", "incident_time"),
      officer_no_name_1 = c("officer_id_1", "officer_name_1"),
      officer_no_name_2 = c("officer_id_2", "officer_name_2")
    ) %>%
    mutate(
      incident_type = "vehicular",
      # NOTE: vehicular because mir_and_description are all traffic
      incident_date = parse_date(incident_date, "%Y/%m/%d"),
      incident_time = parse_time(incident_time),
      subject_race = tr_race[subject_race],
      subject_sex = tr_sex[subject_sex],
      arrest_made = str_sub(disposition_description, 1, 1) == "A",
      # NOTE: includes criminal and non-criminal citations
      citation_issued = matches(disposition_description, "CITATION"),
      incident_outcome = first_of(
        arrest = arrest_made,
        citation = citation_issued
      ),
      subject_dob = ymd(subject_dob),
      officer_id_1 = parse_number(officer_id_1),
      officer_id_2 = parse_number(officer_id_2)
    ) %>%
    standardize(d$metadata)
}
