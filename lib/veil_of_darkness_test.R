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
  lat_col = center_lat,
  lng_col = center_lng,
  minority_demographic = "black",
  majority_demographic = "white",
  spline_degree = 6,
  interact = T,
  plot = F
) {
  control_colqs <- enquos(...)
  demographic_colq <- enquo(demographic_col)
  date_colq <- enquo(date_col)
  time_colq <- enquo(time_col)
  lat_colq = enquo(lat_col)
  lng_colq = enquo(lng_col)


  print("preparing data...")
  d <- prepare_vod_data(
      tbl,
      !!!control_colqs,
      demographic_col = !!demographic_colq,
      date_col = !!date_colq,
      time_col = !!time_colq,
      lat_col = !!lat_colq,
      lng_col = !!lng_colq,
      minority_demographic = minority_demographic,
      majority_demographic = majority_demographic
  )
  
  print("training model...")
  model <- train_vod_model(
      d$data,
      !!!control_colqs,
      demographic_indicator_col = is_minority_demographic,
      darkness_indicator_col = is_dark,
      time_col = rounded_minute,
      degree = spline_degree,
      interact = interact
  )
   

  plots <- list()
  if (plot) {
    print("composing plots...")
    plots <- compose_vod_plots(d$data)
  }

  list(
    metadata = d$metadata,
    results = list(data = d$data, model = model),
    plots = plots
  )
}


prepare_vod_data <- function(
  tbl,
  ...,
  demographic_col = subject_race,
  date_col = date,
  time_col = time,
  lat_col = center_lat,
  lng_col = center_lng,
  minority_demographic = "black",
  majority_demographic = "white"
) {
  control_colqs <- enquos(...)
  demographic_colq <- enquo(demographic_col)
  date_colq <- enquo(date_col)
  time_colq <- enquo(time_col)
  lat_colq = enquo(lat_col)
  lng_colq = enquo(lng_col)

  d <-
    list(
      data = tbl,
      metadata = list()
    ) %>%
    select_and_filter_missing(
      !!!control_colqs,
      !!demographic_colq,
      !!date_colq,
      !!time_colq,
      !!lat_colq,
      !!lng_colq
    )

  # NOTE: prefilter since calculating sunset times can take a while
  tbl <-
    d$data %>%
    filter(
      hour(hms(time)) > 15, # 3 PM
      hour(hms(time)) < 22, # 10 PM
      !!demographic_colq %in% c(minority_demographic, majority_demographic)
    )

  sunset_times <- calculate_sunset_times(
    tbl,
    !!date_colq,
    !!lat_colq,
    !!lng_colq
  )

  d$data <-
    tbl %>%
    left_join(
      sunset_times
    ) %>%
    mutate(
      minute = time_to_minute(time),
      pre_sunset_minute = time_to_minute(pre_sunset),
      sunset_minute = time_to_minute(sunset),
      is_dark = minute >= sunset_minute,
      min_sunset_minute = min(sunset_minute),
      max_sunset_minute = max(sunset_minute)
    ) %>%
    filter(
      # NOTE: filter to get only the intertwilight period
      minute >= min_sunset_minute,
      minute <= max_sunset_minute,
      # NOTE: remove the ~30min ambiguously lit period between sunset and dusk
      !(minute > pre_sunset_minute & minute < sunset_minute)
    ) %>%
    mutate(
      is_minority_demographic = !!demographic_colq == minority_demographic,
      rounded_minute = plyr::round_any(minute, 5)
    )
  d 
}


calculate_sunset_times <- function(
  tbl,
  date_col = date,
  lat_col = center_lat,
  lng_col = center_lng
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
      sunset_utc = getSunlightTimes(data = ., keep = c("sunset"))$sunset,
      date = ymd(str_sub(!!dateq, 1, 10))
    ) %>% 
    mutate(
      dusk_utc = getSunlightTimes(data = ., keep = c("dusk"))$dusk,
      date = ymd(str_sub(!!dateq, 1, 10))
    )
  
  to_local_time <- function(sunset_utc, tz) {
    format(sunset_utc, "%H:%M:%S", tz = tz)
  }

  tbl$pre_sunset <- unlist(map2(tbl$sunset_utc, tbl$tz, to_local_time))
  tbl$sunset <- unlist(map2(tbl$dusk_utc, tbl$tz, to_local_time))

  tbl %>% 
    select(date, !!latq, !!lngq, pre_sunset, sunset)
}


