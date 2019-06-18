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
  }

  results <- opp_apply(load_func, tbl)

  list(
    data = bind_rows(lapply(results, function(p) p@data)),
    metadata = bind_rows(lapply(results, function(p) p@metadata))
  )
}


load_vod_for <- function(state, city) {
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
    remove_years_with_too_few_stops(min_stops = 500)


  p@metadata %<>%
    mutate(state = state, city = city) %>%
    select(state, city, everything())

  p
}


keep_only_highway_patrol_if_state <- function(p) {

  action <- "keeping only highway parol data"
  reason <- "some states have multiple departments, i.e. dept of agriculture"
  result <- "no change"

  is_state <- str_to_lower(p@data$city[[1]]) == "statewide"
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
  details <- list(type_proportion <- count_pct(tbl, type))

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
  p@data %<>% filter(date %in% years)
  n_after <- nrow(p@data)
  if (n_before - n_after > 0)
    result <- "rows removed"

  add_decision(p, action, reason, result)
}


remove_years_with_too_few_stops <- function(p, min_stops) {
  
  action <- sprintf("remove years with fewer than %g stops", min_stops)
  reason <- "data is likely unreliable"
  result <- "no change"
  details <- list(year_count <- count(p@data, yr = year(date)))

  bad_years <- filter(details$year_count, n < min_stops) %>% pull(yr)
  if (length(bad_years) > 0) {
    p@data %<>% filter(!(year(date) %in% bad_years))
    result <- sprintf("removed years %s", str_c(bad_years, collapse = ", "))
  }

  add_decision(p, action, reason, result, details)
}
