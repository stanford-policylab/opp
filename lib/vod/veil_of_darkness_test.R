library(tidyverse)
library(lubridate)
library(suncalc)
library(splines)
library(lutz)


#' Veil of Darkness Test
#'
#' @param tbl a tibble containing the data. Must contain the columns: \code{date}, \code{time}, \code{lat},
#' \code{lng}, \code{subject_race}, \code{subgeography}.
#' @param minority_demographic the minority race of interest. Should be a value of \code{subject_race}
#' @param majority_demographic the majority race of interest. Should be a value of \code{subject_race}
#' @param filter_to_DST \code{TRUE} if only the data around the DST changes
#' should be used. Default \code{FALSE}.
#' @param has_geo_control \code{TRUE} if \code{tbl} contains a column
#' \code{geo_control} containing a subgeography to be used as a control in a regression.
#' Default \code{FALSE}.
#' @param has_sunset_times \code{TRUE} if \code{tbl} already contains the 
#' sunset times for all observations, i.e. as returned by \code{add_sunset_times}. Adding
#' sunset times takes a long time for large datasets, so this is a convenience to allow
#' the user to call \code{add_sunset_times} only once and run \code{veil_of_darkness_test} many
#' times on this data. Default \code{FALSE}.
#' @param geofilter_tol A tolerance in degrees of latitude and longitude. Points more than +/-\code{geofilter_tol} 
#' away from the median latitude or longitude of their respective subgeography are dropped. Default 0.5.
#' 
#' @return list containing data, models, and results. Exact list keys depend on \code{filter_to_DST}
#'
#' @examples
#' veil_of_darkness_test(tbl)
#' veil_of_darkness_test(
#'   tbl,
#'   filter_to_DST = TRUE
#' )
veil_of_darkness_test <- function(
  tbl,
  minority_demographic = "black",
  majority_demographic = "white",
  filter_to_DST = FALSE,
  has_geo_control = FALSE,
  has_sunset_times = FALSE,
  geofilter_tol = 0.5
) {
  
  # Add sunset times
  metadata <- list()
  if (!has_sunset_times) {
    tbl <- add_sunset_times(
      tbl, 
      metadata,
      minority_demographic,
      majority_demographic,
      geofilter_tol
    )
  }
  
  # DST Filtering
  if (filter_to_DST) {
    tbl <- 
      tbl %>% 
      filter(is_dst_period == TRUE) %>% 
      mutate(fall = month(date) > 6)
    
    fall_tbl <-
      tbl %>% 
      filter(fall == TRUE)
    
    if (has_geo_control) {
      intertwilight_zone <-
        fall_tbl %>% 
        group_by(geo_control) %>% 
        summarise(dst_min_dusk = min(dusk_minute), dst_max_sunset = max(sunset_minute))
      
      fall_tbl <-
        fall_tbl %>% 
        left_join(intertwilight_zone, by = "geo_control") %>% 
        filter(minute > dst_min_dusk, minute < dst_max_sunset)
    } else {
      intertwilight_zone <-
        fall_tbl %>% 
        group_by(subgeography) %>% 
        summarise(dst_min_dusk = min(dusk_minute), dst_max_sunset = max(sunset_minute))
      
      fall_tbl <-
        fall_tbl %>% 
        left_join(intertwilight_zone, by = "subgeography") %>% 
        filter(minute > dst_min_dusk, minute < dst_max_sunset)
    }
    
    model_time_const <-
      fall_tbl %>%
      glm(
        formula = is_minority_demographic ~ is_dark + ns(minute, df = 6),
        family = "binomial"
      )
    
    model_geo_adjusted <- NULL
    if (has_geo_control) { 
      model_geo_adjusted <-
        fall_tbl %>%
        glm(
          formula = is_minority_demographic ~ is_dark + ns(minute, df = 6) + geo_control,
          family = "binomial"
        )
    }
    
    fall <- 
      list(
        model_time_const = model_time_const,
        model_geo_adjusted = model_geo_adjusted
      )
    
    spring_tbl <-
      tbl %>% 
      filter(fall == FALSE)
    
    if (has_geo_control) {
      intertwilight_zone <-
        spring_tbl %>% 
        group_by(geo_control) %>% 
        summarise(dst_min_dusk = min(dusk_minute), dst_max_sunset = max(sunset_minute))
      
      spring_tbl <-
        spring_tbl %>% 
        left_join(intertwilight_zone, by = "geo_control") %>% 
        filter(minute > dst_min_dusk, minute < dst_max_sunset)
    } else {
      intertwilight_zone <-
        spring_tbl %>% 
        group_by(subgeography) %>% 
        summarise(dst_min_dusk = min(dusk_minute), dst_max_sunset = max(sunset_minute))
      
      spring_tbl <-
        spring_tbl %>% 
        left_join(intertwilight_zone, by = "subgeography") %>% 
        filter(minute > dst_min_dusk, minute < dst_max_sunset)
    }
    
    model_time_const <-
      spring_tbl %>%
      glm(
        formula = is_minority_demographic ~ is_dark + ns(minute, df = 6),
        family = "binomial"
      )
    
    model_geo_adjusted <- NULL
    if (has_geo_control) {
      model_geo_adjusted <-
        spring_tbl %>%
        glm(
          formula = is_minority_demographic ~ is_dark + ns(minute, df = 6) + geo_control,
          family = "binomial"
        )
    }
    
    spring <- 
      list(
        model_time_const = model_time_const,
        model_geo_adjusted = model_geo_adjusted
      )
    
    return(
      list(
        fall_data = fall_tbl,
        spring_data = spring_tbl,
        fall = fall,
        spring = spring
      )
    )
  }
  
  model_time_const <-
    tbl %>%
    glm(
      formula = is_minority_demographic ~ is_dark + ns(minute, df = 6),
      family = "binomial"
    )

  model_geo_adjusted <- NULL
  if (has_geo_control) {
    model_geo_adjusted <-
      tbl %>%
      glm(
        formula = is_minority_demographic ~ is_dark + ns(minute, df = 6) + geo_control,
        family = "binomial"
      )
    
    model_month_adjusted <-
      tbl %>%
      mutate(month = factor(month(date))) %>% 
      glm(
        formula = is_minority_demographic ~ is_dark + ns(minute, df = 6) + geo_control + month,
        family = "binomial"
      )
  } else {
    model_month_adjusted <-
      tbl %>%
      mutate(month = factor(month(date))) %>% 
      glm(
        formula = is_minority_demographic ~ is_dark + ns(minute, df = 6) + month,
        family = "binomial"
      )
  }
  
  if (has_geo_control) {
    results <-
      tribble(
        ~controls,                            ~coefficient,                  ~se,
        "Clock time",                         coef(model_time_const)[2],     coef(summary(model_time_const))[2, 2],
        "Clock time and Subgeography",        coef(model_geo_adjusted)[2],   coef(summary(model_geo_adjusted))[2,2],
        "Clock time, Month and Subgeography", coef(model_month_adjusted)[2], coef(summary(model_month_adjusted))[2,2]
      )
  } else {
    results <-
      tribble(
        ~controls,              ~coefficient,                  ~se,
        "Clock time",           coef(model_time_const)[2],     coef(summary(model_time_const))[2, 2],
        "Clock time and Month", coef(model_month_adjusted)[2], coef(summary(model_month_adjusted))[2,2]
      )
  }

  list(
    data = tbl,
    models = list(
      model_time_const = model_time_const,
      model_geo_adjusted = model_geo_adjusted,
      model_month_adjusted = model_month_adjusted
    ),
    results = results
  )
}

