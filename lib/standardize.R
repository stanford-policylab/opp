library(dplyr)

source("lib/standards.R")
source("lib/sanitizers.R")


standardize <- function(tbl) {
  tbl %>%
    add_missing_required %>%
    sanitize %>%
    enforce_types %>%
    select_required_first
}


add_missing_required <- function(tbl) {
  print("add missing required")
  for (name in names(required_schema)) {
    if (!(name %in% colnames(tbl))) {
      tbl[[name]] = NA
    }
  }
  tbl
}


sanitize <- function(tbl) {
  print("sanitizing")
  # required
  tbl <- mutate(tbl,
    incident_date = sanitize_incident_date(incident_date)
  )
  # optional
  for (col in colnames(tbl)) {
    if (endsWith(col, "dob")) {
      tbl[[col]] <- sanitize_dob(tbl[[col]])
    }
    if (endsWith(col, "age")) {
      tbl[[col]] <- sanitize_age(tbl[[col]])
    }
    if (endsWith(col, "yob")) {
      tbl[[col]] <- sanitize_yob(tbl[[col]])
    }
    if (col == "vehicle_year") {
      tbl[[col]] <- sanitize_vehicle_year(tbl[[col]])
    }
  }
  tbl
}


enforce_types <- function(tbl) {
  print("enforcing types")
  for (name in names(required_schema)) {
    tbl[[name]] <- required_schema[[name]](tbl[[name]])
  }
  for (name in names(extra_schema)) {
    if (name %in% colnames(tbl)) {
      tbl[[name]] <- extra_schema[[name]](tbl[[name]])
    }
  }
  tbl
}


select_required_first <- function(tbl) {
  print("selecting required first")
  select(tbl,
    incident_id,
    incident_type,
    incident_date,
    incident_time,
    incident_location,
    incident_lat,
    incident_lng,
    subject_race,
    reason_for_stop,
    search_conducted,
    search_type,
    contraband_found,
    arrest_made,
    citation_issued,
    everything()
  )
}
