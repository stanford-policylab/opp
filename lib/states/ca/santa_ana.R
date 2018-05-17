source("common.R")

load_raw <- function(raw_data_dir, n_max) {
  fname <- "citation_audit_summary.csv"
  data <- read_csv(file.path(raw_data_dir, fname), n_max = n_max)
  loading_problems <- list()
  loading_problems[[fname]] <- problems(data)
  bundle_raw(data, loading_problems)
}


clean <- function(d, helpers) {

  tr_race <- c(
    "H" = "hispanic",
    "U" = "other/unknown",
    "W" = "white",
    "X" = "other/unknown",
    "A" = "asian/pacific islander",
    "B" = "black"
  )

  # TODO(phoebe): can we get search/contraband fields?
  # https://app.asana.com/0/456927885748233/663043550621580
  d$data %>%
    rename(
      incident_date = Date,
      incident_location = `Primary Street`,
      officer_id = `Officer (Badge)`,
      reason_for_stop = `Violation Description`
    ) %>%
    helpers$add_incident_type(
    ) %>%
    filter(
      incident_type != "other"
    ) %>%
    mutate(
      subject_race = tr_race[Race],
      subject_sex = tr_sex[Sex],
      citation_issued = !is.na(`Citation #`),
      # TODO(phoebe): can we get other outcomes? arrests/warnings?
      # https://app.asana.com/0/456927885748233/663043550621581
      incident_outcome = first_of(
        "citation" = citation_issued
      )
    ) %>%
    helpers$add_lat_lng(
    ) %>%
    standardize(d$metadata)
}
