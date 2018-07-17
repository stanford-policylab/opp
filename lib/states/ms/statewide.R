source("common.R")


load_raw <- function(raw_data_dir, n_max) {
  d <- load_single_file(raw_data_dir, "citpentx_sheet1.csv", n_max = n_max)
  agencies <- load_single_file(raw_data_dir, "agencies.csv")
  d$data %>%
    mutate(
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
    I = "other/unknown", # American Indian
    O = "other/unknown", # Other
    W = "white",
    Y = "asian/pacific islander"
  )

  d$data %>%
    rename(
      department_id = agency,
      # NOTE: acd descriptions are listed in "acd alpha listing.pdf"
      violation = acd
    ) %>%
    mutate(
      date = as.Date(parse_datetime(tikdate, "%Y/%m/%d")),
      # NOTE: Instructions for decoding "agency" column in "agency decode.docx".
      county_code = ifelse(
        substr(department_id, 1, 2) %in% c("00", "90"),
        substr(department_id, 3, 4),
        substr(department_id, 1, 2)
      ),
      county_name = fast_tr(county_code, tr_county),
      subject_dob = as.Date(parse_datetime(dob, "%Y/%m/%d")),
      subject_age = age_at_date(subject_dob, date),
      subject_race = fast_tr(race, tr_race),
      subject_sex = fast_tr(sex, tr_sex),
      # NOTE: Instructions for decoding "agency" column in "agency decode.docx".
      department_name = ifelse(
        substr(department_id, 1, 2) == "90",
        "Mississippi Highway Patrol",
        `Agency Name`
      ),
      # TODO(walterk): Verify that the dataset corresponds to only vehicular
      # stops.
      # https://app.asana.com/0/456927885748233/746524580819452
      type = "vehicular"
    ) %>%
    standardize(d$metadata)
}
