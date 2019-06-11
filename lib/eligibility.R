source("opp.R")


eligibility <- function() {
  d <- opp_apply(load, opp_available())
}


load <- function(state, city) {
  opp_load_clean_data(state, city) %|%
  filter_to_analysis_years %|%
  filter_to_vehicular_stops %|%
  keep_only_highway_patrol_if_state
  # keep_only_highway_patrol_if_state %|%
  # add_subgeography
}


filter_to_analysis_years <- function(tbl, log) {
  filter(tbl, year(date) %in% 2017:2018)
}


filter_to_vehicular_stops <- function(tbl, log) {
  filter(tbl, type == "vehicular")
}


keep_only_highway_patrol_if_state <- function(tbl, log) {
  filter(
    tbl,
    if (city == "Statewide") {
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
    } else {
      TRUE
    }
  )
}


# add_subgeography <- function(tbl, log) {
#   mutate(
#     tbl,

#   )
#     if_else(
#       city == "Statewide",
#       quos_names(state_subgeographies),
#       quos_names(city_subgeographies)
#     ),
#   )
#   select_least_na(
#     rename = "subgeography"
#   )
# }
