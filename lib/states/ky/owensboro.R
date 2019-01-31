source("common.R")


# VALIDATION: [GREEN] There is only partial data fro 2015 and 2017. The PD's
# 2016 Annual Report cites figures that are similar to those in the data; for
# instance, there were 308 "Street Crimes Unit" arrests; we have 429 arrests
# from traffic violations, which is in the same neighborhood. The Annual
# Report doesn't give any traffic statistics but the data here seems to be on
# the same magnitude as that in the report.
# NOTE: There are some aggregate statistics in excel files for 2016/early 2017
# on citations and drugs in the data directory
load_raw <- function(raw_data_dir, n_max) {
  # NOTE: FI CARDS are "when an officer comes across a person/persons in a
  # suspicious circumstance or around an area being watched"

  # NOTE: there is a list_of_officers.csv as well as the excel spreadsheet
  # (preferable given the formatting) that have more officer information.
  loading_problems <- list()
  r <- function(fname) {
    tbl <- read_csv(
      file.path(raw_data_dir, fname),
      col_types = cols(.default = "c")
    )
    loading_problems[[fname]] <<- problems(tbl)
    tbl
  }

  data <- tibble()
  for (fname_prefix in c("2015-2016_traffic_", "2017_traffic_")) {
    tbl <- r(
        str_c(fname_prefix, "citations.csv")
      ) %>%
      left_join(
        r(str_c(fname_prefix, "location.csv")),
        by = "CONTROL NUMBER"
      ) %>%
      left_join(
        r(str_c(fname_prefix, "offender.csv")),
        by = "CONTROL NUMBER"
      )
    data <- bind_rows(data, tbl)
  }

  if (nrow(data) > n_max) {
    data <- data[1:n_max,]
  }

  # NOTE: the data table has fixed-width, 0-padded violation codes
  violations <- r("violation_codes_sheet_1.csv") %>%
    rename(code = `Viol. Code`) %>%
    mutate(code = str_pad(code, width = 5, pad = "0"))
  violations_colnames <- colnames(violations)
  # NOTE: column names are of the format 'VIOLATION CODE <N>' in data
  # join the violation codes table onto the data table once for each violation
  for (i in seq(1:9)) {
    colnames(violations) <- str_c(violations_colnames, " ", i)
    join_by <- c(str_c("code ", i))
    names(join_by) <- str_c("VIOLATION CODE ", i)
    data <- left_join(
      data,
      violations,
      by = join_by
    )
  }

  bundle_raw(data, loading_problems)
}


clean <- function(d, helpers) {

  tr_race <- c(
    "AMER IND/ALASKAN" = "other/unknown",
    "ASIAN" = "asian/pacific islander",
    "BLACK" = "black",
    "WHITE" = "white"
  )

  # TODO(phoebe): can we get search/contraband data?
  # https://app.asana.com/0/456927885748233/586847974785232
  # TODO(phoebe): what are TOTAL COUNTS? is each row in citations multiple?
  # https://app.asana.com/0/456927885748233/730396938648773
  d$data %>%
    rename(
      vehicle_registration_state = `REGISTRATION STATE`,
      officer_id = `OFFICER BADGE/ID NUMBER`
    ) %>%
    mutate(
      date = parse_date(`CITATION DATE`, "%Y/%m/%d"),
      time = parse_time_int(`VIOLATION TIME`),
      # NOTE: use the first violation under the assumption that this is the
      # "main" violation and likely the reason for the stop
      location = str_c_na(
        `VIOLATION EXACT LOCATION`,
        `ADDRESS CITY`,
        `ADDRESS STATE`,
        `ADDRESS ZIP`,
        sep = ", "
      ),
      lat = parse_double(`VIOLATION LAT DECIMAL`),
      # NOTE: without negating longitude, all stops are in central China
      lng = -parse_double(`VIOLATION LONG DECIMAL`),
      reason_for_stop = `Violation Description 1`,
      subject_race = tr_race[RACE],
      subject_sex = tr_sex[GENDER],
      subject_dob = parse_date(`BIRTH DATE`, "%Y/%m/%d"),
      # TODO(phoebe): all citations with sometimes arrests? warnings?
      # https://app.asana.com/0/456927885748233/586847974785233
      citation_issued = TRUE,
      arrest_made = tr_yn[`ARREST INDICATOR`],
      outcome = first_of(
        arrest = arrest_made,
        citation = citation_issued
      )
    ) %>%
    helpers$add_type(
      "Violation Description 1"
    ) %>%
    helpers$add_shapefiles_data(
    ) %>%
    rename(
      sector = SECTOR
    ) %>%
    standardize(d$metadata)
}
