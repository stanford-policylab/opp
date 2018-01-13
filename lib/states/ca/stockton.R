source("common.R")

load_raw <- function(raw_data_dir, geocodes_path) {
  data <- tibble()
	loading_problems <- list()
  r <- function(fname) {
    tbl <- read_csv(file.path(raw_data_dir, fname))
    loading_problems[[fname]] <<- problems(tbl)
    tbl
  }
  # TODO(journalist): how do we join these sets of files? 
  # stop_files contain date, time, location, officer demographics
  stop_files <- c(
    "jenna_fowler_013117_-_stocktonpd_cad_tstops_2012_2013_sheet_1.csv",
    "jenna_fowler_013117_-_stocktonpd_cad_tstops__2014_july_2016_sheet_1.csv",
    "jenna_fowler_013117_-_stocktonpd_tstops_aug_dec2016_sheet_1.csv"
  )
  # survey_files contain date, outcome, subject demographics
  survey_files <- c(
    "jenna_fowler_013117_-_stocktonpd_trafficstopsurvey_2012_july_2016_sheet_1.csv",
    "jenna_fowler_013117_-_stocktonpd_trafficstopsurvey_aug_dec2016_sheet_1.csv"
  )
  data <- bind_rows(r(survey_files[1]), r(survey_files[2]))

  # TODO(danj): location is in the stop files, but let's wait to
  # geocode until we are sure we are going to use those files
  # data <- add_lat_lng(data, "address", geocodes_path)

	list(data = data, metadata = list(loading_problems = loading_problems))
}


clean <- function(d) {
  names(d$data) <- tolower(names(d$data))
  tr_sex <- c(
    Female = "female",
    Male = "male"
  )
  tr_race <- c(
    "Asian" = "asian/pacific islander",
    "Black/African American" = "black",
    "Hispanic" = "hispanic",
    "Others" = "other/unknown",
    "White/Caucasian" = "white"
  )
  # TODO(ravi): what to do about this outcome?
  tr_outcome <- c(
    "1-In-Custody Arrest" = "arrest",
    "2-Citation Issued" = "citation",
    "3-Verbal Warning" = "warning"
    # 4-Public Service
  )
  # TODO(ravi): what should we classify these other search types as
  tr_search_type <- c(
    # 1-No Search Conducted
    "2-Consent" = "consent",
    "3-Probable Cause (Terry)" = "probable cause",
    # 4-Two Inventory Search
    "5-Incidental to Lawful Arrest" = "incident to arrest"
    # 6-Pursuant to Lawful Search Warrant
    # 7-Probation/Parole Search
  )

  d$data %>%
    select(
      -x3  # empty column
    ) %>%
    rename(
      incident_date = in_date,   
      officer_id_1 = officer_id,
      officer_id_2 = officer2_id,
      subject_age = age,
      subject_sex = gender,
      subject_race = race,
      probable_cause = probcause
    ) %>%
    mutate(
      incident_id = trafsurvey_id,
      incident_outcome = tr_outcome[result],
      search_type = tr_search_type[search],
      subject_sex = tr_sex[subject_sex],
      subject_race = tr_race[subject_race],
      search_conducted = !startsWith(search, "1-No Search"),
      arrest_made = result == "1-In-Custody Arrest",
      citation_issued = result == "2-Citation Issued",
      warning_issued = result == "3-Verbal Warning"
    ) %>%
    standardize(d$metadata)
}