# Convenience function to load data and add sunset times
load_sunset_data <- function(state, city) {
  opp_load_data(state, city) %>%
    add_sunset_times(metadata = list(), multi_tz = FALSE)
}

# Calculate the k as defined in Grogger & Ridgeway:
#    P(minority | light) / P(minority | dark) * 
#              P(majority | dark) / P(majority | light)
calculate_k <- function(tbl)
{
  summary <-
    tbl %>%
    count(is_minority_demographic, is_dark) %>%
    group_by(is_dark) %>%
    mutate(prop = n / sum(n))
  
  prop_minority_dark <- 
    summary %>% 
    filter(is_minority_demographic == TRUE, is_dark == TRUE) %>% 
    pull(prop)
  
  prop_minority_light <- 
    summary %>% 
    filter(is_minority_demographic == TRUE, is_dark == FALSE) %>% 
    pull(prop)
  
  prop_majority_dark <- 
    summary %>% 
    filter(is_minority_demographic == FALSE, is_dark == TRUE) %>% 
    pull(prop)
  
  prop_majority_light <- 
    summary %>% 
    filter(is_minority_demographic == FALSE, is_dark == FALSE) %>% 
    pull(prop)
  
  k_unadj <- (prop_minority_light * prop_majority_dark) /
    (prop_majority_light * prop_minority_dark)
  
  k_unadj
}

