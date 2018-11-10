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
  demographic_col = subject_race,
  geographic_col = NULL,
  subgeographic_col = district,
  date_col = date,
  time_col = time,
  lat_col = lat,
  lng_col = lng,
  has_sunset_times = FALSE,
  filter_to_DST = FALSE
) {

  demographicq <- enquo(demographic_col)
  geographicq <- NULL
  if (!is.null(geographic_col)) {
    geographicq <- enquo(geographic_col)
  }
  subgeographicq <- enquo(subgeographic_col)
  dateq <- enquo(date_col)
  timeq <- enquo(time_col)
  latq = enquo(lat_col)
  lngq = enquo(lng_col)

  metadata <- list()
  
  if (!has_sunset_times) {
    tbl <- add_sunset_times(
      tbl, 
      metadata,
      minority_demographic,
      majority_demographic,
      demographic_col,
      geographic_col,
      date_col,
      time_col,
      lat_col,
      lng_col,
      multi_tz = is.null(geographic_col)
    )
  }
  
  if (filter_to_DST) {
    tbl <- 
      tbl %>% 
      filter(is_dst_period == TRUE)
  }
  
  tbl <- 
    tbl %>% 
    filter(minute < sunset_minute | minute > sunset_minute + minutes(30))
  
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

  model_district_adjusted <-
    tbl %>%
    glm(
      formula = is_minority_demographic ~ is_dark + ns(minute, df = 6) + subgeography,
      family = "binomial"
    )

  list(
    data = list(
      data = tbl,
      summary_proportions = summary
    ),
    models = list(
      model_time_const = model_time_const,
      model_time_varying = model_time_varying,
      model_district_adjusted = model_district_adjusted
    ),
    results = list(
      log_k = log(k_unadj),
      coefficients = list(
        time_adjusted = coef(model_time_const)[2],
        time_and_geo_adjusted = coef(model_district_adjusted)[2]
      )
    )
  )
}

