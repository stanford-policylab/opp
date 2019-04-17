source(here::here("lib", "opp.R"))
source(here::here("lib", "veil_of_darkness_test.R"))


START_YR <- 2011
END_YR <- 2017

# TODO(danj): add los angeles
ELIGIBLE_CITIES <- tribble(
  # NOTE: all of these places have date and time at least 95% of the time and
  # subject_race at least 80% of the time
  ~state, ~city,
  "AZ", "Mesa",
  "CA", "Bakersfield",
  "CA", "San Diego",
  "CA", "San Francisco",
  "CA", "San Jose",
  "CO", "Aurora",
  "CT", "Hartford",
  "KS", "Wichita",
  "KY", "Owensboro",
  "LA", "New Orleans",
  "MN", "Saint Paul",
  "NC", "Charlotte",
  "NC", "Durham",
  "NC", "Fayetteville",
  "NC", "Greensboro",
  "NC", "Raleigh",
  "ND", "Grand Forks",
  "NJ", "Camden",
  "OH", "Cincinnati",
  "OH", "Columbus",
  "OK", "Oklahoma City",
  "OK", "Tulsa",
  "PA", "Philadelphia",
  "TN", "Nashville",
  "TX", "Arlington",
  "TX", "Plano",
  "TX", "San Antonio",
  "VT", "Burlington",
  "WI", "Madison"
)


ELIGIBLE_STATES <- tribble(
  # NOTE: all of these places have date and time at least 95% of the time and
  # subject_race at least 85% of the time
  # NOTE: IL, NJ, RI, VT are elligible too, but geocoding is nontrivial, 
  # because county isn't present
  ~state, ~city,
  "AZ", "Statewide",
  "CT", "Statewide",
  "FL", "Statewide",
  "MT", "Statewide",
  "ND", "Statewide",
  "NY", "Statewide",
  "OH", "Statewide",
  "TN", "Statewide",
  "TX", "Statewide",
  "WI", "Statewide",
  "WY", "Statewide"
)

veil_of_darkness_daylight_savings <- function() {
  
  tbl <- prepare_veil_of_darkness_data(
    dst = T,
    week_radius = 4
  )
  print("Geographies after load:")
  print(unique(tbl$geography))
  print("Number of states:")
  print(tbl %>% filter(is_state_patrol) %>% select(state) %>% n_distinct())
  print("Number of cities:")
  print(tbl %>% filter(!is_state_patrol) %>% select(geography) %>% n_distinct())
  
  print("Running model...")
  # Run actual test
  mod <- dst_model(
    tbl, 
    degree = 6, 
    interact_dark_patrol = T,
    interact_time_location = T
  )
  print("Saving model...")
  write_rds(mod, here::here("cache", str_c("dst_mod_full.rds")))
}

prepare_veil_of_darkness_data <- function(dst = F, week_radius = 2) {
  bind_rows(
    prepare_veil_of_darkness_cities(
      include_sg = F, 
      dst = dst,
      week_radius = week_radius,
      min_stops_per_race = 100,
      max_geos_per_state = 1
    ) %>%
      mutate(is_state_patrol = F),
    prepare_veil_of_darkness_states(
      dst = dst,
      week_radius = week_radius,
      min_stops_per_race = 100,
      max_geos_per_state = 20
    ) %>%
      mutate(is_state_patrol = T)
  )
  
}

load_veil_of_darkness_cities <- function() {
  opp_load_all_clean_data(only = ELIGIBLE_CITIES) %>%
    mutate(yr = year(date)) %>%
    filter(
      type == "vehicular",
      # NOTE: only keep years with complete data
      (city == "Mesa"             & yr %in% 2014:2016)
      | (city == "Bakersfield"    & yr %in% 2010:2017)
      | (city == "San Diego"      & yr %in% 2014:2016)
      | (city == "San Francisco"  & yr %in% 2007:2015)
      | (city == "San Jose"       & yr %in% 2014:2017)
      | (city == "Aurora"         & yr %in% 2012:2016)
      | (city == "Hartford"       & yr %in% 2014:2015)
      | (city == "Wichita"        & yr %in% 2006:2016)
      | (city == "New Orleans"    & yr %in% 2010:2017)
      | (city == "Saint Paul"     & yr %in% 2001:2016)
      | (city == "Charlotte"      & yr %in% setdiff(2002:2015, 2008))
      | (city == "Durham"         & yr %in%
           setdiff(2002:2015, c(2008, 2009, 2010, 2013))
      )
      | (city == "Fayetteville"   & yr %in% setdiff(2002:2015, 2009))
      | (city == "Greensboro"     & yr %in%
           setdiff(2002:2015, c(2005, 2006, 2010, 2014, 2015))
      )
      | (city == "Raleigh"        & yr %in% 2010:2011)
      | (city == "Grand Forks"    & yr %in% 2007:2016)
      | (city == "Camden"         & yr %in% 2014:2017)
      | (city == "Cincinnati"     & yr %in% 2009:2017)
      | (city == "Columbus"       & yr %in% 2012:2016)
      | (city == "Oklahoma City"  & yr %in% 2012:2016)
      | (city == "Tulsa"          & yr %in% 2009:2016)
      | (city == "Philadelphia"   & yr %in% 2015:2017)
      | (city == "Nashville"      & yr %in% 2010:2016)
      | (city == "Arlington"      & yr %in% 2016:2016)
      | (city == "Plano"          & yr %in% 2012:2015)
      | (city == "San Antonio"    & yr %in% 2012:2017)
      | (city == "Burlington"     & yr %in% 2012:2017)
      | (city == "Madison"        & yr %in% 2010:2016),
      # NOTE: the above contains all valid years for each location, but
      # limiting to 2011-2017 to be less affected by locations with many more
      # years of data; incidentally, the 95% CI for the is_dark coefficient is
      # virtually identical using all valid years for all locations vs. only
      # 2012-2017
      yr >= START_YR,
      yr <= END_YR
    ) 
}

