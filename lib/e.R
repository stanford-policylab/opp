source("opp.R")

load <- function(analysis = "disparity") {

  # NOTE: test locations
  # tbl <- tribble(
  #   ~state, ~city,
  #   "WA", "Seattle",
  #   "WA", "Statewide",
  #   "CT", "Hartford",
  #   "TX", "Arlington"
  # )
  tbl <- opp_available()

  if (analysis == "vod_dst") {
    load_func <- load_dst_vod_for
  } else if (analysis == "vod_full") {
    load_func <- load_full_vod_for
  } else if (analysis == "disparity") {
    load_func <- load_disparity_for
  } else if (analysis == "mj") {
    load_func <- load_mj_for
    tbl <- filter(tbl, city == "Statewide")
  } else if (analysis == "mjt") {
    load_func <- load_mj_threshold_for
    tbl <- filter(tbl, state %in% c("CO", "WA"))
  }

  results <- opp_apply(
    function(state, city) {
      p <- load_func(state, city)
      p@metadata %<>% 
        mutate(state = state, city = city) %>%
        select(state, city, everything())
      p
    },
    tbl
  )

  list(
    data = bind_rows(lapply(results, function(p) p@data)),
    metadata = bind_rows(lapply(results, function(p) p@metadata))
  )
}


load_dst_vod_for <- function(state, city) {
  load_vod_base_for(state, city) %>%
    remove_states_that_dont_observe_dst() %>% 
    add_dst_dates() %>%
    filter_to_dst_windows(week_radius = 3) %>% 
    remove_locations_with_too_few_stops_per_race(geography, min_stops = 100) %>% 
    select_top_n_locations_per_super(geography, state, top_n = 20)
}

load_full_vod_for <- function(state, city) {
  load_vod_base_for(state, city) %>%
    remove_partial_years(geography) %>% 
    remove_locations_with_too_few_stops_per_race(geography, min_stops = 100) %>% 
    select_top_n_locations_per_super(geography, state, top_n = 20)
}

load_vod_base_for <- function(state, city) {
  load_base_for(state, city) %>%
    remove_months_with_low_coverage(date, threshold = 0.5) %>%
    remove_months_with_low_coverage(time, threshold = 0.5) %>% 
    remove_na(date) %>% 
    remove_na(time) %>% 
    filter_to_analysis_races(races = c("white", "black")) %>%
    add_county_or_city_as_geography() %>% 
    remove_na(geography) %>% 
    add_lat_lng() %>%
    remove_na(center_lat) %>% 
    remove_na(center_lng) %>% 
    add_sunset_times() %>% 
    filter_to_intertwilight_range()
}

load_disparity_for <- function(state, city) {
  load_base_for(state, city) %>%
    remove_locations_with_unreliable_search_data() %>%
    remove_months_with_low_coverage(search_conducted, threshold = 0.5) %>%
    filter_to_searches() %>%
    filter_to_discretionary_searches_if_search_basis(threshold = 0.5) %>%
    remove_months_with_low_coverage(contraband_found, threshold = 0.5) %>%
    remove_na(contraband_found) %>%
    remove_months_with_low_coverage(subgeography, threshold = 0.5) %>%
    remove_na(subgeography)
}


load_mj_for <- function(state, city) {
  load_base_for(state, city) %>%
    remove_locations_with_unreliable_search_data() %>%
    filter_to_locations_with_data_before_and_after_legalization() %>%
    remove_months_with_low_coverage(search_conducted, threshold = 0.5) %>%
    add_mj_calculated_features()
}


load_mj_threshold_for <- function(state, city) {
  load_mj_for(state, city) %>%
    remove_na(search_conducted) %>%
    remove_months_with_low_coverage(subgeography, threshold = 0.5) %>%
    remove_na(subgeography)
}


load_base_for <- function(state, city) {
  new("Pipeline") %>%
    init(
      opp_load_clean_data(state, city) %>%
      # NOTE: raw_* columns aren't used in the analyses so drop them
      select(-matches("raw_")) %>%
      mutate(state = str_to_upper(state), city = str_to_title(city))
    ) %>%
    keep_only_highway_patrol_if_state() %>%
    filter_to_vehicular_stops() %>%
    filter_to_analysis_years(years = 2011:2018) %>%
    remove_months_with_too_few_stops(min_stops = 50) %>%
    remove_months_with_low_coverage(subject_race, threshold = 0.5) %>%
    filter_to_analysis_races(races = c("white", "black", "hispanic")) %>%
    add_subgeography() %>%
    remove_anomalous_subgeographies()
}


