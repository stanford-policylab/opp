library(tidyverse)
library(lubridate)
library(splines)
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
  ...,
  demographic_col = subject_race,
  date_col = date,
  time_col = time,
  lat_col = lat,
  lng_col = lng,
  minority_demographic = "black",
  majority_demographic = "white"
) {
  controlqs <- enquos(...)
  demographicq <- enquo(demographic_col)
  dateq <- enquo(date_col)
  timeq <- enquo(time_col)
  latq = enquo(lat_col)
  lngq = enquo(lng_col)

  print("cleaning data...")
  d <-
    list(
      data = tbl,
      metadata = list()
    ) %>%
    select_and_filter_missing(
      !!!controlqs,
      !!demographicq,
      !!dateq,
      !!timeq,
      !!latq,
      !!lngq
    )

  print("filtering data...")
  tbl <-
    d$data %>%
    # NOTE: prefilter since calculating sunset times can take a while
    filter(
      hour(hms(time)) > 16, # 4 PM
      hour(hms(time)) < 23, # 11 PM
    )

  print("calculating sunset times for data...")
  sunset_times <- calculate_sunset_times(tbl, !!dateq, !!latq, !!lngq)

  print("calculating features for modeling...")
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

  print("training model...")
  model <- train_vod_model(tbl, !!!controlqs)

  print("calculating confidence intervals on coefficients...")
  list(
    metadata = d$metadata,
    results = list(
      data = tbl,
      model = model,
      coefficients = cbind(coef(model), confint(model))
    )
  )
}


train_vod_model <- function(tbl, ...) {
  # TODO(danj): natural spline or polynomial?
  controlqs <- enquos(...)
  fmla <- as.formula(
    str_c(
      c(
        "is_minority_demographic ~ is_dark + ns(twilight_minute, df = 6)",
        quos_names(controlqs)
      ),
      collapse = " + "
    )
  )
  glm(fmla, data = tbl, family = binomial)
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
    mutate(tz = tz_lookup_coords(pull(., !!latq), pull(., !!lngq), warn = F))

  tbl <- 
    tbl %>%
    select(!!dateq, !!latq, !!lngq) %>%
    distinct() %>%
    left_join(tzs) %>%
    mutate(lat = !!latq, lon = !!lngq) %>%
    mutate(
      sunset_utc = getSunlightTimes(data = ., keep = c("sunset"))$sunset
    )

  to_local_time <- function(sunset_utc, tz) {
    format(sunset_utc, "%H:%M:%S", tz = tz)
  }

  tbl$sunset <- unlist(par_pmap(select(tbl, sunset_utc, tz), to_local_time))

  select(tbl, !!dateq, !!latq, !!lngq, sunset)
}
