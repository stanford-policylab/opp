source(here::here("lib", "opp.R"))
source(here::here("lib", "outcome_test.R"))
source(here::here("lib", "threshold_test.R"))
source(here::here("lib", "disparity_plot.R"))


ELIGIBLE_STATES <- tribble(
  ~state, ~city,
  # "AZ", "Statewide",
  "CO", "Statewide",
  "CT", "Statewide",
  "IL", "Statewide",
  # "MA", "Statewide",
  "NC", "Statewide",
  # "OH", "Statewide",
  "RI", "Statewide",
  "SC", "Statewide",
  "TX", "Statewide",
  "WA", "Statewide",
  "WI", "Statewide"
)


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
  dir_create(here::here("cache"))
  args <- get_disparity_args()
  datasets <- list()
  if (not_null(args$state)) {
    if (not_null(args$from_cache))
      datasets$state <- read_rds(here::here("cache", "state_disparity_data.rds"))
    else {
      datasets$state <- load_eligible_state_disparity_data()
      write_rds(datasets$state, here::here("cache", "state_disparity_data.rds"))
    }
  }
  if (not_null(args$city)) {
    if (not_null(args$from_cache))
      datasets$city <- read_rds(here::here("cache", "city_disparity_data.rds"))
    else {
      datasets$city <- load_eligible_city_disparity_data()
      write_rds(datasets$city, here::here("cache", "city_disparity_data.rds"))
    }
  }
  print("Data loaded.")
  results <- list()
  for (dataset_name in names(datasets)) {
    v = list()
    if (not_null(args$outcome)) {
      print("Starting outcome test...")
      v$outcome <- outcome_test(
        datasets[[dataset_name]],
        geography, sub_geography
      )
      print("Plotting aggregate hit rates...")
      plt(v$outcome$results, str_c("outcome aggregate: ", dataset_name))
      print("Plotting indivual hit rates...")
      plt_all(v$outcome$results, "outcome")
      print("Outcome test and plots finished.")
    }
    if (not_null(args$threshold)) {
      print("Starting threshold...")
      v$threshold <- threshold_test(
        datasets[[dataset_name]],
        sub_geography,
        geography_col = geography
      )
      write_rds(v$threshold, here::here("cache", str_c("threshold_results_", dataset_name, ".rds")))
      print("Plotting aggregate thresholds...")
      plt(v$threshold$results$thresholds, str_c("threshold aggregate: ", dataset_name))
      print("Plotting indivual thresholds...")
      plt_all(v$threshold$results$thresholds, "threshold")
      print("Threshold finished.")
    }
    results[[dataset_name]] <- v
  }
  write_rds(results, here::here("cache", "disparity_results.rds"))
  results  
  q(status = 0)
}