keep_only_highway_patrol_if_state <- function(p) {

  action <- "keeping only highway parol data"
  reason <- "some states have multiple departments, i.e. dept of agriculture"
  result <- "no change"

  print(action)

  is_state <- p@data$city[[1]] == "statewide"
  has_multiple_departments <- "department_name" %in% colnames(p@data)
  if (is_state & has_multiple_departments) {
    n_before <- nrow(p@data)
    p@data %<>%
      filter(
        case_when(
          state == "NC" ~ department_name == "NC State Highway Patrol",
          state == "IL" ~ department_name == "ILLINOIS STATE POLICE",
          state == "CT" ~ department_name == "State Police",
          state == "MD" ~ department_name %in% c("Maryland State Police", "MSP"),
          state == "MS" ~ department_name == "Mississippi Highway Patrol",
          state == "MO" ~ department_name == "Missouri State Highway Patrol",
          state == "NE" ~ department_name == "Nebraska State Agency",
          # NOTE: it's a state, but none of those above, so keep it all
          TRUE ~ TRUE
        )
      )
    n_after <- nrow(p@data)
    if (n_before - n_after > 0)
      result <- "rows removed"
  }

  add_decision(p, action, reason, result)
}


filter_to_vehicular_stops <- function(p) {

  action <- "filter to vehicular stops"
  reason <- "pedestrian stops are qualitatively different"
  result <- "no change"

  print(action)

  details <- list(type_proportion <- count_pct(p@data, type))
  n_before <- nrow(p@data)
  p@data %<>% filter(type == "vehicular")
  n_after <- nrow(p@data)
  if (n_before - n_after > 0)
    result <- "rows removed"

  add_decision(p, action, reason, result, details)
}


filter_to_analysis_years <- function(p, years) {

  action <- sprintf("filter to years %s", str_c(years, collapse = ", "))
  reason <- "most recent, relevant years"
  result <- "no change"

  print(action)

  n_before <- nrow(p@data)
  p@data %<>% filter(year(date) %in% years)
  n_after <- nrow(p@data)
  if (n_before - n_after > 0)
    result <- "rows removed"

  add_decision(p, action, reason, result)
}


remove_months_with_too_few_stops <- function(p, min_stops) {

  action <- sprintf("remove months with fewer than %g stops", min_stops)
  reason <- "data is too sparse to trust"
  result <- "no change"

  print(action)

  month_count = count(p@data, month = format(date, "%Y-%m"))
  bad_months <- filter(month_count, n < min_stops) %>% pull(month)
  details <- list(month_count = month_count, bad_months = bad_months)

  n <- length(bad_months)
  if (n > 0) {
    p@data %<>% filter(!(format(date, "%Y-%m") %in% bad_months))
    result <- sprintf("removed %g months", n)
  }

  add_decision(p, action, reason, result, details)
}


remove_months_with_low_coverage <- function(p, feature, threshold) {

  featq <- enquo(feature)
  feat_name <- quo_name(featq)

  action <- sprintf(
    "remove months where %s is recorded less than %g%% of the time",
    feat_name,
    threshold * 100
  )
  reason <- sprintf("%s data is unreliable", feat_name)
  result <- "no change"

  print(action)

  if (!(feat_name %in% colnames(p@data))) {
    result <- sprintf("eliminated because %s data is not recorded", feat_name)
    p@data %<>% slice(0)
    return(add_decision(p, action, reason, result))
  }

  cvg <-
    p@data %>%
    group_by(month = format(date, "%Y-%m")) %>%
    summarize(coverage = coverage_rate(!!featq)) %>%
    ungroup()

  details <- list(coverage = cvg)

  bad_months <- filter(cvg, coverage < threshold) %>% pull(month)
  if (length(bad_months) > 0) {
    p@data %<>% filter(!(format(date, "%Y-%m") %in% bad_months))
    result <- sprintf("removed months %s", str_c(bad_months, collapse = ", "))
  }

  add_decision(p, action, reason, result, details)
}


