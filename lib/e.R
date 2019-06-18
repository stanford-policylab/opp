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
    keep_only_highway_patrol_if_state()

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
