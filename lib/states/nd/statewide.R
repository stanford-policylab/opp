source("common.R")


load_raw <- function(raw_data_dir, n_max) {
  d <- load_regex(raw_data_dir, "^Request", n_max = n_max)
  bundle_raw(d$data, d$loading_problems)
}


clean <- function(d, helpers) {
  tr_race <- c(
    Asian = "asian/pacific islander",
    Hispanic = "hispanic",
    White = "white",
    Other = "other/unknown",
    "African American" = "black",
    "Native American" = "other/unknown"
  )

  # NOTE: Each row in the dataset corresponds to a citation. We dedup to have
  # one row per stop.
  d$data %>%
    group_by(
      Age,
      county_name,
      desc_of_area,
      highway,
      hwy_suffix,
      Race,
      ref_point,
      sex,
      street_cnty_rd_location,
      violation_date_time
    ) %>% 
    summarize(
      violation = str_c_sort_uniq(century_code_viol),
      reason_for_stop = str_c_sort_uniq(description_50)
    ) %>%
    ungroup(
    ) %>%
    rename(
      subject_age = Age
    ) %>%
    mutate(
      date = date(parse_datetime(violation_date_time, "%m/%d/%y %H:%M")),
      time = parse_time(violation_date_time, "%m/%d/%y %H:%M"),
      # TODO(walterk): Fix this; issues because str_c_na(NA, NA) returns "".
      location = str_c_na(
        str_c_na(
          street_cnty_rd_location,
          str_c_na(highway, hwy_suffix),
          ref_point,
          sep = " "
        ),
        desc_of_area,
        sep = ", "
      ),
      subject_race = tr_race[Race],
      subject_sex = tr_sex[sex],
      type = if_else(
        # NOTE: Inferring type "vehicular" based on century_code_viol and
        # whether the violation section starts with "39".
        # See: https://www.legis.nd.gov/cencode/t39.html
        str_detect(violation, "(^|\\|)39"),
        "vehicular",
        NA_character_
      )
      # TODO(walterk): The old code seems to indicate that this is all state
      # patrol stops. Figure out if this is really true, in which case
      # department_name is "North Dakota State Highway Patrol".
    ) %>%
    standardize(d$metadata)
}