remove_na <- function(p, feature) {

  featq <- enquo(feature)
  feat_name <- quo_name(featq)

  action <- sprintf("remove rows where %s is NA", feat_name)
  reason <- sprintf("%s is required for analysis", feat_name)
  result <- "no change"

  print(action)

  if (!(feat_name) %in% colnames(p@data)) {
    result <- sprintf("eliminated because %s not recorded", feat_name)
    p@data %<>% slice(0)
    return(add_decision(p, action, reason, result))
  }

  n_before <- nrow(p@data)
  p@data %<>% filter(!is.na(!!featq))
  n_after <- nrow(p@data)
  if (n_before - n_after > 0)
    result <- "rows removed"

  add_decision(p, action, reason, result)
}


filter_to_analysis_races <- function(p, races) {

  action <- sprintf("filter to races %s", str_c(races, collapse = ", "))
  reason <- "these are the most common races in the U.S."
  result <- "no change"

  print(action)

  if (!("subject_race" %in% colnames(p@data))) {
    result <- "eliminated because race is not recorded"
    p@data %<>% slice(0)
    return(add_decision(p, action, reason, result))
  }

  details <- list(subject_race_proportion <- count_pct(p@data, subject_race))

  n_before <- nrow(p@data)
  p@data %<>% filter(subject_race %in% races)
  n_after <- nrow(p@data)
  if (n_before - n_after > 0)
    result <- "rows removed"

  add_decision(p, action, reason, result, details)
}


add_subgeography <- function(p) {

  action <- "add subgeography"
  reason <- "necessary for some analyses"
  result <- "no change"

  print(action)

  if (nrow(p@data) == 0)
    return(add_decision(p, action, reason, result))

  subgeography_colnames <-
    if (p@data$city[[1]] == "Statewide") {
      quos_names(state_subgeographies)
    } else {
      quos_names(city_subgeographies)
    }

  subgeographies <- select_or_add_as_na(p@data, subgeography_colnames)
  # TODO(danj/amyshoe): add condition to select subgeography with reasonable numbers
  subgeography <- subgeographies %>% select_if(funs(which.min(sum(is.na(.)))))
  subgeography_selected <- colnames(subgeography)[[1]]
  colnames(subgeography) <- "subgeography"
  p@data %<>% bind_cols(subgeography)

  summary <-
    left_join(
      null_rates(subgeographies),
      n_distinct_values(subgeographies),
      by = "feature"
    ) %>%
    mutate(selected = feature == subgeography_selected)

  selected <- filter(summary, selected)

  result <- sprintf(
    "selected subgeography %s (%s null, %g distinct values)",
    subgeography_selected,
    selected$`null rate`,
    selected$`n distinct values`
  )
  details <- list(summary = summary)

  add_decision(p, action, reason, result, details)
}


remove_anomalous_subgeographies <- function(p) {

  # TODO(danj/amyshoe): look for other anomalous subgeos
  action <- "remove anomalous subgeographies"
  reason <- "these regions are either qualitatively different or undefined"
  result <- "no change"

  print(action)

  if (nrow(p@data) == 0)
    return(add_decision(p, action, reason, result))

  details <- list(subgeography_proportion <- count_pct(p@data, subgeography))

  city <- p@data$city[[1]]
  n_before <- nrow(p@data)

  if (city == "Arlington") {

    p@data %<>% filter(!(subgeography %in% c("N", "E", "S", "W")))
    result <- str_c(
      "filtered out districts that aren't 'N', 'E', 'S', and 'W', ",
      "since they appear to be data entry errors"
    )

  } else if (city == "Louisville") {

    p@data %<>% filter(!str_detect(subgeography, "DIVISON"))
    result <- str_c(
      "filtered out division 'DIVISION' since it appears to be ",
      "a data entry error"
    )

  } else if (city == "Nashville") {

    p@data %<>% filter(subgeography != "U")
    result <- "filtered out precinct 'U' (Unknown)"

  } else if (city == "Philadelphia") {

    p@data %<>% filter(subgeography != "77")
    result <- str_c(
      "filtered out district 77 because it's the airport and HQ and ",
      "has qualitatively different stops"
    )

  } else if (city == "Plano") {

    p@data %<>% filter(subgeography != "999")
    result <- str_c(
      "filtered out sector '9999' since it appears to be ",
      "a data entry error"
    )

  } else if (city == "San Diego") {

    p@data %<>% filter(subgeography != "Unknown")
    result <- "filtered out service_area 'Unknown'"
  }

  n_after <- nrow(p@data)
  if (n_before - n_after > 0)
    result <- "rows removed"

  add_decision(p, action, reason, result)
}