get_disparity_args <- function() {
  usage <- str_c("./disparity.R",
                 "[--help]",
                 "[--state]",
                 "[--city]",
                 "[--from_cache]",
                 "[--outcome]",
                 "[--threshold]",
                 sep = " ")
  spec <- tribble(
    ~long_name,   ~short_name,  ~argument_type, ~data_type,
    "help",        "h",         "none",         "logical",
    "state",       "s",         "none",         "logical",
    "city",        "c",         "none",         "logical",
    "from_cache",  "cc",        "none",         "logical",
    "outcome",     "o",         "none",         "logical",
    "threshold",   "t",         "none",         "logical"
  )
  args <- parse_args(spec)
  
  if (not_null(args$help) || length(args) == 1) {
    print(usage)
    q(status = 0)
  }
  
  if (
    (is.null(args$state) && is.null(args$city))
    ||
    (is.null(args$outcome) && is.null(args$threshold))
  ) {
    print(usage)
    print("Must include <state and/or city> and <outcome and/or threshold>")
    q(status = 1)
  }
  
  args
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
      # if_else(
      #   # NOTE: old OPP doesn't use AZ because the contraband data is too messy
      #   # Our contraband data, while indeed a little messy, seems reasonable.
      #   state == "AZ",
      #   # NOTE: remove non-discretionary searches
      #   # & (is.na(search_basis) | search_basis != "other")
      #   # NOTE: 2009 and 2010 have insufficient data
      #   year(date) >= 2011,
      #   T
      # ),
      if_else(
        state == "CO",
        # NOTE: remove non-discretionary searches
        # (is.na(search_basis) | search_basis != "other")
        # NOTE: remove the stops for which a search was conducted but we don't have
        # contraband recovery info
        !(search_conducted & is.na(contraband_found)),
        T
      ),
      if_else(
        state == "CT",
        # NOTE: use just state patrol stops
        department_name == "State Police",
        # NOTE: remove non-discretionary searches (5% of searches)
        # NOTE: keeps searches for which search basis is not given (~7%)
        # & (is.na(search_basis) | search_basis != "other")
        T
      ),
      if_else(
        state == "IL",
        # NOTE: we're missing state patrol stops from 2013
        # NOTE: we don't have information on non-discretionary searches
        # NOTE: use just state patrol stops
        department_name == "ILLINOIS STATE POLICE",
        T
      ),
      
      # MASSACHUSETTS
      # NOTE: old OPP says contraband info is too messy; i want to check this further
      # For now, we include MA, and no filters needed, except:
      # NOTE: remove non-discretionary searches (32% of searches)
      # NOTE: keeps searches for which search basis is not given (~9%)
      # (is.na(search_basis) | search_basis != "other")
      
      if_else(
        state == "NC",
        # NOTE: use just state patrol stops
        department_name == "NC State Highway Patrol",
        # NOTE: remove non-discretionary searches (68% of searches)
        # & (is.na(search_basis) | search_basis != "other")
        T
      ),
      
      # OHIO
      # NOTE: old opp excludes because only search reasons listed are k9 and consent,
      # which they say makes them skeptical of the recording scheme;
      # however, 87% of searches are not labeled -- we call default them to probable cause,
      # but regardless, it seems reasonable to assume that all searches are indeed
      # being tallied up, but i would not trust the search_basis categorization itself.
      # Thus we _do_ use OH in our analysis
      # No filters needed, but some further notes:
      # NOTE: if not listed as k9 or consent search, we deem the search probable cause
      # i.e., we don't know if a search is incident to arrest or not.
      # NOTE: when contraband wasn't found after a search it was labeled NA
      # we fix this after the mega filter statement
      
      # RHODE ISLAND
      # No filters needed, except maybe:
      # NOTE: remove non-discretionary searches (49% of searches)
      # (is.na(search_basis) | search_basis != "other"),
      
      # SOUTH CAROLINA
      if_else(
        state == "SC",
        # NOTE: old opp removed collision stops altogether; we left them in the data for
        # other possible analyses, but for post-stop outcomes, collision stops seem 
        # qualitatively different. (They also have a 3x search rate and lower hit rate, too,
        # and a larger white and hispanic demographic, so including these could lead
        # to misleading results.)
        reason_for_stop != "Collision",
        T
      ),
      
      # TEXAS
      # No filters needed, except maybe:
      # NOTE: remove non-discretionary searches (28% of searches)
      # NOTE: keep searches for which search basis is not given (<<<1%)
      # (is.na(search_basis) | search_basis != "other")
      
      # WASHINGTON
      # No filters needed, except maybe:
      # NOTE: remove non-discretionary searches (95%?!?!?)
      # (is.na(search_basis) | search_basis != "other")
      
      if_else(
        state == "WI",
        # NOTE: 2010 is too sparse to trust
        year(date) > 2010,
        # NOTE: remove non-discretionary searches (33%)
        # NOTE: keep searches for which search basis is not given (<<<1%)
        # & (is.na(search_basis) | search_basis != "other")
        T
      ),
      
      # NOTE: compare only blacks/hispanics with whites
      subject_race %in% c("black", "white", "hispanic"),
      type == "vehicular"
    ) %>%
    mutate(
      # If a search was conducted and we don't have contraband info,
      # assume no contraband was found
      contraband_found = if_else(
        search_conducted,
        replace_na(contraband_found, FALSE),
        contraband_found
      ),
      sg = NA_character_,
      # sg = if_else(state == "AZ", county_name, sg),
      sg = if_else(state == "CO", county_name, sg),
      sg = if_else(state == "CT", county_name, sg),
      sg = if_else(state == "IL", beat, sg),
      # sg = if_else(state == "MA", county_name, sg),
      sg = if_else(state == "NC", county_name, sg),
      # sg = if_else(state == "OH", county_name, sg),
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
      # if_else(state == "AZ", sg %in% eligible_sgs(., "AZ"), T),
      if_else(state == "CO", sg %in% eligible_sgs(., "CO"), T),
      if_else(state == "CT", sg %in% eligible_sgs(., "CT"), T),
      if_else(state == "IL", sg %in% eligible_sgs(., "IL"), T),
      # if_else(state == "MA", sg %in% eligible_sgs(., "MA"), T),
      if_else(state == "NC", sg %in% eligible_sgs(., "NC"), T),
      # if_else(state == "OH", sg %in% eligible_sgs(., "OH"), T),
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

outcome_tests <- function(d) {
  d %>%
    group_by(state, city) %>%
    do(
      outcome_test(., state, city, sub_geography)$results
    ) %>%
    ungroup()
}


threshold_tests <- function(d) {
  # NOTE: Runs threshold test on each location individually.
  # For the multi-location hierarchical threshold test, call
  # threshold_test(...) on the data, directly. 
  d %>%
    group_by(state, city) %>%
    do(
      threshold_test(
        ., state, sub_geography,
        geography_col = city,
        demographic_col = subject_race,
        action_col = search_conducted,
        outcome_col = contraband_found
      )$results$thresholds
    ) %>%
    ungroup()
}


plt_all <- function(tbl, prefix) {
  output_dir <- dir_create(here::here("plots"))
  f <- function(grp) {
    str_geo <- unique(grp$geography)
    title <- str_c(prefix, ": ", str_geo)
    fpath <- path(output_dir, str_c(title, ".pdf"))
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
    ggsave(fpath, p, width=12, height=6, units="in")
    print(str_c("saved: ", fpath))
    grp
  }
  group_by(tbl, geography) %>% do(f(.)) %>% ungroup()
}


plt <- function(d, prefix) {
  output_dir <- dir_create(here::here("plots"))
  fpath <- path(output_dir, str_c(prefix, ".pdf"))
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
  ggsave(fpath, p, width=12, height=6, units="in")
  print(str_c("saved: ", fpath))
  p
}
