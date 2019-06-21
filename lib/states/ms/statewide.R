source(here::here("lib", "common.R"))


load_raw <- function(raw_data_dir, n_max) {
  d <- load_single_file(raw_data_dir, "citpentx_sheet1.csv", n_max = n_max)
  agencies <- load_single_file(raw_data_dir, "agencies.csv")
  mutate(
    d$data,
    agency = str_pad(agency, 4, pad = '0')
  ) %>%
  left_join(
    agencies$data,
    by = c("agency" = "Agency code")
  ) %>%
  bundle_raw(c(d$loading_problems, agencies$loading_problems))
}


clean <- function(d, helpers) {
  tr_county <- json_to_tr(helpers$load_json("MS_counties.json"))

  tr_race <- c(
    B = "black",
    I = "other", # American Indian
    O = "other", # Other
    W = "white",
    Y = "asian/pacific islander"
  )

  d$data %>%
    rename(
      department_id = agency,
      # NOTE: acd descriptions are listed in "acd alpha listing.pdf"
      violation = acd
    ) %>%
    add_raw_colname_prefix(
      race
    ) %>% 
    mutate(
      date = as.Date(parse_datetime(tikdate, "%Y/%m/%d")),
      # NOTE: Instructions for decoding "agency" column in "agency decode.docx".
      county_code = if_else(
        substr(department_id, 1, 2) %in% c("00", "90"),
        substr(department_id, 3, 4),
        substr(department_id, 1, 2)
      ),
      county_name = fast_tr(county_code, tr_county),
      subject_dob = as.Date(parse_datetime(dob, "%Y/%m/%d")),
      subject_age = age_at_date(subject_dob, date),
      subject_race = fast_tr(raw_race, tr_race),
      subject_sex = fast_tr(sex, tr_sex),
      speed = if_else(mph == 0, NA_integer_, as.integer(mph)),
      posted_speed = if_else(spdzone == 0, NA_integer_, as.integer(spdzone)),
      # NOTE: Instructions for decoding "agency" column in "agency decode.docx".
      department_name = if_else(
        substr(department_id, 1, 2) == "90",
        "Mississippi Highway Patrol",
        `Agency Name`
      ),
      # NOTE: Only vehicular stops were requested for the data received in Aug
      # 2016.
      type = "vehicular"
    ) %>%
    standardize(d$metadata)
}