filter_to_searches <- function(p) {

  action <- "filter to searches"
  reason <- "searches are the risk population"
  result <- "no change"

  print(action)

  if (!("search_conducted") %in% colnames(tbl)) {
    result <- "eliminated because search data not recorded"
    p@data %<>% slice(0)
    return(add_decision(p, action, reason, result))
  }

  n_before <- nrow(p@data)
  p@data %<>% filter(search_conducted)
  n_after <- nrow(p@data)
  if (n_before - n_after > 0)
    result <- "rows removed"

  add_decision(p, action, reason, result, details)
}



filter_to_discretionary_searches_if_search_basis <- function(p, threshold) {

  action <- str_c(
    "keep only plain view, consent, probable cause, k9 and NA searches ",
    "(assume NA is discretionary) where search_basis is reliable; ",
    "excludes arrest/warrant, probation/parole, inventory searches"
  )
  reason <- "the officer decides to make these searches and is not obligated"
  result <- "no change"

  print(action)

  p@data %<>% filter(search_conducted)

  if (!("search_basis") %in% colnames(tbl)) {
    result <- str_c(
      "search basis not recorded; ",
      "assuming all searches are discretionary"
    )
    return(add_decision(p, action, reason, result))
  }

  cvg_rate <- coverage_rate(p@data$search_basis)
  details <- list(coverage = cvg_rate)

  # TODO(danj/amyshoe): this is really what we want to do?
  if (cvg_rate < threshold) {
    result <- sprintf(
      str_c(
        "search basis coverage rate %g%% < %g%% (threshold), ",
        "making it unreliable; assuming all searches are discretionary"
      ),
      cvg_rate * 100,
      threshold * 100
    )
    return(add_decision(p, action, reason, result))
  }

  n_before <- nrow(p@data)
  p@data %<>% filter(
    search_conducted,
    is.na(search_basis)
    | search_basis %in% c("plain view", "consent", "probable cause", "k9")
  )
  n_after <- nrow(p@data)
  if (n_before - n_after > 0)
    result <- "rows removed"

  add_decision(p, action, reason, result, details)
}


remove_locations_with_unreliable_search_data <- function(p) {

  action <- "remove locations with unreliable search data"
  reason <- "has an unreiable and/or irregular recording policy"
  result <- "no change"

  print(action)

  if (nrow(p@data) == 0)
    return(add_decision(p, action, reason, result))

  city <- p@data$city[[1]]
  state <- p@data$state[[1]]
  n_before <- nrow(p@data)

  if (city == "Statewide" & state %in% c("IL", "MD", "MO", "NE")) {
    p@data %<>% slice(0)
    result <- case_when(
      state,
      "IL" ~ "removed because search recording policy changes year to year",
      "MD" ~ "removed because before 2013 we are only given annual data",
      "MO" ~ "removed because it's all annual data",
      "NE" ~ str_c(
        "removed because it has unreliable quarterly dates, ",
        "i.e. in 2012 all patrol stops are in Q1"
      ),
      TRUE ~ "no change"
    )
  }

  n_after <- nrow(p@data)
  if (n_before - n_after > 0)
    result <- "rows removed"

  add_decision(p, action, reason, result)
}


filter_to_locations_with_data_before_and_after_legalization <- function(p) {

  action <- "filter to locations with data before and after 2012"
  reason <- "need data pre/post marijuana legalization"
  result <- "no change"

  print(action)

  if (nrow(p@data) == 0)
    return(add_decision(p, action, reason, result))

  date_range <- range(p@data$date, na.rm = TRUE)
  start_year <- year(date_range[1])
  end_year <- year(date_range[2])
  details <- list(date_range = date_range)
  if (start_year > 2012 | end_year < 2012) {
    p@data %<>% slice(0)
    result <- "eliminated: there isn't data before and after legalization"
    return(add_decision(p, action, reason, result, details))
  } 

  add_decision(p, action, reason, result, details)
}


