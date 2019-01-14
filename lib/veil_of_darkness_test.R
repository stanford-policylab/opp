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

  tbl <-
    d$data %>%
    # NOTE: prefilter since calculating sunset times can take a while
    filter(
      hour(hms(time)) > 16, # 4 PM
      hour(hms(time)) < 23, # 11 PM
    )

  sunset_times <- calculate_sunset_times(tbl, !!dateq, !!latq, !!lngq)

  tbl <-
    tbl %>%
    left_join(
      sunset_times
    ) %>%
    mutate(
      minute = hour(hms(time)) * 60 + minute(hms(time)),
      sunset_minute = hour(hms(sunset)) * 60 + minute(hms(sunset)),
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

  model <- glm(
    is_minority_demographic ~ is_dark + poly(twilight_minute, 6),
    data = tbl,
    family = binomial
  )

  list(
    metadata = d$metadata,
    results = list(
      data = tbl,
      model = model,
      coefficients = list(
        is_dark = coef(model)[2]
      )
    )
  )
}


calculate_sunset_times <- function(
  tbl,
  date_col = date,
  lat_col = lat,
  lng_col = lng
) {

  dateq <- enquo(date_col)
  latq <- enquo(lat_col)
  lngq <- enquo(lng_col)

  tzs <-
    tbl %>%
    select(!!latq, !!lngq) %>%
    distinct() %>%
    # NOTE: Warning is about using 'fast' by default; 'accurate' requires
    # more dependencies and it doesn't seem necessary
    mutate(tz = tz_lookup_coords(pull(., !!latq), pull(., !!lngq)))

  tbl %>%
  select(!!dateq, !!latq, !!lngq) %>%
  distinct() %>%
  left_join(tzs) %>%
  mutate(lon = !!lngq) %>%
  mutate(
    sunset = format(
      getSunlightTimes(data = ., keep = c("sunset"), tz = tz)$sunset,
      "%H:%M:%S"
    )
  )
}
