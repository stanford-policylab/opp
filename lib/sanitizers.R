library(tidyverse)


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


sanitize_dob_func <- function(dates) {
  function(v) {
    enforce_bounds(
      v,
      dates - years(valid_age_end),
      dates - years(valid_age_start),
      as.Date(NA)
    )
  }
}


sanitize_age <- function(val) {
  enforce_bounds(
    val,
    valid_age_start,
    valid_age_end,
    as.numeric(NA)
  )
}


sanitize_vehicle_year_func <- function(dates) {
  function(v) {
    enforce_bounds(
      v,
      valid_vehicle_start_year,
      # NOTE: sometimes you can get a new car that is "next year's model"
      dates + years(1),
      as.integer(NA)
    )
  }
}


sanitize_speed <- function(v) {
  if_else(v <= 0, NA_real_, v)
}


sanitize_digits <- function(val) {
  str_replace_all(val, "\\d", "-")
}