add_mj_calculated_features <- function(p) {

  action <- "add legalization, treatment, search, and misdemeanor features"
  reason <- "these are required for the analysis"
  result <- "added the features"

  if (nrow(p@data) == 0)
    return(add_decision(p, action, reason, "no change"))

  if (!("subject_race" %in% colnames(p@data))) {
    result <- "eliminated because race is not recorded"
    p@data %<>% slice(0)
    return(add_decision(p, action, reason, result))
  }

  if (!("violation") %in% colnames(p@data))
    p@data %<>% mutate(violation = NA)

  if (!("search_basis") %in% colnames(p@data))
    p@data %<>% mutate(violation = NA)

  p@data %<>% 
    mutate(
      subject_race = relevel(factor(subject_race), "white"),
      legalization_date = if_else(
        state == "CO",
        as.Date("2012-12-10"),
        # NOTE: default for control and WA is WA's legalization date
        as.Date("2012-12-09")
      ),
      is_before_legalization = date < legalization_date,
      is_treatment_state = state %in% c("WA", "CO"),
      is_treatment = is_treatment_state & !is_before_legalization,
      violation = str_to_lower(violation),
      # NOTE: search_basis = NA is interpreted as a discretionary search;
      # excludes other (non-discretionary)
      is_discretionary_search =
        search_conducted
        & (
          is.na(search_basis)
          | search_basis %in% c("k9", "plain view", "probable cause", "consent")
        ),
      is_drugs_infraction_or_misdemeanor = str_detect(
        violation,
        str_c(
          # NOTE: Details on Colorado's marijuana policies:
          # https://www.colorado.gov/pacific/marijuana/driving-and-traveling
          # CO violations
          "possession of 1 oz or less of marijuana",
          # NOTE: these spike after legalization
          # "open marijuana container",

          # WA violations
          "drugs - misdemeanor",
          "drugs paraphernalia - misdemeanor",
          sep = "|"
        )
      )
    )

  add_decision(p, action, reason, result)
}

add_county_or_city_as_geography <- function(p) {
  action <- "add counties and cities as geography"
  reason <- "necessary for joint state-city vod models"
  result <- "no change"
  
  print(action)
  
  if (nrow(p@data) == 0)
    return(add_decision(p, action, reason, result))
  
  geography_colname <-
    if (p@data$city[[1]] == "Statewide") {
      "county_name"
    } else {
      "city"
    }
  
  geography <- select_or_add_as_na(p@data, geography_colname)
  colnames(geography) <- "geography"
  p@data %<>% 
    bind_cols(geography) %>% 
    mutate(geography = str_c(geography, state, sep = ", "))
  
  summary <-
    left_join(
      null_rates(geography),
      n_distinct_values(geography),
      by = "feature"
    ) 
  
  result <- sprintf(
    "selected geography %s (%s null, %g distinct values)",
    geography_colname,
    summary$`null rate`,
    summary$`n distinct values`
  )
  details <- list(summary = summary)
  
  add_decision(p, action, reason, result, details)
}

add_lat_lng <- function(p) {
  action <- "add lat/lng"
  reason <- "necessary for computing sunset times"
  result <- "no change"
  
  print(action)
  
  if (nrow(p@data) == 0)
    return(add_decision(p, action, reason, result))
  
  geocodes <-
    if (p@data$city[[1]] == "Statewide") {
      geoCounty %>% 
      filter(state == p@data$state[[1]]) %>% 
      select(state, county, center_lat = lat, center_lng = lon) %>% 
      mutate(
        # to match how states were processed, where McHenry, ND is Mchenry, ND
        county = str_to_title(county),
        # to match how states were processed, where "St. Johns" is "St Johns"
        county = str_replace_all(county, "\\.", "")
      ) %>% 
      unite(geography, c("county", "state"), sep = ", ")
    } else {
      read_csv(here::here("resources", "city_coverage_geocodes.csv")) %>%
      rename(center_lat = lat, center_lng = lng) 
    }
  
  p@data %<>% 
    left_join(geocodes, by = "geography")
  
  summary <-
    null_rates(select(p@data, center_lat, center_lng))
  
  lat_lng_null_rate <- max(summary$`null rate`)
  
  result <- sprintf(
    "added lat/lng (%s null)",
    lat_lng_null_rate
  )
  details <- list(summary = summary)
  
  add_decision(p, action, reason, result, details)
}