add_sunset_times <- function(
  tbl,
  metadata,
  minority_demographic = "black",
  majority_demographic = "white",
  demographic_col = subject_race,
  geographic_col = NULL,
  date_col = date,
  time_col = time,
  lat_col = lat,
  lng_col = lng,
  latlng_tol = 0.5,
  multi_tz = FALSE
) {
  demographicq <- enquo(demographic_col)
  dateq <- enquo(date_col)
  timeq <- enquo(time_col)
  latq <- enquo(lat_col)
  lngq <- enquo(lng_col)

  geographicq <- NULL
  if (multi_tz) {
    geographicq <- enquo(geographic_col)
  }
  
  tbl <- clean(
    tbl,
    !!latq,
    !!lngq,
    !!demographicq,
    !!dateq,
    !!timeq,
    metadata = metadata
  )
  
  if (is.null(geographicq)) {
    tz <- infer_tz(pull(tbl, !!latq), pull(tbl, !!lngq))
    tbl <- 
      mutate(
        tbl,
        tz = tz
      )
  } else {
    tzs <-
      tbl %>% 
      distinct(!!geographicq) %>% 
      pull(!!geographicq) %>% 
      map_dfr(., ~infer_tz_by_group(tbl, ., !!geographicq))
    by <- set_names("group", quo_name(geographicq))
    tbl <-
      left_join(tbl, tzs, by = by)
  }
  
  sunset_times <- infer_sunset_times(tbl, !!latq, !!lngq, !!dateq, tz)
  date_colname <- quo_text(dateq)
  tbl <-
    left_join(tbl, sunset_times, by = c(date_colname, "tz"))
  
  minutes_per_hour <- 60
  tbl %>%
    # NOTE: prefilter since calculate sunset times takes a while
    filter(
      hour(hms(time)) > 14, # 2 PM - allow window of 3 hours either
      hour(hms(time)) < 23 # 11 PM   side of earliest/latest sunset
    ) %>%
    mutate(
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
      minutes_since_dark = minute - sunset_minute,
      is_minority_demographic = !!demographicq == minority_demographic,
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

clean <- function(
  tbl,
  lat_col,
  lng_col,
  ...,
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

# Generate synthetic data to test

plot_prop_minority_by_time <- function(
    tbl,
    min_time,
    max_time,
    title = "",
    DST_only = FALSE,
    city_only = NULL,
    clock_time_col = minute,
    dark_minute_col = minutes_since_dark,
    demographic_col = is_minority_demographic,
    smooth_method = "loess",
    time_range = list(low = -3, high = 3), # hours
    time_accuracy = 15 # minutes
) {
  dark_minuteq <- enquo(dark_minute_col)
  demographicq <- enquo(demographic_col)
  clock_timeq <- enquo(clock_time_col)
  
  minutes_per_hour <- 60
  
  if(DST_only) {
    tbl <- filter(tbl, is_dst_period == TRUE)
  }
  
  if(!is.null(city_only)) {
    tbl <- filter(tbl, city == city_only)
  }
  
  tbl %>% 
    filter(
      time > min_time,
      time < max_time,
      !!dark_minuteq <= 90,
      !!dark_minuteq >= -90
    ) %>% 
    mutate(
      min_since_sunset_bin = !!dark_minuteq %/% time_accuracy * time_accuracy,
      clock_time = hms::hms(min = !!clock_timeq - 12 * 60),
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
    summarise(prop_minority = sum(!!demographicq) / n(), total = n()) %>% 
    ggplot(aes(min_since_sunset_bin, prop_minority, color = clock_time_bin)) +
    geom_vline(xintercept = 0) +
    geom_smooth(method = smooth_method, se = FALSE) +
    scale_x_continuous(
      breaks = seq(
        -90,
        90,
        by = 30),
      limits = c(-90, 90)
    ) +
    lims(y = c(0.2, 0.7)) +
    labs(
      title = title,
      x = "Minutes since sunset",
      y = "Proportion minority drivers stopped"
    )
}

plot_prop_minority_by_time_dst <- function(
  tbl,
  min_time,
  max_time,
  title = "",
  city_only = NULL,
  clock_time_col = minute,
  dark_minute_col = minutes_since_dark,
  demographic_col = is_minority_demographic,
  smooth_method = "loess",
  time_range = list(low = -3, high = 3), # hours
  time_accuracy = 15 # minutes
) {
  dark_minuteq <- enquo(dark_minute_col)
  demographicq <- enquo(demographic_col)
  clock_timeq <- enquo(clock_time_col)
  
  minutes_per_hour <- 60
  
  tbl <- filter(tbl, is_dst_period == TRUE)
  
  if(!is.null(city_only)) {
    tbl <- filter(tbl, city == city_only)
  }
  
  tbl %>% 
    filter(
      time > min_time,
      time < max_time,
      !!dark_minuteq <= 90,
      !!dark_minuteq >= -90
    ) %>% 
    mutate(
      min_since_sunset_bin = !!dark_minuteq %/% time_accuracy * time_accuracy,
      clock_time = hms::hms(min = !!clock_timeq - 12 * 60),
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
    group_by(min_since_sunset_bin, clock_time_bin, is_dst) %>% 
    summarise(prop_minority = sum(!!demographicq) / n(), total = n()) %>% 
    ggplot(aes(min_since_sunset_bin, prop_minority, color = is_dst)) +
    geom_vline(xintercept = 0) +
    geom_smooth(method = smooth_method, se = FALSE) +
    facet_wrap(. ~ clock_time_bin, scales = "free_y") +
    scale_x_continuous(
      breaks = seq(
        -90,
        90,
        by = 30),
      limits = c(-90, 90)
    ) +
    lims(y = c(0.2, 0.7)) +
    labs(
      title = title,
      x = "Minutes since sunset",
      y = "Proportion minority drivers stopped"
    )
}

load_sunset_data <- function(state, city) {
  opp_load_data(state, city) %>%
    add_sunset_times(metadata = list(), multi_tz = FALSE)
}

load_and_plot <- function(state, city){
  data <-
    opp_load_data(state, city) %>% 
    add_sunset_times(metadata = list(), multi_tz = FALSE)
  data %>% 
    plot_prop_minority_by_time(title = str_c(city, ", ", state)) %>% 
    print()
  data
}

filter_to_DST <- function(tbl) {
  tbl %>% 
    mutate(
      day = day(date),
      month = month(date)
    ) %>% filter(
      month == 2 & day >= 25 | 
        month == 3 & day <= 25 | 
        month == 10 & day >= 15 | 
        month == 11 & day <= 15)
}