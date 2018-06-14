source("standards.R")


# NOTE: for obscure reasons, NA must be "typed" or it sometimes causes the data
# to fall apart, i.e. dates will revert to POSIX integers
enforce_bounds <- function(val, start, end, fill) {
  # NOTE: standard ifelse loses the datatype, i.e. Dates will become numeric
  if_else(val < start | val > end, fill, val)
}


sanitize_date <- function(val) {
  enforce_bounds(
    val,
    valid_start_date,
    valid_end_date,
    as.Date(NA)
  )
}


sanitize_dob <- function(val) {
  enforce_bounds(
    val,
    valid_dob_start_date,
    valid_dob_end_date,
    as.Date(NA)
  )
}


sanitize_yob <- function(val) {
  enforce_bounds(
    val,
    valid_yob_start,
    valid_yob_end,
    as.integer(NA)
  )
}


sanitize_age <- function(val) {
  enforce_bounds(
    val,
    valid_age_start,
    valid_age_end,
    as.numeric(NA)
  )
}


sanitize_vehicle_year <- function(val) {
  enforce_bounds(
    val,
    valid_vehicle_start_year,
    valid_vehicle_end_year,
    as.integer(NA)
  )
}
