source("common.R")

load_raw <- function(raw_data_dir, n_max) {
  # TODO(phoebe): what are FI CARDS?
  # https://app.asana.com/0/456927885748233/585575759775409 

  # NOTE: there is a list_of_officers.csv as well as the excel spreadsheet
  # (preferable given the formatting) that have more officer information.
  loading_problems <- list()
  r <- function(fname) {
    tbl <- read_csv(file.path(raw_data_dir, fname),
                    col_types = cols(.default = "c"))
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

  violations <- r("violation_codes_sheet_1.csv") %>%
    rename(code = `Viol. Code`) %>%
    mutate(code = str_pad(code, width = 5, pad = "0"))
  violations_colnames <- colnames(violations)
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


clean <- function(d, calculated_features_path) {

  tr_race <- c(
    "AMER IND/ALASKAN" = "other/unknown",
    "ASIAN" = "asian/pacific islander",
    "BLACK" = "black",
    "WHITE" = "white"
  )

  # TODO(phoebe): can we get search/contraband data?
  # https://app.asana.com/0/456927885748233/586847974785232
  d$data %>%
    rename(
      incident_location = `VIOLATION EXACT LOCATION`,
      incident_lat = `VIOLATION LAT DECIMAL`,
      incident_lng = `VIOLATION LONG DECIMAL`,
      vehicle_registration_state = `REGISTRATION STATE`,
      officer_id = `OFFICER BADGE/ID NUMBER`
    ) %>%
    mutate(
      incident_date = parse_date(`CITATION DATE`, "%Y/%m/%d"),
      # NOTE: use the first violation under the assumption that this is the
      # "main" violation and likely the reason for the stop
      reason_for_stop = `Violation Description 1`,
      subject_race = tr_race[RACE],
      subject_sex = tr_sex[GENDER],
      subject_dob = parse_date(`BIRTH DATE`, "%Y/%m/%d"),
      # TODO(phoebe): all citations with sometimes arrests? warnings?
      # https://app.asana.com/0/456927885748233/586847974785233
      citation_issued = TRUE,
      arrest_made = yn_to_tf[`ARREST INDICATOR`],
      incident_outcome = first_of(
        arrest = arrest_made,
        citation = citation_issued
      )
    ) %>%
    add_incident_types(
      "Violation Description 1",
      calculated_features_path
    ) %>%
    standardize(d$metadata)
}
