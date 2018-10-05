library(tidyverse)
#library(suncalc)


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
  time_colq <- enquo(time_col)
  latitude_colq = enquo(latitude_col)
  longitude_colq = enquo(longitude_col)
  
  n_sec_day <- 24 * 60 * 60
  
  tbl <-
    tbl %>% 
    mutate(
      sunset = hms::hms(get_sunset_frac(
        !!latitude_colq, 
        !!longitude_colq, 
        as.POSIXct(str_c(!!date_colq, !!time_colq))
      ) * n_sec_day),
      dark = time > sunset
    ) %>% 
    filter(
      time > min(sunset),
      time < max(sunset)
    )
  
  proportion_black <-
    df %>% 
    mutate(black = !!demographic_colq == "black") %>% 
    count(black, dark) %>% 
    group_by(dark) %>% 
    mutate(prop = n / sum(n))
  
  #calculate k
}

n_sec_day <- 24 * 60 * 60

testsf_wsunset <-
  testsf %>% 
  mutate(
    sunset = hms::hms(get_sunset_frac(
      lat, 
      lng, 
      as.POSIXct(str_c(date, time))
    ) * n_sec_day)
  )

min(testsf_wsunset$sunset)
summary(testsf_wsunset)

prop <- testsf_wsunset %>% 
  mutate(
    dark = time > sunset,
    black = subject_race == "black"
  ) %>% 
  filter(
    time > min(sunset),
    time < max(sunset)
  ) %>% 
  count(dark, black) %>% 
  group_by(dark) %>% 
  mutate(prop = n / sum(n))

k <- (prop %>% filter(black == TRUE, dark == FALSE) %>% pull(prop) * 
  prop %>% filter(black == FALSE, dark == TRUE) %>%  pull(prop)) / 
  (prop %>% filter(black == FALSE, dark == FALSE) %>% pull(prop) *
     prop %>% filter(black == TRUE, dark == TRUE) %>% pull(prop))

kget_sunset_frac <- function(
  lat, 
  lng, 
  datetime
) {
  crds <- as.matrix(data.frame(lng, lat))
  sunriset(crds, datetime, direction = "sunset")
}