load_veil_of_darkness_states <- function() {
  opp_load_all_clean_data(only = ELIGIBLE_STATES) %>% 
    filter(
      type == "vehicular",
      # NOTE: only keep years with complete data between 2011 and 2017
      # runs through nov 2015 (keep dec 2011 to be able to keep 2015)
      # Rest of 2011 seems like ramp-up period
      (state == "AZ"      & ((year(date) == 2011 & month(date) == 12)
                             | (year(date) %in% 2012:2014)
                             | (year(date) == 2015 & month(date) <= 11)))
      # runs oct 2013 to sept 2015
      | (state == "CT"    & !(year(date) == 2015 & month(date) > 9)
         & department_name == "State Police")
      # runs through oct 2016 (keep nov/dec 2010 to be able to keep 2016)
      | (state == "FL"    & ((year(date) == 2010 & month(date) >= 11)
                             | (year(date) %in% 2011:2015)
                             | (year(date) == 2016 & month(date) <= 10)))
      | (state == "MT"    & year(date) %in% 2011:2016)
      | (state == "ND"    & year(date) %in% 2011:2014)
      # runs through nov 2017 (keep dec 2010 to be able to keep 2017)
      | (state == "NY"      & ((year(date) == 2010 & month(date) >= 12)
                               | (year(date) %in% 2011:2016)
                               | (year(date) == 2017 & month(date) <= 11)))
      | (state == "TX"    & year(date) %in% 2011:2017)
      | (state == "WI"    & year(date) %in% 2011:2015)
      | (state == "WY"    & year(date) %in% 2011:2012)
    ) %>% 
    opp_filter_out_non_highway_patrol_stops_from_states()
}

prepare_veil_of_darkness_cities <- function(
  include_sg = T, 
  dst = F,
  week_radius = 2,
  min_stops_per_race = 1000,
  max_geos_per_state = 1
) {
  
  city_geocodes <-
    read_csv(here::here("resources", "city_coverage_geocodes.csv")) %>%
    separate(loc, c("city", "state"), sep = ",") %>%
    rename(center_lat = lat, center_lng = lng)
  
  print("Loading city data..")
  tbl <- load_veil_of_darkness_cities() %>% 
    left_join(city_geocodes) %>%
    mutate(city_state = str_c(city, state, sep = ", "))
  
  if(include_sg) {
    print("creating subgeography data..")
    tbl_sg <-
      tbl %>%
      filter(
        !(city == "Nashville" & precinct == "U"),
        !(city == "Arlington" & !(district %in% c("N", "E", "S", "W"))),
        !(city == "Plano"     & sector == "9999")
      ) %>%
      mutate(
        subgeography = case_when(
          city == "Bakersfield"     ~ beat,
          city == "San Diego"       ~ service_area,
          city == "San Francisco"   ~ district,
          city == "Aurora"          ~ district,
          city == "Hartford"        ~ district,
          city == "New Orleans"     ~ district,
          city == "Saint Paul"      ~ police_grid_number,
          # NOTE: beat is 75% null
          city == "Cincinnati"      ~ beat,
          # NOTE: 5 zones and ~9 precincts
          city == "Columbus"        ~ zone,
          city == "Philadelphia"    ~ district,
          # NOTE: 8 precincts, but 50+ reporting areas and zones each
          city == "Nashville"       ~ precinct,
          # NOTE: 4 districts, 40 beats
          city == "Arlington"       ~ district,
          # NOTE: 4 sectors, 25 beats, both null ~50% of the time
          city == "Plano"           ~ sector,
          # NOTE: 1 substations, 50+ districts
          city == "San Antonio"     ~ substation,
          # NOTE: district 2 is missing from shapefiles so NA; there are 6
          # districts and 50+ sectors
          city == "Madison"         ~ district
        ),
        city_state_subgeography = str_c(city_state, ": ", subgeography)
      )
    
    eligible_subeography_locations <-
      tbl_sg %>%
      group_by(city_state) %>%
      summarize(
        subgeography_coverage = sum(!is.na(city_state_subgeography)) / n()
      ) %>%
      # TODO(danj): does 80% make sense?
      filter(subgeography_coverage > 0.80) %>%
      pull(city_state)
    print("eligible subgeography locations: ")
    print(eligible_subeography_locations)
    tbl_sg <- filter(tbl_sg, city_state %in% eligible_subeography_locations)
  }
  
  print("preparing city data for vod analysis..")
  vod_tbl <- tbl %>% 
    rename(geography = city_state) %>% 
    prepare_vod_data(
      state,
      dst_filter = dst,
      super_geo_col = geography,
      week_radius = week_radius,
      min_stops_per_race = min_stops_per_race,
      max_geos_per_state = max_geos_per_state
    )
  
  if(include_sg) {
    vod_tbl_sg <- prepare_vod_data(tbl_sg, city_state)$data
    vod_tbl_sg_plus <- prepare_vod_data(tbl_sg, city_state_subgeography)$data
  
    list(
      vod_tbl = vod_tbl$data,
      vod_tbl_sg = vod_tbl_sg,
      vod_tbl_sg_plus = vod_tbl_sg_plus
    )
  } else {
    vod_tbl$data
  }
  
}