add_sunset_times <- function(p) {
  action <- "add sunset times"
  reason <- "necessary for vod analysis"
  result <- "no change"
  
  print(action)
  
  if (nrow(p@data) == 0)
    return(add_decision(p, action, reason, result))
  
  tzs <-
    p@data %>%
    select(center_lat, center_lng) %>%
    distinct() %>%
    # NOTE: Warning is about using 'fast' by default; 'accurate' requires
    # more dependencies and it doesn't seem necessary
    mutate(
      tz = tz_lookup_coords(pull(., center_lat), pull(., center_lng), warn = F)
    )
  
  sunset_times <- 
    p@data %>%
    select(date, center_lat, center_lng) %>%
    distinct() %>%
    left_join(tzs) %>%
    mutate(
      lat = center_lat, 
      lon = center_lng
    ) %>% 
    mutate(
      sunset_utc = getSunlightTimes(data = ., keep = c("sunset"))$sunset,
      date = ymd(str_sub(date, 1, 10))
    ) %>% 
    mutate(
      dusk_utc = getSunlightTimes(data = ., keep = c("dusk"))$dusk,
      date = ymd(str_sub(date, 1, 10))
    )
  
  to_local_time <- function(sunset_utc, tz) {
    format(sunset_utc, "%H:%M:%S", tz = tz)
  }
  
  sunset_times$pre_sunset <- unlist(
    map2(sunset_times$sunset_utc, sunset_times$tz, to_local_time)
  )
  sunset_times$sunset <- unlist(
    map2(sunset_times$dusk_utc, sunset_times$tz, to_local_time)
  )
  
  p@data %<>% left_join(
    sunset_times %>% 
      select(date, center_lat, center_lng, pre_sunset, sunset)
  ) 
  
  summary <- null_rates(select(p@data, sunset, pre_sunset))
  sunset_null_rate <- max(summary$`null rate`)
  
  result <- sprintf(
    "added sunset times (%s null)",
    sunset_null_rate
  )
  details <- list(summary = summary)
  
  add_decision(p, action, reason, result, details)
}

filter_to_intertwilight_range <- function(p) {
  action <- "filter to intertwilight range"
  reason <- "necessary for vod analysis"
  result <- "no change"
  
  print(action)
  
  if (nrow(p@data) == 0)
    return(add_decision(p, action, reason, result))
  
  time_to_minute <- function(time) {
    hour(hms(time)) * 60 + minute(hms(time))
  }
  
  p@data <-
    p@data %>%
    mutate(
      minute = time_to_minute(time),
      pre_sunset_minute = time_to_minute(pre_sunset),
      sunset_minute = time_to_minute(sunset),
      min_sunset_minute = min(sunset_minute),
      max_sunset_minute = max(sunset_minute)
    )
  
  n_before <- nrow(p@data)
  p@data %<>% 
    filter(
      # NOTE: filter to get only the intertwilight period
      minute >= min_sunset_minute,
      minute <= max_sunset_minute
    )
  n_after_intertwilight_filter <- nrow(p@data)
  p@data %<>% 
    filter(
      # NOTE: remove the ~30min ambiguously lit period between sunset and dusk
      !(minute > pre_sunset_minute & minute < sunset_minute)
    ) 
  n_after_ambiguous_light_filter <- nrow(p@data)
  
  if (n_before - n_after_ambiguous_light_filter > 0)
    result <- "rows removed"
  
  details <- list(
    p_removed_from_twilight_filter = 
      (n_before - n_after_intertwilight_filter) / n_before,
    p_removed_from_ambiguous_light_filter = 
      (n_after_intertwilight_filter - n_after_ambiguous_light_filter) /
      n_after_ambiguous_light_filter
  )
  
  add_decision(p, action, reason, result, details)
}

add_dst_dates <- function() {
}

filter_to_dst_windows <- function(week_radius = 3) {
}

remove_locations_with_too_few_stops_per_race <- function(geography, min_stops) {
  
}

select_top_n_locations_per_super <- function(geography, supergeography, top_n) {
  
}

remove_partial_years <- function(geography) {
  
}