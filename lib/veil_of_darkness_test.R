library(tidyverse)
library(lubridate)
library(suncalc)
library(splines)
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
  minority_demographic = "black",
  majority_demographic = "white",
  filter_to_DST = FALSE,
  has_subgeography = FALSE,
  has_sunset_times = FALSE,
  geofilter_tol = 0.5,
  multi_tz = FALSE
) {
  
  # Add sunset times
  metadata <- list()
  if (!has_sunset_times) {
    tbl <- add_sunset_times(
      tbl, 
      metadata,
      minority_demographic,
      majority_demographic,
      geofilter_tol,
      multi_tz
    )
  }
  
  # DST Filtering
  if (filter_to_DST) {
    tbl <- 
      tbl %>% 
      filter(is_dst_period == TRUE)
  }
  
  # Filter out 30 mins after sunset
  tbl <- 
    tbl %>% 
    filter(minute < sunset_minute | minute > sunset_minute + 30)
  
  # Results
  k_unadj <- calculate_k(tbl)
  
  model_time_const <-
    tbl %>%
    glm(
      formula = is_minority_demographic ~ is_dark + ns(minute, df = 6),
      family = "binomial"
    )

  model_time_varying <-
    tbl %>%
    glm(
      formula = is_minority_demographic ~ is_dark * ns(minute, df = 6),
      family = "binomial"
    )

  model_subgeo_adjusted <- NULL
  if (has_subgeography) {
    model_subgeo_adjusted <-
      tbl %>%
      glm(
        formula = is_minority_demographic ~ is_dark + ns(minute, df = 6) + subgeography,
        family = "binomial"
      )
  }

  list(
    data = tbl,
    models = list(
      model_time_const = model_time_const,
      model_time_varying = model_time_varying,
      model_geo_adjusted = model_subgeo_adjusted
    ),
    results = list(
      log_k = log(k_unadj),
      coefficients = list(
        time_adjusted = coef(model_time_const)[2],
        time_and_geo_adjusted = coef(model_subgeo_adjusted)[2]
      )
    )
  )
}

load_sunset_data <- function(state, city) {
  opp_load_data(state, city) %>%
    add_sunset_times(metadata = list(), multi_tz = FALSE)
}

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

add_sunset_times <- function(
  tbl,
  metadata,
  minority_demographic = "black",
  majority_demographic = "white",
  geofilter_tol = 0.5,
  multi_tz = FALSE
) {
  
  # Drop NAs
  tbl <- clean(
    tbl,
    lat,
    lng,
    subject_race,
    date,
    time,
    geofilter_tol = geofilter_tol,
    metadata = metadata
  )
  
  # Add timezone
  if (!multi_tz) {
    tz <- infer_tz(pull(tbl, lat), pull(tbl, lng))
    tbl <- 
      mutate(
        tbl,
        tz = tz
      )
  } else {
    tzs <-
      tbl %>% 
      distinct(city) %>% 
      pull(city) %>% 
      map_dfr(., ~infer_tz_by_group(tbl, ., city))
    tbl <-
      left_join(tbl, tzs, by = c("group" = "city"))
  }
  
  # Add sunset times
  sunset_times <- infer_sunset_times(tbl, lat, lng, date, tz)
  tbl <-
    left_join(tbl, sunset_times, by = c("date", "tz"))
  
  minutes_per_hour <- 60
  tbl %>%
    mutate(
      minute = hour(hms(time)) * minutes_per_hour + minute(hms(time)),
      sunset_minute = hour(hms(sunset)) * minutes_per_hour + minute(hms(sunset)),
      is_dark = minute > sunset_minute,
      min_sunset_minute = min(sunset_minute),
      max_sunset_minute = max(sunset_minute)
    ) %>%
    filter(
      # Filter to the intertwilight period
      minute >= min_sunset_minute,
      minute <= max_sunset_minute,
      subject_race %in% c(minority_demographic, majority_demographic)
    ) %>%
    mutate(
      twilight_minute = minute - min_sunset_minute,
      minutes_since_dark = minute - sunset_minute,
      is_minority_demographic = subject_race == minority_demographic,
      month = month(date),
      day = day(date),
      is_dst = dst(as.POSIXct(date, tz = tz)),
      is_dst_period = 
        (month == 2 & day >= 25 | 
           month == 3 & day <= 25 | 
           month == 10 & day >= 15 | 
           month == 11 & day <= 15)
    )
}