prepare_veil_of_darkness_states <- function(
  dst = F,
  week_radius = 2,
  min_stops_per_race = 1000,
  max_geos_per_state = 50
) {
  
  state_geocodes <-
    read_rds(here::here("resources", "state_county_geocodes.rds")) %>%
    rename(county_state = loc)
  
  print("Loading state data...")
  tbl <- 
    load_veil_of_darkness_states() %>%
    left_join(
      state_geocodes, 
      by = c("state", "county_name")
    ) %>% 
    rename(geography = county_state)
    # filter(
    #   county_state %in% eligible_counties(
    #     ., 
    #     min_stops_per_race = 100,
    #     max_counties_per_state = 20
    #   )
    # ) 
  
  print("preparing state data for vod analysis..")
  
  tbl <- tbl %>% 
    prepare_vod_data(
      state, 
      dst_filter = dst,
      super_geo_col = state,
      week_radius = week_radius,
      min_stops_per_race = min_stops_per_race,
      max_geos_per_state = max_geos_per_state
    )
  
  tbl$data
}



veil_of_darkness_cities <- function() {
  
  vod_data <- prepare_veil_of_darkness_cities()
  
  vod_tbl <- vod_data$vod_tbl
  vod_tbl_sg <- vod_data$vod_tbl_sg
  vod_tbl_sg_plus <- vod_data$vod_tbl_sg_plus
  
  coefficients <-
    par_pmap(
      mc.cores = 3,
      tibble(degree = c(6, 6), interact = c(T, F)),
      # tibble(degree = rep(1:6, 2), interact = c(rep(T, 6), rep(F, 6))),
      function(degree, interact) {
        bind_rows(
          vod_coef(vod_tbl, city_state, degree, interact),
          vod_coef(vod_tbl_sg, city_state, degree, interact),
          vod_coef(vod_tbl_sg_plus, city_state_subgeography, degree, interact)
        ) %>%
        mutate(
          data = c(
            "all",
            "subgeography",
            "subgeography"
          ),
          controls = c(
            "time, city_state",
            "time, city_state",
            "time, city_state_subgeography"
          ),
          spline_degree = degree,
          interact = interact
        )
      }
    ) %>% bind_rows()

  list(coefficients = coefficients, plots = compose_vod_plots(vod_tbl, city_state))
}

vod_coef <- function(tbl, control_col, degree, interact_time_location) {
  control_colq <- enquo(control_col)
  is_dark_e_sd <- summary(train_vod_model(
    tbl,
    !!control_colq,
    spline_degree = degree,
    interact_time_location = interact_time_location
  ))$coefficients[2, 1:2]
  list(is_dark = is_dark_e_sd[1], std_error = is_dark_e_sd[2])
}


veil_of_darkness_states <- function() {
  
  tbl <- prepare_veil_of_darkness_states()

  coefficients <- bind_rows(
    par_pmap(
      mc.cores = 3,
      tibble(degree = rep(6, 2), interact = c(T, F)),
      function(interact, degree = 6) {
        bind_rows(
          vod_coef(tbl, state, degree, interact),
          vod_coef(tbl, county_state, degree, interact)
        ) %>%
        rename(
          is_dark = Estimate,
          std_error = `Std. Error`
        ) %>%
        mutate(
          controls = c(
            "time, state",
            "time, county_state"
          ),
          spline_degree = degree,
          interact = interact
        )
      }
    )
  )
  
  # list(coefficients = coefficients, plots = compose_vod_plots(tbl, state))
  list(coefficients = coefficients)
}


