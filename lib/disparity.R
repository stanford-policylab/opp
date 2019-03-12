source(here::here("lib", "opp.R"))
source(here::here("lib", "outcome_test.R"))
source(here::here("lib", "threshold_test.R"))
source(here::here("lib", "disparity_plot.R"))

# NOTE: AZ, MA, OH, and VT also have contraband info and thus could have these
# tests run, but for various reasons (contraband info unreliable or messy,
# or too large a white population to be able to compare at the county level)
# we omit them because we wouldn't trust analysis on those states.
ELIGIBLE_STATES <- tribble(
  ~state, ~city,
  "CO", "Statewide",
  "CT", "Statewide",
  "IL", "Statewide",
  "NC", "Statewide",
  "RI", "Statewide",
  "SC", "Statewide",
  "TX", "Statewide",
  "WA", "Statewide",
  "WI", "Statewide"
)

# NOTE: Cities in NC can also be used for aggregate disparity tests, but
# do not have sub-geography and thus we do not use them in our paper.
ELIGIBLE_CITIES <- tribble(
  ~state, ~city,
  "CA", "San Diego",
  "CA", "San Francisco",
  "LA", "New Orleans",
  "PA", "Philadelphia",
  "TN", "Nashville",
  "TX", "San Antonio"
)


main <- function() {
  datasets <- list()
  print("Preparing data...")
  datasets$state <- load_eligible_state_disparity_data()
  datasets$city <- load_eligible_city_disparity_data()
 
  results <- list()
  for (dataset_name in names(datasets)) {
    sprintf("Using %s data...", dataset_name)
    v <- list()
    print("Running outcome test...")
    v$outcome <- outcome_test(
      datasets[[dataset_name]],
      sub_geography,
      geography_col = geography
    )
    print("Composing outcome plots...")
    v$outcome$plots <- plt_all(v$outcome$results$hit_rates, "outcome")
    v$outcome$plots$aggregate <- 
      plt(
        v$outcome$results$hit_rates, 
        str_c("outcome aggregate: ", dataset_name)
      )
  
    print("Running threshold test...")
    v$threshold <- threshold_test(
      datasets[[dataset_name]],
      sub_geography,
      geography_col = geography
    )
    print("Composing threshold plots...")
    v$threshold$plots <- plt_all(v$threshold$results$thresholds, "threshold")
    v$threshold$plots$aggregate <- 
      plt(
        v$threshold$results$thresholds, 
        str_c("threshold aggregate: ", dataset_name)
      )
    
    results[[dataset_name]] <- v
  }
  results  
}

load_eligible_city_disparity_data <- function() {
  opp_load_all_clean_data(only=ELIGIBLE_CITIES) %>%
    filter(
      ifelse(
        # NOTE: years 2014, 2016
        city == "San Diego",
        # NOTE: 2015 only has 64.4% coverage of variables we care about
        # 2014 has over 70%
        year(date) != 2015
        # NOTE: these service areas have insufficient data
        # NOTE: 130 just is insufficient for whites, but makes results misleading
        & !(service_area %in% c("130", "530", "630", "840", "Unknown")),
        T
      ),
      # NOTE: 
      ifelse(
        city == "San Francisco",
        # NOTE: 2014 has no sub-geography
        year(date) != 2014
        # NOTE: these districts have insufficient data
        & !(district %in% c("K", "S", "T")),
        T
      ),
      ifelse(
        city == "New Orleans",
        # NOTE: data outside this range is sparse and/or unavailable
        as.yearmon(date) >= as.yearmon("2013-05")
        & as.yearmon(date) <= as.yearmon("2018-06"),
        T
      ),
      ifelse(
        city == "Philadelphia",
        # NOTE: this districts have insufficient data for hispanics
        # We remove so results are over-interpreted
        !(district == "05" & subject_race == "hispanic"),
        T
      ),
      ifelse(
        city == "Nashville",
        # NOTE: U stands for Unknown, remove these
        precinct != "U",
        T
      ),
      # NOTE: San Antonio looks good
      # NOTE: remove these to compare only blacks/hispanics with whites
      !(subject_race %in% c("asian/pacific islander", "other/unknown")),
      year(date) >= 2011,
      year(date) <= 2017,
      type == "vehicular"
    ) %>%
    mutate(
      sg = NA_character_,
      sg = if_else(city == "San Diego", service_area, sg),
      sg = if_else(city == "San Francisco", district, sg),
      sg = if_else(city == "New Orleans", district, sg),
      sg = if_else(city == "Philadelphia", district, sg),
      sg = if_else(city == "Nashville", precinct, sg),
      sg = if_else(city == "San Antonio", substation, sg)
    ) %>%
    unite(
      col = geography, 
      state, city, 
      remove = FALSE
    ) %>% 
    rename(
      sub_geography = sg
    )
}

