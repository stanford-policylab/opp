source("common.R")

# VALIDATION: [YELLOW] 2014 appears to have data collection issues, and in 2018
# we are missing months after April; unfortunately, the annual reports only
# seem to provide budgeting details, but the data looks reasonable
load_raw <- function(raw_data_dir, n_max) {
  d <- load_single_file(raw_data_dir, "citation_audit_summary.csv", n_max)
  bundle_raw(d$data, d$loading_problems)
}


clean <- function(d, helpers) {

  tr_race <- c(tr_race, "X" = "other")

  # TODO(phoebe): can we get search/contraband fields?
  # https://app.asana.com/0/456927885748233/663043550621580
  d$data %>%
    rename(
      date = Date,
      location = `Primary Street`,
      officer_id = `Officer (Badge)`,
      violation = `Violation Description`
    ) %>%
    helpers$add_type(
      "violation"
    ) %>%
    mutate(
      subject_race = tr_race[Race],
      subject_sex = tr_sex[Sex],
      # NOTE: Stop Results are all CITATION
      citation_issued = TRUE,
      # TODO(phoebe): can we get other outcomes? arrests/warnings?
      # https://app.asana.com/0/456927885748233/663043550621581
      outcome = "citation"
    ) %>%
    helpers$add_lat_lng(
    ) %>%
    helpers$add_shapefiles_data(
    ) %>%
    rename(
      region = CITY_DISTR,
      district = REPORT_DIS,
      raw_race = Race
    ) %>%
    standardize(d$metadata)
}
