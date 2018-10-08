library(tidyverse)
#library(suncalc)
library(splines)


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
  
  tbl_intertwilight <-
    tbl %>% 
    drop_na(
      !!demographic_colq,
      !!date_colq,
      !!time_colq,
      !!latitude_colq,
      !!longitude_colq
    ) %>% 
    mutate(
      sunset = hms::hms(get_sunset_frac(
        !!latitude_colq, 
        !!longitude_colq, 
        as.POSIXct(str_c(!!date_colq, !!time_colq))
      ) * n_sec_day),
      dark = time > sunset,
      black = !!demographic_colq == "black"
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
  
  k_unadj <- (prob_given_bd(proportion_black, TRUE, FALSE) * 
          prob_given_bd(proportion_black, FALSE, TRUE)) / 
    (prob_given_bd(proportion_black, FALSE, FALSE) *
       prob_given_bd(proportion_black, TRUE, TRUE))
  
  model_time_const <- 
    tbl_intertwilight %>% 
    glm(formula = black ~ dark + ns(time, df = 6), 
        family = "binomial")
  
  model_time_varying <-
    tbl_intertwilight %>% 
    glm(formula = black ~ dark * ns(time, df = 6), 
        family = "binomial")
  
  model_district_adj <-
    tbl_intertwilight %>% 
    glm(formula = black ~ dark + ns(time, df = 6) + district, 
        family = "binomial")
}

n_sec_day <- 24 * 60 * 60

testsf_wsunset <-
  testsf %>% 
  filter(!is.na(lat), !is.na(lng), !is.na(date), !is.na(time)) %>% 
  mutate(
    sunset = hms::hms(get_sunset_frac(
      lat, 
      lng, 
      as.POSIXct(str_c(date, time))
    ) * n_sec_day)
  )

min(testsf_wsunset$sunset)
summary(testsf_wsunset)

testdata <-
  testsf_wsunset %>% 
  mutate(
    dark = time > sunset,
    black = subject_race == "black"
  ) %>% 
  filter(
    time > min(sunset),
    time < max(sunset)
  )

model <-
  testdata %>% 
  glm(formula = black ~ dark * ns(time, df = 6), family = "binomial")

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

# Returns the sunset time at the given latitude and longitude
# and date/time as a fraction of the day
get_sunset_frac <- function(
  lat, 
  lng, 
  datetime
) {
  crds <- as.matrix(data.frame(lng, lat))
  maptools::sunriset(crds, datetime, direction = "sunset")
}

# todo - generalize
prob_given_bd <- function(data, black, dark) {
  data %>% 
    filter(black == black, dark == dark) %>% 
    pull(prop)
}