time_to_minute <- function(time) {
  hour(hms(time)) * 60 + minute(hms(time))
}


train_vod_model <- function(
  tbl,
  ...,
  demographic_indicator_col = is_minority_demographic,
  darkness_indicator_col = is_dark,
  time_col = rounded_minute,
  degree = 6,
  interact = T
) {
  control_colqs <- enquos(...)
  darkness_indicator_colq <- enquo(darkness_indicator_col)
  demographic_indicator_colq <- enquo(demographic_indicator_col)
  time_colq <- enquo(time_col)

  agg <-
    tbl %>%
    group_by(
      !!darkness_indicator_colq,
      !!time_colq,
      !!!control_colqs
    ) %>%
    summarize(
      n = n(),
      n_minority = sum(!!demographic_indicator_colq),
      n_majority = n - n_minority
    )

  fmla <- as.formula(
    str_c(
      "cbind(n_minority, n_majority) ~ ",
      quo_name(darkness_indicator_colq),
      " + ",
      str_c(
        str_c("ns(", quo_name(time_colq), ", df = ", degree, ")"),
        quos_names(control_colqs),
        sep = if (interact) "*" else " + "
      )
    )
  )
  glm(fmla, data = agg, family = binomial, control = list(maxit = 100))
}


compose_vod_plots <- function(tbl, geo_col = city_state) {
  geo_colq <- enquo(geo_col)
  geo_colname <- quo_name(geo_colq)
  # NOTE: limit time to 5:45 PM to 7:15 PM since data is sparse outside this
  # window; i.e. for a 5:45 PM sunset, there are relatively fewer data points
  # for days when the sunsets before 5:45 PM relative to after 5:45 PM; the
  # reverse is true for a 7:15 PM sunset. So, limit the times to between these
  # values; in fact, 7 minutes before and 7 minutes after since each 15-minute
  # group is composed of 7 minutes before + midpoint (15-minute mark) + 7
  # minutes after
  tbl <- filter(tbl, time >= hm("17:38"), time <= hm("19:22"))
  bind_rows(
    # NOTE: controlling for time every 15 minutes
    mutate(
      tbl,
      quarter_hour = to_quarter_hour(date, time),
      quarter_hour_minute = time_to_minute(quarter_hour),
      quarter_hour_minute_since_sunset = quarter_hour_minute - sunset_minute,
      quarter_hour_readable = str_c(
          hour(hms(quarter_hour)) - 12,
          ':',
          str_pad(minute(hms(quarter_hour)), 2, side = "right", pad = "0"),
          " PM"
      )
    ),
    # NOTE: aggregate for comparison
    mutate(
      tbl,
      quarter_hour_minute_since_sunset = minute - sunset_minute,
      quarter_hour_readable = "aggregated"
    )
  ) %>%
  group_by(
    !!geo_colq,
    quarter_hour_readable,
    quarter_hour_minute_since_sunset
  ) %>%
  summarize(
    minority_total = sum(is_minority_demographic),
    majority_total = sum(!is_minority_demographic),
    proportion_minority = minority_total / (minority_total + majority_total)
  ) %>%
  group_by(!!geo_colq) %>%
  do(
    plot = 
      ggplot(
        .,
        aes(
          x = quarter_hour_minute_since_sunset,
          y = proportion_minority,
          # NOTE: color and linetype need to be mapped to quarter_hour_readable
          # in order to set scale_linetype_manual later
          color = quarter_hour_readable,
          linetype = quarter_hour_readable
        )
      ) +
      geom_smooth(method = "lm", se = F) +
      scale_linetype_manual(values = c(rep("solid", 7), "dashed")) +
      xlab("Minutes Since Sunset") +
      ylab("Proportion Minority") +
      coord_cartesian(xlim = c(-60, 60)) +
      theme(legend.title = element_blank()) +
      ggtitle(unique(pull(., !!geo_colq)))
  ) %>%
  translator_from_tbl(
    geo_colname,
    "plot"
  )
}


to_quarter_hour <- function(date, time) {
  format(
    round_date(ymd_hms(str_c(date, time, sep = " ")), "15 min"),
    "%H:%M:%S"
  )
}
