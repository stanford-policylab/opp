suppressMessages(source(here::here("lib", "opp.R")))
suppressMessages(source(here::here("lib", "veil_of_darkness_test.R")))

load_city_cache <- function() {
  eligible_cities <-
    tribble(
      ~state, ~city,
      "AZ",    "Mesa"         ,
      "CA",    "San Francisco",
      "CA",    "San Jose"     ,
      "CO",    "Aurora"       ,
      "KS",    "Wichita"      ,
      "LA",    "New Orleans"  ,
      "MN",    "Saint Paul"   ,
      "ND",    "Grand Forks"  ,
      "OH",    "Columbus"     ,
      "OK",    "Oklahoma City",
      "OK",    "Tulsa"        ,
      "PA",    "Philadelphia" ,
      "TN",    "Nashville"    ,
      "TX",    "Arlington"    ,
      "TX",    "San Antonio"  ,
      "VT",    "Burlington"   ,
      "WI",    "Madison"
    )
  
  cities <- 
    opp_load_all_data(only=eligible_cities) %>% 
    mutate(subgeography = city) %>% 
    filter(!(city == "Madison" & year(date) %in% c(2007, 2008))) # bad years of data
  
  metadata = list()
  cities_wsunset <-
    add_sunset_times(
      cities,
      metadata = metadata
    )
  
  write_rds(cities_wsunset, here::here("cache", "aggregated_cities_wsunset.Rds"))
  
  subgeos <-
    cities_wsunset %>%
    group_by(city) %>%
    summarise_at(
      vars(
        region,
        precinct,
        reporting_area,
        district,
        beat,
        sector,
        police_grid_number
      ),
      n_distinct,
      na.rm = TRUE
    ) %>%
    gather(-city, key = "subgeo", value = "n_distinct") %>%
    filter(
      n_distinct >= 5, n_distinct <= 30
    ) %>%
    select(-n_distinct)
  
  
  get_subgeo_cities <- function(name) {
    subgeos %>%
      filter(subgeo == name) %>%
      pull(city)
  }
  
  region_cities <- get_subgeo_cities("region")
  precinct_cities <- get_subgeo_cities("precinct")
  district_cities <- get_subgeo_cities("district")
  beat_cities <- get_subgeo_cities("beat")
  sector_cities <- get_subgeo_cities("sector")
  
  cities_wsunset_and_subgeo <-
    cities_wsunset %>%
    filter(city %in% pull(subgeos, city)) %>%
    mutate(
      subgeography = city,
      geo_control_var = case_when(
        city %in% region_cities ~ region,
        city %in% precinct_cities ~ precinct,
        city %in% district_cities ~ district,
        city %in% beat_cities ~ beat,
        city %in% sector_cities ~ sector
      )
    ) %>%
    filter(!is.na(subgeography)) %>%
    unite("geo_control", city, geo_control_var, remove = FALSE)
  
  write_rds(cities_wsunset_and_subgeo, here::here("cache", "aggregated_cities_wsunset_and_subgeo.Rds"))
}

# NOTE: to load the state cache you must have the files 
# "state_centroids.rds" and "stateFIPS.csv" in the data/ directory
load_state_cache <- function() {
  COUNTY_FILE <- here::here("data", "state_centroids.rds") # Figure out what to do with these
  STATE_FILE <- here::here("data", "stateFIPS.csv")
  STATE_ABBS <- c("AZ", "CT", "MI", "MT", "ND", "OH", "TN", "TX", "WY", "WI")
  
  print("loading data...")
  
  counties <-
    read_rds(COUNTY_FILE) %>%
    transmute(
      FIPS = parse_number(STATEFP),
      county = str_to_lower(as.character(NAME)),
      county = if_else(str_detect(county, "county"), county, str_c(county, " county")),
      lat = parse_number(INTPTLAT),
      lng = parse_number(INTPTLON)
    )

  fips <-
    read_csv(STATE_FILE) %>%
    transmute(FIPS = parse_number(STATE), state = STUSAB)

  
  get_statewide <- function(state) {
    print(str_c("loading ", state))
    opp_load_data(state, city = "statewide") %>%
      mutate(state = state) %>%
      filter(year(date) >= 2010) # reduce size of data for efficiency
  }

  state_data <- map_dfr(STATE_ABBS, get_statewide)

  print("adding county lat/lng...")

  states <-
    state_data %>%
    select(-lat, -lng) %>%
    mutate(
      county_name = str_to_lower(county_name),
      county = if_else(str_detect(county_name, "county"), county_name, str_c(county_name, " county"))
    ) %>%
    left_join(fips, by = "state") %>%
    left_join(counties, by = c("FIPS", "county")) %>%
    unite("geo_control", state, county, remove = FALSE) %>%
    mutate(subgeography = geo_control)

  print("adding sunset times")
  states_wsunset <- add_sunset_times(states, metadata = list())
  
  print("saving data...")
  write_rds(states, here::here("cache", "states_wsunset.rds"))
}

