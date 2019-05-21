source(here::here("lib", "common.R"))


load_raw <- function(raw_data_dir, n_max) {
  d <- load_regex(raw_data_dir, "^Request", n_max = n_max)
  bundle_raw(d$data, d$loading_problems)
}


clean <- function(d, helpers) {
  tr_race <- c(
    "African American" = "black",
    "Asian" = "asian/pacific islander",
    "Hispanic" = "hispanic",
    "Native American" = "other/unknown",
    "Other" = "other/unknown",
    "White" = "white"
  )

  # NOTE: Each row in the dataset corresponds to a citation. We dedup to have
  # one row per stop.
  d$data %>%
    add_raw_colname_prefix(
      Race
    ) %>% 
    mutate(
      violation = str_c(century_code_viol, description_50, sep = ": ")
    ) %>%
    merge_rows(
      Age,
      county_name,
      desc_of_area,
      highway,
      hwy_suffix,
      raw_Race,
      ref_point,
      sex,
      street_cnty_rd_location,
      violation_date_time
    ) %>% 
    mutate(
      subject_age = Age,
      date = as.Date(parse_datetime(violation_date_time, "%m/%d/%y %H:%M")),
      time = parse_time(violation_date_time, "%m/%d/%y %H:%M"),
      location = if_else(
        is.na(highway) & is.na(hwy_suffix),
        str_c_na(street_cnty_rd_location, ref_point, desc_of_area, sep = ", "),
        str_c_na(
          street_cnty_rd_location,
          str_c_na(highway, hwy_suffix),
          ref_point,
          desc_of_area,
          sep = ", "
        )
      ),
      # NOTE: If all values feeding into location are NA, str_c_na returns "".
      # We convert to NA here.
      location = if_else(location == "", NA_character_, location),
      county_name = str_c(county_name, " County"),
      subject_race = tr_race[raw_Race],
      subject_sex = tr_sex[sex],
      type = if_else(
        # NOTE: Inferring type "vehicular" based on century_code_viol and
        # whether the violation section starts with "39".
        # See: https://www.legis.nd.gov/cencode/t39.html
        str_detect(violation, "(^|\\|)39"),
        "vehicular",
        NA_character_
      )
    ) %>%
    standardize(d$metadata)
}
