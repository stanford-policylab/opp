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
  latitude_col = lat,
  longitude_col = lng
) {
  # TODO(danj):
  # get timezone from lat/long
  # get sunset time from maptools::sunriset
  # filter data to get data between min and max sunset times
  demographic_colq <- enquo(demographic_col)
  date_colq <- enquo(date_col)
  time_colq <- enquo(date_colq)
  latitude_colq = enquo(latitude_colq)
  longitude_colq = enquo(longitude_colq)
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
  # TODO: filter to window around
}
