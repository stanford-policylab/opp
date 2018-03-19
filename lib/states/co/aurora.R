source("common.R")

load_raw <- function(raw_data_dir, n_max) {
  data <- tibble()
	loading_problems <- list()
  for (i in 1:5) {
    prefix <- "aurora_colorado_orr_3253_traf_tix_w_demos_sheet_"
    fname <- str_c(prefix, i, ".csv")
    tbl <- read_csv(
      file.path(raw_data_dir, fname),
      col_types = cols(`Date of Birth` = col_date())
    )
		loading_problems[[fname]] <- problems(tbl)
    data <- bind_rows(data, tbl)
    if (nrow(data) > n_max) {
      data <- data[1:n_max, ]
      break
    }
  }
  bundle_raw(data, loading_problems)
}


clean <- function(d, calculated_features_path) {
  tr_race <- c(
    "AMERICAN INDIAN/ALASKAN N" = "other/unknown",
    "ASIAN" = "asian/pacific islander",
    "BLACK/AFRICAN AMERICAN" = "black",
    "HISPANIC" = "hispanic",
    "NATIVE HAWAIIAN/PACIFIC I" = "asian/pacific islander",
    "NULL" = NA_character_,
    "UNKNOWN" = "other/unknown",
    "WHITE" = "white"
  )

  # TODO(phoebe): get search and contraband
  # https://app.asana.com/0/456927885748233/570989790365269 
  d$data %>%
    rename(
      incident_date = `Ticket Date`,
      incident_time = `Ticket Time`,
      incident_location = `Ticket Location`,
      reason_for_stop = `Incident Violation`,
      subject_dob = `Date of Birth`
    ) %>%
    add_lat_lng(
      "incident_location",
      calculated_features_path
    ) %>%
    add_incident_types(
      "reason_for_stop",
      calculated_features_path
    ) %>%
    filter(
      incident_type != "other"
    ) %>%
    mutate(
      # TODO(phoebe): do we really only get citations?
      # https://app.asana.com/0/456927885748233/570989790365270
      incident_outcome = "citation",
      citation_issued = TRUE,
      subject_race = tr_race[
        ifelse(Ethnicity == "HISPANIC OR LATINO", "HISPANIC", Race)
      ],
      subject_sex = tr_sex[sex]
    ) %>%
    standardize(d$metadata)
}
