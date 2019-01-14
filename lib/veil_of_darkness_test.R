library(tidyverse)
library(lubridate)
library(suncalc)
library(lutz)

source("analysis_common.R")


#' Veil of Darkness Test
#'
#' @param tbl a tibble containing the following data
#' @param demographic_col contains a population division of interest, i.e. race,
#'        age group, sex, etc...
#' @param date_col contains date of event
#' @param time_col contains time of event
#' @param lat_col contains latitude of event
#' @param lng_col contains longitude of event
#' @param minority_demographic contains the minority class in demographic_col
#' @param majority_demographic contains the majority class in demographic_col
#' 
#' @return list with \code{results} and \code{metadata} keys
#'
#' @examples
#' veil_of_darkness_test(tbl)
#' veil_of_darkness_test(tbl, subject_age)
#' veil_of_darkness_test(
#'   tbl,
#'   subject_race,
#'   date_col=date
#' )
veil_of_darkness_test <- function(
  tbl,
  demographic_col = subject_race,
  date_col = date,
  time_col = time,
  lat_col = lat,
  lng_col = lng,
  minority_demographic = "black",
  majority_demographic = "white"
) {

  demographicq <- enquo(demographic_col)
  dateq <- enquo(date_col)
  timeq <- enquo(time_col)
  latq = enquo(lat_col)
  lngq = enquo(lng_col)

  d <-
    list(
      data = tbl,
      metadata = list()
    ) %>%
    select_and_filter_missing(
      !!demographicq,
      !!dateq,
      !!timeq,
      !!latq,
      !!lngq
    )

  tz <- infer_tz(pull(tbl, !!latq), pull(tbl, !!lngq))
  minutes_per_hour <- 60
  tbl <- tbl %>%
    # NOTE: prefilter since calculate sunset times takes a while
    filter(
      hour(hms(time)) > 16, # 4 PM
      hour(hms(time)) < 23, # 11 PM
    ) %>%
    mutate(
      sunset = calculate_sunset_times(date, lat, lng, tz),
      minute = hour(hms(time)) * minutes_per_hour + minute(hms(time)),
      sunset_minute = hour(hms(sunset)) * minutes_per_hour + minute(hms(sunset)),
      is_dark = minute > sunset_minute,
      min_sunset_minute = min(sunset_minute),
      max_sunset_minute = max(sunset_minute)
    ) %>%
    filter(
      # NOTE: filter to get only the intertwilight period
      minute >= min_sunset_minute,
      minute <= max_sunset_minute,
      !!demographicq %in% c(minority_demographic, majority_demographic)
    ) %>%
    mutate(
      twilight_minute = minute - min_sunset_minute,
      is_minority_demographic = !!demographicq == minority_demographic
    )

  twilight_minute_poly_degree <- 6
  model = glm(
    is_minority_demographic 
      ~ is_dark + poly(twilight_minute, twilight_minute_poly_degree),
    data = tbl,
    family = binomial
  )
  list(
    metadata = list(
      data = tbl,
      model = model
    ),
    results = list(
      coefficients = list(
        is_dark = coef(model)[2]
      )
    )
  )
}


infer_tz <- function(lats, lngs) {
  sample_idx <- sample.int(length(lats), 10)
  # NOTE: uses 'fast' by default, 'accurate' requires a lot more dependencies,
  # and it doesn't seem to be necessary to be more accurate
  tzs <- suppressWarnings(tz_lookup_coords(lats[sample_idx], lngs[sample_idx]))
  tz <- unique(tzs)
  stopifnot(length(tz) == 1)
  tz
}


calculate_sunset_times <- function(dates, lats, lngs, tz) {
  format(
    getSunlightTimes(
      data = tibble(date = dates, lat = lats, lon = lngs),
      keep = c("sunset"),
      tz = tz
    )$sunset,
    "%H:%M:%S"
  )
}


veil_of_darkness_daylight_savings_test <- function(
  tbl,
  demographic_col = subject_race,
  date_col = date,
  time_col = time,
  latitude_col = lat,
  longitude_col = lng,
  window_size_in_days = 7
) {
  # TODO: filter to window around daylight savings, call veil_of_darkness_test
}
