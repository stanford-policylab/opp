source("common.R")

# VALIDATION: [YELLOW] auroragov.org was down (2018-12-13), so the annual
# report couldn't be accessed for validation, but the data seems reasonable.
load_raw <- function(raw_data_dir, n_max) {
  # NOTE: Here, "old" means second-wave (Dan and Amy) OPP in 2018 and 2019, and
  # "new" means the data update led by Phoebe in 2020.
  old_d <- load_regex(
    raw_data_dir,
    "^aurora_colorado_orr_3253_traf_tix_w_demos_sheet_",
    n_max
  )
  # NOTE: Columns are formatted identically but have different names between the
  # new and old data, with the exception of race and ethnicity.
  new_d <- load_regex(
    raw_data_dir,
    "^copy_of_apd_traf_tickets_2018_thru_ytd_2020_sheet_",
    n_max
  )

  bundle_raw(
    bind_rows(old_d$data, new_d$data),
    c(old_d$loading_problems, new_d$loading_problems)
  )
}

clean <- function(d, helpers) {

  tr_race <- c(
    "AMERICAN INDIAN/ALASKAN N" = "other",
    "ASIAN" = "asian/pacific islander",
    "BLACK/AFRICAN AMERICAN" = "black",
    "HISPANIC" = "hispanic",
    "HISPANIC OR LATINO" = "hispanic", 
    "NATIVE HAWAIIAN/PACIFIC I" = "asian/pacific islander",
    "UNKNOWN" = "unknown",
    "WHITE" = "white"
  )

  # TODO(phoebe): get search and contraband
  # https://app.asana.com/0/456927885748233/570989790365269 
  d$data %>%
    mutate(
      date = coalesce(
        `Ticket Date`,
        `TRAFFIC Tickets\nIssued Between\n1/1 - 12/31/18`,
        `TRAFFIC Tickets\nIssued Between\n1/1 - 12/31/19`,
        `TRAFFIC Tickets\nIssued Between\n1/1 - 7/31/20`
      ),
      time = coalesce(Time,`Ticket Time`),
      location = coalesce(Location, `Ticket Location`), 
      violation = coalesce(Violation, `Incident Violation`),
      sex = coalesce(Sex, sex), 
    ) %>%
    select(-Violation, -Location, -Sex, -Time) %>%
    rename(
      subject_dob = `Date of Birth`,
      subject_first_name = `First Name`,
      subject_last_name = `Last Name`
    ) %>%
    rename_all(str_to_lower) %>%
    mutate_all(str_trim) %>%
    merge_rows(
      date,
      time,
      location,
      subject_first_name,
      subject_last_name,
      subject_dob,
      sex,
      ethnicity,
      race,
      # For 2018-2020, `number` is citation number.
      number
    ) %>%
    helpers$add_lat_lng(
      "location"
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
      old_subject_race = tr_race[
        if_else(ethnicity == "HISPANIC OR LATINO", "HISPANIC", race)
      ],
      new_subject_race = tr_race[`race/ethnicity`],
      subject_race = coalesce(old_subject_race, new_subject_race),
      subject_sex = tr_sex[sex],
      # NOTE: Race and ethnicity are not differentiated from 2018 on.
      raw_race = coalesce(race, `race/ethnicity`)
    ) %>%
    rename(
      raw_ethnicity = ethnicity
    ) %>%
    standardize(d$metadata)
}
