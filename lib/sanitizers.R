source("lib/standards.R")


sanitize_incident_date <- function(val) {
  sanitize_date(val, valid_incident_start_date, valid_incident_end_date)
}


sanitize_date <- function(val, start, end) {
  out_of_bounds_to(val, start, end, as.Date(NA))
}


out_of_bounds_to <- function(val, start, end, fill) {
  if_else(val < start | val > end, fill, val)
}


sanitize_dob <- function(val) {
  sanitize_date(val, valid_dob_start_date, valid_dob_end_date)
}


sanitize_yob <- function(val) {
  out_of_bounds_to(val, valid_yob_start, valid_yob_end, as.integer(NA))
}


sanitize_age <- function(val) {
  out_of_bounds_to(val, valid_age_start, valid_age_end, as.numeric(NA))
}


sanitize_vehicle_year <- function(val) {
  out_of_bounds_to(val,
                   valid_vehicle_start_year,
                   valid_vehicle_end_year,
                   as.integer(NA))
}
