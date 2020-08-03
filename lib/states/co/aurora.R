source("common.R")

# VALIDATION: [YELLOW] auroragov.org was down (2018-12-13), so the annual
# report couldn't be accessed for validation, but the data seems reasonable.
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
    "AMERICAN INDIAN/ALASKAN N" = "other",
    "ASIAN" = "asian/pacific islander",
    "BLACK/AFRICAN AMERICAN" = "black",
    "HISPANIC" = "hispanic",
    "NATIVE HAWAIIAN/PACIFIC I" = "asian/pacific islander",
    "UNKNOWN" = "unknown",
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
      subject_dob = `Date of Birth`,
      subject_first_name = `First Name`,
      subject_last_name = `Last Name`,
    ) %>%
    merge_rows(
      date,
      time,
      location,
      subject_first_name,
      subject_last_name,
      subject_dob,
      sex,
      Ethnicity,
      Race
    ) %>%
    helpers$add_lat_lng(
      "Ticket Location"
    ) %>%
    helpers$add_shapefiles_data(
    ) %>%
    helpers$add_type(
      "violation"
    ) %>%
    mutate(
      # TODO(phoebe): do we really only get citations?
      # https://app.asana.com/0/456927885748233/570989790365270
      citation_issued = TRUE,
      outcome = "citation",
      subject_race = tr_race[
        if_else(Ethnicity == "HISPANIC OR LATINO", "HISPANIC", Race)
      ],
      subject_sex = tr_sex[sex]
    ) %>%
    rename(
      raw_race = Race,
      raw_ethnicity = Ethnicity
    ) %>%
    standardize(d$metadata)
}
