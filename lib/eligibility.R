source("opp.R")


load <- function(analysis_name = "vod") {
  if (analysis_name == "vod") {
    load_func <- load_vod_for
  } else if (analysis_name == "disparity") {
    load_func <- load_disparity_for
  } else if (analysis_name == "mj") {
    # TODO(danj)
  }
  # tbl <- tribble(
  #   ~state, ~city,
  #   "WA", "Seattle",
  #   "WA", "Statewide",
  #   "CT", "Hartford"
  # )
  tbl <- opp_available()
  d <-
    opp_apply(
      function(state, city) {
          d <- load_func(state, city)
          # NOTE: opp_apply already uses state as key for each process/output
          city <- str_to_title(city)
          metadata <- list()
          metadata[[city]] <- list()
          metadata[[city]] <- d$metadata
          d$metadata <- metadata
          d
      },
      tbl
    ) %>% purrr::transpose()

  list(data = bind_rows(d$data), metadata = c(d$metadata))
}


load_vod_for <- function(state, city) {
  load_base_for(state, city)
  # TODO(danj/amyshoe): Do we want to add the dst and non-dst filters here?
  # (two separate functions, one filtering to complete years, on filtering 
  # to complete season-ranges)
}


load_disparity_for <- function(state, city) {
  load_base_for(state, city) %|%
    filter_to_sufficient_search_info %|%
    filter_to_discretionary_searches %|%
    filter_to_sufficient_contraband_info
}


load_base_for <- function(state, city) {
  opp_load_clean_data(state, city) %>%
  # NOTE: raw columns are not used in the analyses
  select(-matches("raw_")) %>%
  mutate(state = state, city = city) %|%
  filter_to_vehicular_stops %|%
  filter_to_analysis_years %|%
  filter_to_analysis_races %|%
  keep_only_highway_patrol_if_state %|%
  add_subgeography
}


filter_to_vehicular_stops <- function(tbl, log) {
  log(list(type_proportion = count_pct(tbl, type)))
  tbl <- filter(tbl, type == "vehicular")
  tbl
}


filter_to_analysis_years <- function(tbl, log) {
  # TODO: add a minimum number of records?
  tbl <- filter(tbl, year(date) %in% 2011:2018)
  log(list(date_range = range(tbl$date)))
  tbl
}


filter_to_analysis_races <- function(tbl, log) {
  if (!("subject_race") %in% colnames(tbl)) {
    log(list(reason_eliminated = "subject_race undefined"))
    return(tibble())
  }
  log(list(type_proportion = count_pct(tbl, subject_race)))
  threshold <- 0.65
  if (coverage_rate(tbl$subject_race) < threshold) {
    pct <- threshold * 100
    msg <- sprintf("subject_race non-null less than %g%% of the time", pct)
    log(list(reason_eliminated = msg))
    return(tibble())
  }
  tbl <- filter(tbl, subject_race %in% c("white", "black", "hispanic"))
  tbl
}


keep_only_highway_patrol_if_state <- function(tbl, log) {
  # NOTE: if it's a state and there are multiple departments listed,
  # filter to only the highway patrol stops
  if (tbl$city[[1]] == "Statewide" & "department_name" %in% colnames(tbl)) {
    filter(
      tbl,
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
  } else {
    tbl
  }
}


add_subgeography <- function(tbl, log) {

  subgeography_colnames <-
    if (tbl$city[[1]] == "Statewide") {
      quos_names(state_subgeographies)
    } else {
      quos_names(city_subgeographies)
    }

  subgeographies <- select_or_add_as_na(tbl, subgeography_colnames)
  subgeography <- subgeographies %>% select_if(funs(which.min(sum(is.na(.)))))
  subgeography_selected <- colnames(subgeography)[[1]]

  log(list(stats = 
    left_join(
      null_rates(subgeographies),
      n_distinct_values(subgeographies)
    ) %>%
    mutate(selected = feature == subgeography_selected)
  ))

  bind_cols(tbl, subgeography)
}


filter_to_sufficient_search_info <- function(tbl, log) {
  if (!("search_conducted") %in% colnames(tbl)) {
    log(list(reason_eliminated = "search info not collected"))
    return(tibble())
  }
  log(list(type_proportion = count_pct(tbl, search_conducted)))
  threshold <- 0.5
  if (coverage_rate(tbl$search_conducted) < threshold) {
    pct <- threshold * 100
    msg <- sprintf("search_conducted non-null less than %g%% of the time", pct)
    log(list(reason_eliminated = msg))
    return(tibble())
  }
  tbl <- filter(tbl, !is.na(search_conducted))
  tbl
}


filter_to_discretionary_searches <- function(tbl, log) {
  if (!("search_basis") %in% colnames(tbl)) {
    log(list(missing_info = "search basis not given; keeping all searches"))
    return(tbl)
  }
  if (tbl$state[1] == "IL") {
    log(list(exception = 
      "search basis unreliable (see data readme); keeping all searches"
    ))
    return(tbl)
  }
  log(list(type_proportion = tbl %>% 
             filter(search_conducted) %>% 
             count_pct(search_basis)
  ))
  threshold <- 0.5
  if (tbl %>% 
      filter(search_conducted) %>% 
      pull(search_basis) %>% 
      coverage_rate() < threshold) {
    pct <- threshold * 100
    msg <- sprintf(
      "search_basis non-null less than %g%% of the time when search_conducted;
      keeping all searches", pct)
    log(list(reason_eliminated = msg))
    return(tbl)
  }
  # NOTE: Excludes "other" (i.e., arrest/warrant, probation/parole, inventory)
  tbl <- filter(tbl, is.na(search_basis) | search_basis %in% 
                  c("plain view", "consent", "probable cause", "k9"))
  tbl
}


filter_to_sufficient_contraband_info <- function(tbl, log) {
  if (!("contraband_found") %in% colnames(tbl)) {
    log(list(reason_eliminated = "contraband info not collected"))
    return(tibble())
  }
  log(list(coverage = count_pct(tbl, search_conducted, contraband_found)))
  threshold <- 0.5
  if (tbl %>% 
        filter(search_conducted) %>% 
        pull(contraband_found) %>% 
        coverage_rate() < threshold) { 
    pct <- threshold * 100
    msg <- sprintf(
      "contraband_found non-null less than %g%% of the time when search_conducted", 
      pct
    )
    log(list(reason_eliminated = msg))
    return(tibble())
  }
  tbl
}