clean <- function(
  tbl,
  lat_col,
  lng_col,
  ...,
  geofilter_tol = 0.5,
  metadata = list()
) {
  latq = enquo(lat_col)
  lngq = enquo(lng_col)
  drop_vars = quos(...)

  n_before_drop_na <- nrow(tbl)
  tbl <- drop_na(tbl, !!latq, !!lngq, !!!drop_vars)
  n_after_drop_na <- nrow(tbl)
  metadata["null_rate"] <-
    (n_before_drop_na - n_after_drop_na) / n_before_drop_na
  if (metadata[["null_rate"]] > 0) {
    rate_warning(metadata[["null_rate"]], "dropped due to missing values")
  }
  
  # TODO - Fix this!! More specific
  US_LAT_LIMITS <- c(19.5, 64.9)
  US_LNG_LIMITS <- c(-161.8, -68)
  n_before_filter_geo <- nrow(tbl)
  tbl <- 
    tbl %>% 
    filter(
      !!latq < US_LAT_LIMITS[2],
      !!latq > US_LAT_LIMITS[1],
      !!lngq < US_LNG_LIMITS[2],
      !!lngq > US_LNG_LIMITS[1]
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

infer_tz_by_group <- function(tbl, group_val, group_var = city, n = 10) 
{
  group_var <- enquo(group_var)
  lats <- 
    tbl %>% 
    filter(!!group_var == group_val) %>% 
    pull(lat)
  
  lngs <- 
    tbl %>% 
    filter(!!group_var == group_val) %>% 
    pull(lng)
  
  print(str_c("Inferring TZ for ", group_val))
  tibble(
    group = group_val,
    tz = infer_tz(lats, lngs, n)
  )
}

infer_tz <- function(lats, lngs, n = 10) {
  sample_idx <- sample.int(length(lats), min(n, length(lats)))
  # NOTE: uses 'fast' by default, 'accurate' requires a lot more dependencies,
  # and it doesn't seem to be necessary to be more accurate
  tzs <- suppressWarnings(tz_lookup_coords(lats[sample_idx], lngs[sample_idx]))
  tz <- unique(tzs)
  stopifnot(length(tz) == 1)
  tz
}

infer_sunset_times <- function(
  tbl, 
  lat_col = lat, 
  lng_col = lng, 
  date_col = date,
  tz_col = tz
) {
  latq <- enquo(lat_col)
  lngq <- enquo(lng_col)
  dateq <- enquo(date_col)
  tzq <- enquo(tz_col)
  
  tbl %>% 
    group_by(!!dateq, !!tzq) %>% 
    summarise(
      med_lat = median(!!latq),
      med_lng = median(!!lngq)
    ) %>% 
    rowwise() %>% 
    mutate(
      sunset = calculate_sunset_times(!!dateq, med_lat, med_lng, !!tzq)
    ) %>% 
    select(-med_lat, -med_lng)
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

plot_prop_minority_by_time <- function(
    tbl,
    min_clock_time,
    max_clock_time,
    title = "",
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
  
  tbl %>% 
    filter(
      time > min_clock_time,
      time < max_clock_time,
      minutes_since_dark <= time_range$high,
      minutes_since_dark >= time_range$low
    ) %>% 
    mutate(
      min_since_sunset_bin = minutes_since_dark %/% time_accuracy * time_accuracy,
      clock_time = hms::hms(min = minute - 12 * 60),
      clock_time_bin = case_when(
        clock_time < hms::hms(hours = 5, min = 45) ~ "5:30-5:45",
        clock_time < hms::hms(hours = 6, min = 00) ~ "5:45-6:00",
        clock_time < hms::hms(hours = 6, min = 15) ~ "6:00-6:15",
        clock_time < hms::hms(hours = 6, min = 30) ~ "6:15-6:30",
        clock_time < hms::hms(hours = 6, min = 45) ~ "6:30-6:45",
        clock_time < hms::hms(hours = 7, min = 00) ~ "6:45-7:00",
        clock_time < hms::hms(hours = 7, min = 15) ~ "7:00-7:15",
        TRUE ~ "7:15-7:30"
      )
    ) %>% 
    group_by(min_since_sunset_bin, clock_time_bin) %>% 
    summarise(prop_minority = sum(is_minority_demographic) / n(), total = n()) %>% 
    ggplot(aes(min_since_sunset_bin, prop_minority, color = clock_time_bin)) +
    geom_vline(xintercept = 0) +
    geom_smooth(method = smooth_method, se = FALSE) +
    scale_x_continuous(
      breaks = seq(
        time_range$low,
        time_range$high,
        by = 30),
      limits = c(time_range$low, time_range$high)
    ) +
    lims(y = c(0.2, 0.7)) +
    labs(
      title = title,
      x = "Minutes since sunset",
      y = "Proportion minority drivers stopped"
    )
}