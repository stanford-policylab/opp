source("common.R")

load_raw <- function(raw_data_dir, n_max) {
  d <- load_regex(
    raw_data_dir,
    "^aurora_colorado_orr_3253_traf_tix_w_demos_sheet_",
    n_max
  )
  bundle_raw(d$data, d$loading_problems)
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
    helpers$add_lat_lng(
      "Ticket Location"
    ) %>%
    helpers$add_shapefiles_data(
    ) %>%
    rename(
      date = `Ticket Date`,
      time = `Ticket Time`,
      location = `Ticket Location`,
      violation = `Incident Violation`,
      subject_dob = `Date of Birth`,
      district = POLICE_DIS
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
