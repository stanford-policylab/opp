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


clean <- function(d, helpers) {

  tr_race <- c(
    "AMERICAN INDIAN/ALASKAN N" = "other/unknown",
    "ASIAN" = "asian/pacific islander",
    "BLACK/AFRICAN AMERICAN" = "black",
    "HISPANIC" = "hispanic",
    "NATIVE HAWAIIAN/PACIFIC I" = "asian/pacific islander",
    "UNKNOWN" = "other/unknown",
    "WHITE" = "white"
  )

  # TODO(phoebe): get search and contraband
  # https://app.asana.com/0/456927885748233/570989790365269 
  d$data %>%
    rename(
      date = `Ticket Date`,
      time = `Ticket Time`,
      location = `Ticket Location`,
      violation = `Incident Violation`,
      subject_dob = `Date of Birth`
    ) %>%
    helpers$add_lat_lng(
    ) %>%
    helpers$add_type(
      "violation"
    ) %>%
    filter(
      type != "other"
    ) %>%
    mutate(
      # TODO(phoebe): do we really only get citations?
      # https://app.asana.com/0/456927885748233/570989790365270
      outcome = "citation",
      citation_issued = TRUE,
      subject_race = tr_race[
        ifelse(Ethnicity == "HISPANIC OR LATINO", "HISPANIC", Race)
      ],
      subject_sex = tr_sex[sex]
    ) %>%
    standardize(d$metadata)
}