run_city_analysis <- function() {
  data_no_geo <-
    read_rds(here::here("cache", "aggregated_cities_wsunset.Rds"))
  data <-
    read_rds(here::here("cache", "aggregated_cities_wsunset_and_subgeo.Rds"))
  
  print("running regression on all stops without subgeography...")
  results_no_geo <- veil_of_darkness_test(data_no_geo, has_sunset_times = TRUE)
  print("regression complete")
  
  print("writing results")
  write_rds(results_no_geo$data, here::here("cache", "vod_no_geo_data.Rds"))
  write_rds(results_no_geo$models, here::here("cache", "vod_no_geo_models.Rds"))
  write_rds(results_no_geo$results, here::here("cache", "vod_no_geo_results.Rds"))
  
  print("running regression on all stops with subgeography...")
  results_full <- veil_of_darkness_test(data, has_sunset_times = TRUE, has_geo_control = TRUE)
  print("regression complete")
  
  print("writing results")
  write_rds(results_full$data, here::here("cache", "vod_full_data.Rds"))
  write_rds(results_full$models, here::here("cache", "vod_full_models.Rds"))
  write_rds(results_full$results, here::here("cache", "vod_full_results.Rds"))

  print("running regression on DST period without subgeography...")
  results_dst_no_geo <- veil_of_darkness_test(
    data_no_geo,
    has_sunset_times = TRUE,
    filter_to_DST = TRUE
  )
  print("regression complete")
  
  print("writing results")
  write_rds(results_dst_no_geo$fall_data, here::here("cache", "vod_dst_no_geo_fall_data.Rds"))
  write_rds(results_dst_no_geo$spring_data, here::here("cache", "vod_dst_no_geo_spring_data.Rds"))
  write_rds(results_dst_no_geo$fall, here::here("cache", "vod_dst_no_geo_fall.Rds"))
  write_rds(results_dst_no_geo$spring, here::here("cache", "vod_dst_no_geo_spring.Rds"))
    
  print("running regression on DST period with subgeography...")
  results_dst <- veil_of_darkness_test(
    data,
    has_sunset_times = TRUE,
    has_geo_control = TRUE,
    filter_to_DST = TRUE
  )
  print("regression complete")
  
  print("writing results")
  write_rds(results_dst$fall_data, here::here("cache", "vod_dst_fall_data.Rds"))
  write_rds(results_dst$spring_data, here::here("cache", "vod_dst_spring_data.Rds"))
  write_rds(results_dst$fall, here::here("cache", "vod_dst_fall.Rds"))
  write_rds(results_dst$spring, here::here("cache", "vod_dst_spring.Rds"))
  
  print("running city level regressions all stops without subgeography...")
  reg <- function(city_name){
    print(str_c("running regression on ", city_name))
    results <-
      data %>%
      filter(city == city_name) %>%
      veil_of_darkness_test(has_sunset_times = TRUE, has_geo_control = FALSE)
    
    broom::tidy(results$models$model_time_const) %>%
      filter(term == "is_darkTRUE") %>%
      mutate(city = city_name)
  }
  
  by_city_no_geo <-
    data %>%
    distinct(city) %>%
    pull(city) %>% 
    map_dfr(~reg(.))
  
  print("writing results")
  write_rds(by_city_no_geo, here::here("cache", "vod_no_geo_by_city.Rds"))
  
  print("running city level regressions all stops with subgeography...")
  reg <- function(city_name){
    print(str_c("running regression on ", city_name))
    results <-
      data %>%
      filter(city == city_name) %>%
      veil_of_darkness_test(has_sunset_times = TRUE, has_geo_control = TRUE)
    
    broom::tidy(results$models$model_geo_adjusted) %>%
      filter(term == "is_darkTRUE") %>%
      mutate(city = city_name)
  }
  
  by_city <-
    subgeos %>%
    pull(city) %>%
    map_dfr(~reg(.))
  
  print("writing results")
  write_rds(by_city, here::here("cache", "vod_geo_adj_by_city.Rds"))
  
  print("running city level regressions DST with subgeography...")
  reg_dst <- function(city_name){
    print(str_c("running DST regression on ", city_name))
    results <-
      data %>%
      filter(city == city_name) %>%
      veil_of_darkness_test(has_sunset_times = TRUE, has_geo_control = TRUE, filter_to_DST = TRUE)
    
    rbind(
      broom::tidy(results$fall$model_geo_adjusted) %>%
        filter(term == "is_darkTRUE") %>%
        mutate(season = "spring", city = city_name),
      broom::tidy(results$spring$model_geo_adjusted) %>%
        filter(term == "is_darkTRUE") %>%
        mutate(season = "fall", city = city_name)
    )
  }
  
  by_city_dst <-
    subgeos %>%
    pull(city) %>%
    map_dfr(~reg_dst(.))
  
  print("writing results")
  write_rds(by_city_dst, here::here("cache", "vod_dst_by_city.Rds"))
  print("done")
}

