source("common.R")


# VALIDATION: [YELLOW] The Houston PD's Annual Reports don't list traffic
# figures, but the stop counts don't appear unreasonable for a city of 2M
# people. 2018 only has partial data.
load_raw <- function(raw_data_dir, n_max) {
  d <- load_years(raw_data_dir, n_max = n_max)
  bundle_raw(d$data, d$loading_problems)
}


clean <- function(d, helpers) {

  tr_race <- c(
    tr_race,
    "american indian" = "other",
    "pacific islander" = "asian/pacific islander"
  )

  # TODO(phoebe): can we get search/contraband fields?
  # https://app.asana.com/0/456927885748233/663043550621572
  d$data %>%
  merge_rows(
    `Defendant Name`,
    Gender,
    Race,
    Street,
    Block,
    `Scnd Street`,
    `Scnd Block`,
    `Officer Name`,
    `Offense Date`
  ) %>%
  filter(
    `Defendant Name` != "TICKET, TEST"
  ) %>%
  rename(
    vehicle_color = `V Color`,
    vehicle_make = `V Make`,
    vehicle_model = `V Model`,
    violation = `Violation Description`,
    speed = Speed,
    posted_speed = `Posted Speed`
  ) %>%
  separate_cols(
    `Defendant Name` = c("subject_last_name", "subject_first_middle_name"),
    sep = ", "
  ) %>%
  separate_cols(
    subject_first_middle_name = c("subject_first_name", "subject_middle_name"),
    sep = " "
  ) %>%
  mutate(
    # TODO(phoebe): can we confirm these are all vehicle related incidents?
    # https://app.asana.com/0/456927885748233/663043550621573
    type = "vehicular",
    date = parse_date(`Offense Date`),
    # NOTE: either block and street are provided or two cross streets
    location = coalesce(
      str_c(Block, Street, sep = " "),
      str_c(Street, "AND", `Scnd Street`, sep = " "),
      Street
    ),
    subject_race = tr_race[str_to_lower(Race)],
    subject_sex = tr_sex[Gender],
    citation_issued = !is.na(`Citataion Num`),
    # TODO(phoebe): can we get other outcomes? arrests/warnings?
    # https://app.asana.com/0/456927885748233/663043550621574
    outcome = first_of(
      "citation" = citation_issued
    )
  ) %>%
  helpers$add_lat_lng(
  ) %>%
  helpers$add_shapefiles_data(
  ) %>%
  rename(
    beat = Beats,
    district = District.x,
    raw_race = Race
  ) %>%
  standardize(d$metadata)
}
