library(tidyverse)
library(suncalc)
library(lutz)


#' Veil of Darkness Test
#'
#' @param tbl a tibble containing the following data
#' @param ... additional attributes to control for when conducting test
#'            i.e. county, precinct, police department, etc...
#' @param demographic_col contains a population division of interest, i.e. race,
#'        age group, sex, etc...
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
  lng_col = lng
) {

  demographicq <- enquo(demographic_col)
  dateq <- enquo(date_col)
  timeq <- enquo(time_col)
  latq = enquo(lat_col)
  lngq = enquo(lng_col)

  metadata <- list()

  tbl <- clean(
    tbl,
    !!demographicq,
    !!dateq,
    !!timeq,
    !!latq,
    !!lngq,
    metadata
  )

  # TODO(danj):
  # black ~ is_dark + ploy(minute, 6)
  tz <- infer_tz(pull(tbl, !!latq), pull(tbl, !!lngq))
  tbl <-
    tbl %>%
    mutate(sunset = calculate_sunset_times(date, lat, lng, tz))
    # filter(
    #   as.duration(hms(time)) >= min(as.duration(hms(sunset))),
    #   as.duration(hms(time)) <= max(as.duration(hms(sunset))),
    # )
    # mutate(
    #   is_dark = time > sunset,
    #   minute = as.numeric(as.duration(hms(time) - hms(min(sunset))), "minutes")
    # )
  tbl
}

clean <- function(
  tbl,
  demographic_col,
  date_col,
  time_col,
  lat_col,
  lng_col,
  metadata
) {
  demographicq <- enquo(demographic_col)
  dateq <- enquo(date_col)
  timeq <- enquo(time_col)
  latq = enquo(lat_col)
  lngq = enquo(lng_col)

  tbl <- select(tbl, !!demographicq, !!dateq, !!timeq, !!latq, !!lngq)
  n_before_drop_na <- nrow(tbl)
  tbl <- drop_na(tbl)
  n_after_drop_na <- nrow(tbl)
  metadata["null_rate"] <-
    (n_before_drop_na - n_after_drop_na) / n_before_drop_na
  if (metadata[["null_rate"]] > 0) {
    rate_warning(metadata[["null_rate"]], "dropped due to missing values")
  }
  tbl
}


rate_warning <- function(rate, message) {
  warning(
    str_c(
      formatC(100 * rate, format = "f", digits = 2), 
      "% of the data ",
      message
    ),
    call. = FALSE
  )
}

infer_tz <- function(lats, lngs) {
  sample_idx <- sample.int(length(lats), 10)
  tz <- unique(tz_lookup_coords(lats[sample_idx], lngs[sample_idx]))
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
  # TODO: filter to window around, call veil_of_darkness_test
}