run_state_analysis <- function() {
  print("loading data...")
  data <-
    read_rds(here::here("cache", "states_wsunset.rds"))

  print("running regression on all stops...")
  results_full <- veil_of_darkness_test(data, has_sunset_times = TRUE, has_geo_control = TRUE)
  print("regression complete")

  print("writing results")
  # Note we only write the tidied tibbles to file because the full model objects are enormous
  model_time_adj <- broom::tidy(results_full$models$model_time_const)
  model_time_geo_adj <- broom::tidy(results_full$models$model_geo_adjusted)
  model_month_adj <- broom::tidy(results_full$models$model_month_adjusted)
  
  write_rds(model_time_adj, here::here("cache", "vod_statewide_time_const.rds"))
  write_rds(model_time_geo_adj, here::here("cache", "vod_statewide_geo_adj.rds"))
  write_rds(model_month_adj, here::here("cache", "vod_statewide_month_adj.Rds"))

  print("running regression on DST period...")
  results_dst <- veil_of_darkness_test(
    data,
    has_sunset_times = TRUE,
    has_geo_control = TRUE,
    filter_to_DST = TRUE
  )
  print("regression complete")

  print("writing results")
  write_rds(results_dst$fall, here::here("cache", "vod_statewide_dst_fall.Rds"))
  write_rds(results_dst$spring, here::here("cache", "vod_statewide_dst_spring.Rds"))
  
  print("running state level regressions...")
  reg <- function(state){
    print(str_c("running regression on ", state))
    results <-
      data %>%
      filter(state == state) %>%
      veil_of_darkness_test(has_sunset_times = TRUE, has_geo_control = TRUE)
    
    broom::tidy(results$models$model_geo_adjusted) %>%
      filter(term == "is_darkTRUE") %>%
      mutate(state = state)
  }
  
  by_state <-
    data %>%
    distinct(state) %>%
    pull(state) %>%
    map_dfr(~reg(.))
  
  print("writing results")
  write_rds(by_state, here::here("cache", "vod_geo_adj_by_state.Rds"))
  print("done")
}

## Uncomment the lines below to run:

# load_city_cache()
# load_state_cache() # VERY LARGE DATASET - TAKES A LONG TIME
# run_city_analysis()
# run_state_analysis() # THIS FUNCTION MAY TAKE DAYS TO RUN