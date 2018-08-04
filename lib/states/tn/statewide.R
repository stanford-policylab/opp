source("common.R")


load_raw <- function(raw_data_dir, n_max) {
  d <- load_regex(raw_data_dir, "\\.csv$", n_max = n_max)
  bundle_raw(d$data, d$loading_problems)
}


clean <- function(d, helpers) {
  tr_county <- json_to_tr(helpers$load_json("TN_counties.json"))
  tr_violation <- json_to_tr(helpers$load_json("TN_violations.json"))

  tr_race = c(
    A = "asian/pacific islander",
    B = "black",
    C = "asian/pacific islander",
    H = "hispanic",
    I = "other/unknown",
    J = "asian/pacific islander",
    O = "other/unknown",
    R = "other/unknown",
    W = "white"
  )

  d$data %>%
    rename(
      department_id = AGY_CDE,
      vehicle_make = VHCL_MAKE,
      vehicle_model = VHCL_MODL,
      vehicle_year = VHCL_TAG_YR
    ) %>%
    mutate(
      date = parse_date(VIOL_EVNT_DTE, "%Y-%m-%d"),
      time_numeric = parse_number(VIOL_TME),
      time_numeric = ifelse(
        is.na(AM_PM_IND),
        # NOTE: Assume times without AM/PM flag are in 24-hour time.
        time_numeric,
        if_else(
          AM_PM_IND == "P",
          if_else(time_numeric < 1200, time_numeric + 1200, time_numeric),
          time_numeric
        )
      ),
      time = parse_time(sprintf("%04d", time_numeric), "%H%M"),
      location = str_combine_cols(
        UP_STR_HWY,
        MLE_MRK_NBR,
        prefix_right = "milepost: ",
        sep = ", "
      ),
      county_name = fast_tr(CNTY_NBR, tr_county),
      subject_race = fast_tr(RACE_IND, tr_race),
      subject_sex = fast_tr(SEX_IND, tr_sex),
      department_name = if_else(
        department_id == "T",
        "Tennessee Highway Patrol",
        NA_character_
      ),
      # NOTE: The dataset is specifically vehicular citations.
      type = "vehicular",
      citation_issued = TRUE,
      outcome = "citation",
      violation = fast_tr(ORIG_TRFC_VIOL_CDE, tr_violation)
    ) %>%
    standardize(d$metadata)
}
