source("opp.R")


load <- function(analysis = "vod") {

  # NOTE: test locations
  tbl <- tribble(
    ~state, ~city,
    "WA", "Seattle",
    # "WA", "Statewide",
    "CT", "Hartford"
  )
  # tbl <- opp_available()

  if (analysis == "vod") {
    load_func <- load_vod_for
  } else if (analysis == "disparity") {
    load_func <- load_disparity_for
  } else if (analysis == "mj") {
    load_func <- load_mj_for
    tbl <- filter(tbl, city == "Statewide")
  }

  results <- opp_apply(load_func, tbl)
  results

  # list(
  #   data = bind_rows(lapply(results, function(p) p@data)),
  #   metadata = bind_rows(lapply(results, function(p) p@metadata))
  # )
}


load_vod_for <- function(state, city) {
  load_base_for(state, city)
}


load_disparity_for <- function(state, city) {
  load_base_for(state, city)
}


load_mj_for <- function(state, city) {
  load_base_for(state, city)
}


load_base_for <- function(state, city) {

  state <- str_to_upper(state)
  city <- str_to_title(city)

  p <-
    new("Pipeline") %>%
    init(
      opp_load_clean_data(state, city) %>%
      # NOTE: raw_* columns aren't used in the analyses so drop them
      select(-matches("raw_")) %>%
      mutate(state = state, city = city)
    ) %>%
    keep_only_highway_patrol_if_state() %>%
    filter_to_vehicular_stops() %>%
    filter_to_analysis_years(years = 2011:2018) %>%
    remove_months_with_too_few_stops(min_stops = 50) 
    # remove_months_with_too_few_stops(min_stops = 50) %>%
    # remove_months_with_poor_race_coverage(threshold = 0.65) %>%
    # filter_to_analysis_races(races = c("white", "black", "hispanic")) %>%
    # add_subgeography() %>%
    # remove_anomalous_subgeographies()

  p@metadata %<>%
    mutate(state = state, city = city) %>%
    select(state, city, everything())

  p
}


keep_only_highway_patrol_if_state <- function(p) {

  action <- "keeping only highway parol data"
  reason <- "some states have multiple departments, i.e. dept of agriculture"
  result <- "no change"

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
  details <- list(month_count <- count(p@data, month = format(date, "%Y-%m")))

  bad_months <- filter(details$month_count, n < min_stops) %>% pull(month)
  if (length(bad_months) > 0) {
    p@data %<>% filter(!(format(date, "%Y-%m") %in% bad_months))
    result <- sprintf("removed months %s", str_c(bad_months, collapse = ", "))
  }

  add_decision(p, action, reason, result, details)
}


remove_months_with_poor_race_coverage <- function(p, threshold) {

  action <- sprintf(
    "remove months where race is recorded less than %g%% of the time",
    threshold * 100
  )
  reason <- "race recording is unreliable"
  result <- "no change"

  if (!("subject_race" %in% colnames(p@data))) {
    result <- "eliminated because race is not recorded"
    p@data %<>% slice(0)
    return(add_decision(p, action, reason, result))
  }

  cvg <-
    p@data %>%
    group_by(month = format(date, "%Y-%m")) %>%
    summarize(coverage = coverage_rate(subject_race)) %>%
    ungroup()

  details <- list(race_coverage = cvg)

  bad_months <- filter(cvg, coverage < threshold) %>% pull(month)
  if (length(bad_months) > 0) {
    p@data %<>% filter(!(format(date, "%Y-%m") %in% bad_months))
    result <- sprintf("removed months %s", str_c(bad_months, collapse = ", "))
  }

  add_decision(p, action, reason, result, details)
}


filter_to_analysis_races <- function(p, races) {

  action <- sprintf("filter to races %s", str_c(races, collapse = ", "))
  reason <- "these are the most common races in the U.S."
  result <- "no change"

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

  # TODO(danj): add condition to use subgeography with intermediate numbers

  action <- "add subgeography"
  reason <- "necessary for some analyses"
  result <- "no change"

  subgeography_colnames <-
    if (p@data$city[[1]] == "Statewide") {
      quos_names(state_subgeographies)
    } else {
      quos_names(city_subgeographies)
    }

  subgeographies <- select_or_add_as_na(p@data, subgeography_colnames)
  subgeography <- subgeographies %>% select_if(funs(which.min(sum(is.na(.)))))
  subgeography_selected <- colnames(subgeography)[[1]]
  colnames(subgeography) <- "subgeography"
  p@data %<>% bind_cols(subgeography)

  summary <-
    left_join(
      null_rates(subgeographies),
      n_distinct_values(subgeographies)
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
  diff <- n_before - n_after
  if (diff > 0)
    result %<>% str_c("removed %g records", diff)

  add_decision(p, action, reason, result)
}