#' Add Sunset Times
#'
#' @param tbl a tibble containing the data. Must contain the columns: \code{date}, \code{time}, \code{lat},
#' \code{lng}, \code{subject_race}, \code{subgeography}.
#' @param minority_demographic the minority race of interest. Should be a value of \code{subject_race}
#' @param majority_demographic the majority race of interest. Should be a value of \code{subject_race}
#' @param filter_to_DST \code{TRUE} if only the data around the DST changes
#' should be used. Default \code{FALSE}.
#' @param geofilter_tol A tolerance in degrees of latitude and longitude. Points more than +/-\code{geofilter_tol} 
#' away from the median latitude or longitude of their respective subgeography are dropped. Default 0.5.
#' @param multi_tz \code{TRUE} if \code{tbl} contains data from multiple timezones. Default \code{FALSE}
#' 
#' @return \code{tbl} with sunset and dusk times and related variables, filtered to only stops
#' occurring in the intertwilight period, defined as the period between the earliest
#' dusk and the latest sunset. Rows with \code{NA} values for \code{subject_race}, \code{date} or
#' \code{time} are dropped.
#'
#' @examples
#' add_sunset_times(tbl, list())
#' 
#' metadata = list()
#' add_sunset_times(tbl, metadata, multi_tz = TRUE)
add_sunset_times <- function(
  tbl,
  metadata,
  minority_demographic = "black",
  majority_demographic = "white",
  geofilter_tol = 0.5
) {
  # Drop NAs
  tbl <- clean(
    tbl,
    subject_race,
    date,
    time,
    geofilter_tol = geofilter_tol,
    metadata = metadata
  )
  
  # Add timezone & sunset times
  tzs <-
    tbl %>% 
    distinct(subgeography) %>% 
    pull(subgeography) %>% 
    map_dfr(., ~infer_tz_by_group(tbl, .))
  tbl <-
    left_join(tbl, tzs, by = "subgeography")
  
  sunset_times <-
    tbl %>% 
    distinct(subgeography) %>% 
    pull(subgeography) %>% 
    map_dfr(., ~infer_sunset_times_by_group(tbl, .))
  tbl <-
    left_join(tbl, sunset_times, by = c("subgeography", "date", "tz"))
  
  minutes_per_hour <- 60
  tbl <-
    tbl %>%
    mutate(
      minute = hour(hms(time)) * minutes_per_hour + minute(hms(time)),
      sunset_minute = hour(hms(sunset)) * minutes_per_hour + minute(hms(sunset)),
      dusk_minute = hour(hms(dusk)) * minutes_per_hour + minute(hms(dusk)),
      is_dark = minute > dusk_minute
    )
  
  intertwilight <-
    tbl %>% 
    group_by(subgeography) %>% 
    summarise(
      min_dusk_minute = min(dusk_minute),
      max_sunset_minute = max(sunset_minute)
    )
  
  tbl %>% 
    left_join(intertwilight, by = "subgeography") %>% 
    filter(
      # Filter to the intertwilight period
      minute > min_dusk_minute,
      minute < max_sunset_minute,
      (minute < sunset_minute | minute > dusk_minute),
      subject_race %in% c(minority_demographic, majority_demographic)
    ) %>%
    mutate(
      twilight_minute = minute - min_dusk_minute,
      minutes_since_dark = minute - sunset_minute,
      is_minority_demographic = subject_race == minority_demographic,
      month = month(date),
      day = day(date),
      is_dst = dst(as.POSIXct(date, tz = tz)),
      is_dst_period =  dst(as.POSIXct(date + days(14), tz = tz)) != is_dst | 
        dst(as.POSIXct(date - days(14), tz = tz)) != is_dst
    )
}

