library(dplyr)

source("lib/standards.R")
source("lib/sanitizers.R")


standardize <- function(tbl) {
  # NOTE: rows that were merged will likley have some values coerced to NA when
  # types are enforced. For instance, let's say a car was stopped with 2 people
  # ages 18 and 22, with a row per person for that stop. If those rows are
  # merged, the age value in that record will be 18<sep>22; when age is later
  # coerced to an integer type, this value will be coerced to NA; typically,
  # this is what you want unless you have some logic for selecting one value
  # over another; if that's the case, a new column should be created that
  # reflects that choice
  tbl %>%
    add_missing_required %>%
    enforce_types %>%
    sanitize %>%
    select_required_first
}


add_missing_required <- function(tbl) {
  print("adding missing required columns...")
  for (name in names(required_schema)) {
    if (!(name %in% colnames(tbl))) {
      tbl[[name]] = NA
    }
  }
  tbl
}


enforce_types <- function(tbl) {
  print("enforcing standard types...")
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


sanitize <- function(tbl) {
  print("sanitizing...")
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


select_required_first <- function(tbl) {
  print("selecting required columns first...")
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