load_eligible_state_disparity_data <- function() {
  print("Loading eligible states...")
  opp_load_all_clean_data(only=ELIGIBLE_STATES) %>% 
    filter(
      # NOTE: Remove CO stops for which a search was conducted but we don't 
      # have contraband recovery info
      !(state == "CO" & (search_conducted & is.na(contraband_found))),
      
      # NOTE: use just CT state patrol stops
      !(state == "CT" & department_name != "State Police"),
      
      # NOTE: use just IL state patrol stops
      # NOTE: we're missing IL state patrol stops from 2013
      !(state == "IL" & department_name != "ILLINOIS STATE POLICE"),
      
      # NOTE: use just NC state patrol stops
      !(state == "NC" & department_name != "NC State Highway Patrol"),
      
      # NOTE: Remove SC collision stops because they seem qualitatively different 
      # (They also have a 3x search rate and lower hit rate, too, and a larger 
      # white and hispanic demographic, so including these could lead to 
      # misleading results.)
      !(state == "SC" & reason_for_stop == "Collision"),
      
      # NOTE: WI 2010 data is too sparse to trust
      !(state == "WI" & year(date) <= 2010),
      
      subject_race %in% c("black", "white", "hispanic"),
      type == "vehicular"
    ) %>%
    mutate(
      # If a search was conducted but we don't have contraband info,
      # assume no contraband was found (unless dealt with otherwise above)
      contraband_found = if_else(
        search_conducted,
        replace_na(contraband_found, FALSE),
        contraband_found
      ),
      sg = NA_character_,
      sg = if_else(state == "CO", county_name, sg),
      sg = if_else(state == "CT", county_name, sg),
      sg = if_else(state == "IL", beat, sg),
      sg = if_else(state == "NC", county_name, sg),
      sg = if_else(state == "RI", zone, sg),
      sg = if_else(state == "SC", county_name, sg),
      sg = if_else(state == "TX", county_name, sg),
      sg = if_else(state == "WA", county_name, sg),
      sg = if_else(state == "WI", county_name, sg)
    ) %>%
    filter(
      # VALID DATE RANGE: 2011-2017
      # NOTE: any anomalies within 2011-2017 are dealt with state by
      # state in the state-by-state filters above
      year(date) >= 2011, year(date) <= 2017,
      !is.na(sg)
    ) %>% 
    filter(
      if_else(state == "CO", sg %in% eligible_sgs(., "CO"), T),
      if_else(state == "CT", sg %in% eligible_sgs(., "CT"), T),
      if_else(state == "IL", sg %in% eligible_sgs(., "IL"), T),
      if_else(state == "NC", sg %in% eligible_sgs(., "NC"), T),
      if_else(state == "RI", sg %in% eligible_sgs(., "RI"), T),
      if_else(state == "SC", sg %in% eligible_sgs(., "SC"), T),
      if_else(state == "TX", sg %in% eligible_sgs(., "TX"), T),
      if_else(state == "WA", sg %in% eligible_sgs(., "WA"), T),
      if_else(state == "WI", sg %in% eligible_sgs(., "WI"), T)
    ) %>% 
    rename(
      sub_geography = sg,
      geography = state
    ) 
}

# selects the top `max_sub_geographies` number of sub geographies with at 
# least `min_stops` number of stops per demographic in `eligible demographics`
eligible_sgs <- function(
  tbl,
  state_abbr,
  sub_geography_col = sg, 
  demographic_col = subject_race,
  eligible_demographics = c("white", "black", "hispanic"),
  action_col = search_conducted,
  min_stops = 500,
  min_actions = 0,
  max_sub_geographies = 100
) {
  sub_geography_colq <- enquo(sub_geography_col)
  demographic_colq <- enquo(demographic_col)
  action_colq <- enquo(action_col)
  tbl <- tbl %>% filter(state == state_abbr)
  sub_geographies_with_sufficient_stops <-
    tbl %>%
    filter(!!demographic_colq %in% eligible_demographics) %>% 
    count(!!sub_geography_colq, !!demographic_colq) %>% 
    spread(!!demographic_colq, n, fill = 0) %>% 
    filter_at(
      vars(2:(length(eligible_demographics) + 1)), 
      all_vars(. > min_stops)
    ) %>% 
    pull(!!sub_geography_colq)
  sub_geographies_with_sufficient_actions <-
    tbl %>%
    filter(!!action_colq, !!demographic_colq %in% eligible_demographics) %>%
    count(!!sub_geography_colq, !!demographic_colq) %>%
    filter(n > min_actions) %>%
    pull(!!sub_geography_colq)
  
  tbl %>%
    filter(
      !!sub_geography_colq %in% sub_geographies_with_sufficient_stops,
      !!sub_geography_colq %in% sub_geographies_with_sufficient_actions
    ) %>%
    count(!!sub_geography_colq) %>%
    top_n(max_sub_geographies, n) %>% 
    pull(!!sub_geography_colq)
}

plt <- function(d, prefix) {
  if (str_detect(prefix, "outcome")) {
    p <- disparity_plot(d, geography, sub_geography, title = prefix)
  } else {
    p <- disparity_plot(
      d, geography, sub_geography,
      rate_col = threshold,
      size_col = n_action,
      title = prefix,
      axis_title = "threshold"
    )
  }
  p
}

plt_all <- function(tbl, prefix) {
  f <- function(grp) {
    str_geo <- unique(grp$geography)
    title <- str_c(prefix, ": ", str_geo)
    if (str_detect(prefix, "outcome")) {
      p <- disparity_plot(
        grp, geography, sub_geography, 
        title = str_c(str_geo, " hit rates")
      )
    } else {
      p <- disparity_plot(
        grp,
        geography, sub_geography,
        demographic_col = subject_race,
        rate_col = threshold,
        size_col = n_action,
        title = str_c(str_geo, " thresholds"),
        axis_title = "threshold"
      )
    }
    p
  }
  tbl %>% 
    group_by(geography) %>% 
    do(plot = f(.)) %>% 
    ungroup() %>% 
    translator_from_tbl(
      "geography",
      "plot"
    )
}