# Drops NA values and geographic outliers
clean <- function(
  tbl,
  ...,
  geofilter_tol = 0.5,
  metadata = list()
) {
  drop_vars = quos(...)

  n_before_drop_na <- nrow(tbl)
  tbl <- drop_na(tbl, lat, lng, !!!drop_vars)
  n_after_drop_na <- nrow(tbl)
  metadata["null_rate"] <-
    (n_before_drop_na - n_after_drop_na) / n_before_drop_na
  if (metadata[["null_rate"]] > 0) {
    rate_warning(metadata[["null_rate"]], "dropped due to missing values")
  }
  
  # TODO - Fix this!! More specific
  n_before_filter_geo <- nrow(tbl)
  med_lat_lng <-
    tbl %>% 
    group_by(subgeography) %>% 
    summarise(
      median_lat = median(lat),
      median_lng = median(lng)
    )
  
  tbl <- 
    tbl %>% 
    left_join(med_lat_lng, by = "subgeography") %>% 
    filter(
      lat < median_lat + geofilter_tol,
      lat > median_lat - geofilter_tol,
      lng <  median_lng + geofilter_tol,
      lng >  median_lng - geofilter_tol
    )
  n_after_filter_geo <- nrow(tbl)
  metadata["geo_error_rate"] <-
    (n_before_filter_geo - n_after_filter_geo) / n_before_drop_na
  if (metadata[["geo_error_rate"]] > 0) {
    rate_warning(metadata[["geo_error_rate"]], "dropped due to possible geocoding error")
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

# Infers the timzone for the subgeography subgeo_name
infer_tz_by_group <- function(tbl, subgeo_name, n = 10) 
{
  lats <- 
    tbl %>% 
    filter(subgeography == subgeo_name) %>% 
    pull(lat)
  
  lngs <- 
    tbl %>% 
    filter(subgeography == subgeo_name) %>% 
    pull(lng)
  
  print(str_c("Inferring TZ for ", subgeo_name))
  tibble(
    subgeography = subgeo_name,
    tz = infer_tz(lats, lngs, n)
  )
}

# Infer timezone from a sample of latitudes and longitudes
# MUST BE FROM ONLY ONE TIMEZONE
infer_tz <- function(lats, lngs, n = 10) {
  sample_idx <- sample.int(length(lats), min(n, length(lats)))
  # NOTE: uses 'fast' by default, 'accurate' requires a lot more dependencies,
  # and it doesn't seem to be necessary to be more accurate
  tzs <- suppressWarnings(tz_lookup_coords(lats[sample_idx], lngs[sample_idx]))
  tz <- unique(tzs)
  if (length(tz) != 1) {print(tz)}
  stopifnot(length(tz) == 1)
  tz
}

# Infer sunset times for subgeography subgeo_name
infer_sunset_times_by_group <- function(tbl, subgeo_name) 
{
  tbl <- 
    tbl %>% 
    filter(subgeography == subgeo_name)
  
  print(str_c("Inferring sunset times for ", subgeo_name))
  infer_sunset_times(tbl)
}

# Infer sunset times at median latitude and longitude of subgeographies
# for each date.
infer_sunset_times <- function(tbl) 
{
  tbl %>% 
    group_by(date, tz, subgeography) %>% 
    summarise(
      med_lat = median(lat),
      med_lng = median(lng)
    ) %>% 
    rowwise() %>% 
    mutate(
      sunset = calculate_sunset_times(date, med_lat, med_lng, tz),
      dusk = calculate_dusk_times(date, med_lat, med_lng, tz)
    ) %>% 
    select(-med_lat, -med_lng)
}

# wrapper around suncalc::getSunsetTimes to get sunset time
# as a character string
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

# wrapper around suncalc::getSunsetTimes to get dusk time
# as a character string
calculate_dusk_times <- function(dates, lats, lngs, tz) {
  format(
    getSunlightTimes(
      data = tibble(date = dates, lat = lats, lon = lngs),
      keep = c("dusk"),
      tz = tz
    )$dusk,
    "%H:%M:%S"
  )
}

# Produce the plot of proportion minority by time relative to sunset
# controlling for clock time
plot_prop_minority_by_time <- function(
    tbl,
    min_clock_time = hms::hms(hours = 17, min = 30),
    max_clock_time = hms::hms(hours = 19, min = 45),
    title = "",
    subtitle = "",
    DST_only = FALSE,
    city_only = NULL,
    smooth_method = "loess",
    time_range = list(low = -90, high = 90), # minutes
    time_accuracy = 15 # minutes
) {
  minutes_per_hour <- 60
  
  if(DST_only) {
    tbl <- filter(tbl, is_dst_period == TRUE)
  }
  
  if(!is.null(city_only)) {
    tbl <- filter(tbl, city == city_only)
  }
  
  plot_data <-
    tbl %>% 
    filter(
      time >= min_clock_time,
      time < max_clock_time,
      minutes_since_dark < time_range$high + time_accuracy,
      minutes_since_dark >= time_range$low,
      minutes_since_dark < 0 | minutes_since_dark >= 30
    ) %>% 
    mutate(
      min_since_sunset_bin = minutes_since_dark %/% time_accuracy * time_accuracy,
      clock_time = hms::hms(min = minute - 12 * 60),
      clock_time_bin = case_when(
        clock_time < hms::hms(hours = 5, min = 45) ~ "5:30-5:44",
        clock_time < hms::hms(hours = 6, min = 00) ~ "5:45-5:59",
        clock_time < hms::hms(hours = 6, min = 15) ~ "6:00-6:14",
        clock_time < hms::hms(hours = 6, min = 30) ~ "6:15-6:29",
        clock_time < hms::hms(hours = 6, min = 45) ~ "6:30-6:44",
        clock_time < hms::hms(hours = 7, min = 00) ~ "6:45-6:59",
        clock_time < hms::hms(hours = 7, min = 15) ~ "7:00-7:14",
        clock_time < hms::hms(hours = 7, min = 30) ~ "7:15-7:29",
        TRUE ~ "7:30-7:45"
      )
    ) %>% 
    group_by(min_since_sunset_bin, clock_time_bin) %>% 
    summarise(prop_minority = sum(is_minority_demographic) / n(), total = n())
  
  plot_data %>% 
    mutate(is_dark = min_since_sunset_bin > 0) %>% 
    unite(smooth_group, is_dark, clock_time_bin, remove = FALSE) %>% 
    ggplot(aes(min_since_sunset_bin, prop_minority, color = clock_time_bin)) +
    geom_vline(xintercept = 0) +
    geom_smooth(method = smooth_method, se = FALSE) +
    scale_x_continuous(
      breaks = seq(
        time_range$low,
        time_range$high,
        by = 30
      ),
      limits = c(time_range$low, time_range$high)
    ) +
    scale_y_continuous(labels = scales::percent_format()) +
    labs(
      title = title,
      subtitle = subtitle,
      x = "Minutes since sunset",
      y = "Percentage Minority Drivers",
      color = "Clock Time (PM)"
    )
}

