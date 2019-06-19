library(housingData) # loads geoCounty which has county lat/lng centroids
source(here::here("lib", "opp.R"))
source(here::here("lib", "veil_of_darkness_test.R"))

veil_of_darkness_daylight_savings <- function() {
  if(!exists("VOD_ELIGIBLE_CITIES") | !exists("VOD_ELIGIBLE_STATES"))
    source(here::here("lib", "eligible_locations.R"))
  
  VOD_ELIGIBLE_CITIES <- VOD_ELIGIBLE_CITIES %>% select(state, city)
  VOD_ELIGIBLE_STATES <- VOD_ELIGIBLE_STATES %>% select(state, city)
  
  tbl <- prepare_veil_of_darkness_data(
    only_cities = VOD_ELIGIBLE_CITIES,
    only_states = VOD_ELIGIBLE_STATES,
    dst = T,
    week_radius = 3
  )
  
  print("Running model...")
  # Run actual test
  coefficients <- 
    par_pmap(
      mc.cores = 3,
      tibble(
        degree = rep(1:6, 4), 
        interact = c(rep(T, 12), rep(F, 12)),
        agency = rep(c(rep(T, 6), rep(F, 6)), 2)
      ),
      function(degree, interact, agency) {
        vod_coef(dst = T, tbl, geography, degree, interact, agency) %>% 
          mutate(
            data = "counties and cities",
            base_controls = "time, location, season, year",
            agency_control = agency,
            interact_time_loc = interact,
            spline_degree = degree
          )
      }
    ) %>% bind_rows()
  
  d <- list(coefficients = coefficients, data = tbl)
  
  write_rds(d, here::here("cache", "vod_dst_sweep.rds"))
  d
}

veil_of_darkness_full <- function() {
  if(!exists("VOD_ELIGIBLE_CITIES") | !exists("VOD_ELIGIBLE_STATES"))
    source(here::here("lib", "eligible_locations.R"))
  
  VOD_ELIGIBLE_CITIES <- VOD_ELIGIBLE_CITIES %>% select(state, city)
  VOD_ELIGIBLE_STATES <- VOD_ELIGIBLE_STATES %>% select(state, city)
  
  tbl <- prepare_veil_of_darkness_data(
    only_cities = VOD_ELIGIBLE_CITIES,
    only_states = VOD_ELIGIBLE_STATES, 
    dst = F
  )
  
  coefficients <-
    par_pmap(
      mc.cores = 3,
      tibble(degree = rep(6, 3), interact = rep(T, 3)),
      function(degree, interact) {
        bind_rows(
          vod_coef(dst = F, tbl, geography, degree, interact),
          vod_coef(
            dst = F, 
            filter(tbl, is_state_patrol), 
            geography, 
            degree, interact
          ),
          vod_coef(
            dst = F, 
            filter(tbl, !is_state_patrol), 
            geography, 
            degree, interact
          )
        ) %>%
          mutate(
            data = c(
              "counties and cities",
              "states",
              "cities"
            ),
            ### TODO(amy): do we want year too?
            base_controls = "time, geography",
            spline_degree = degree,
            interact_time_loc = interact
          )
      }
    ) %>% bind_rows()
  
  list(
    coefficients = coefficients, 
    plots = list(
      states = compose_vod_plots(
        filter(tbl, is_state_patrol), 
        state
      ),
      cities = compose_vod_plots(
        filter(tbl, !is_state_patrol), 
        geography
      )
    )
  )
}

prepare_veil_of_darkness_data <- function(
  only_cities = NULL, only_states = NULL,
  dst = F, week_radius = 2
) {
  bind_rows(
    prepare_veil_of_darkness_cities(
      only_cities,
      include_sg = F, 
      dst = dst,
      week_radius = week_radius,
      min_stops_per_race = 100,
      max_geos_per_super = 1
    ) %>%
      mutate(is_state_patrol = F),
    prepare_veil_of_darkness_states(
      only_states,
      dst = dst,
      week_radius = week_radius,
      min_stops_per_race = 100,
      max_geos_per_super = 20
    ) %>%
      mutate(is_state_patrol = T)
  )
  
}

prepare_veil_of_darkness_cities <- function(
  only = NULL,
  include_sg = T, 
  dst = F,
  week_radius = 2,
  min_stops_per_race = 200,
  max_geos_per_super = 1
) {
  
  city_geocodes <-
    read_csv(here::here("resources", "city_coverage_geocodes.csv")) %>%
    separate(loc, c("city", "state"), sep = ",") %>%
    rename(center_lat = lat, center_lng = lng)
  
  print("Loading city data..")
  tbl <- load_veil_of_darkness_cities(dst, only) %>% 
    left_join(city_geocodes) %>%
    mutate(city_state = str_c(city, state, sep = ", "))
  
  if(include_sg) {
    print("creating subgeography data..")
    tbl_sg <-
      tbl %>%
      filter(
        !(city == "Nashville"    & precinct == "U"),
        !(city == "Arlington"    & !(district %in% c("N", "E", "S", "W"))),
        !(city == "Louisville"   & !str_detect(division, "DIVISION")),
        !(city == "Plano"        & sector == "9999"),
        !(city == "Philadelphia" & district == "77")
      ) %>%
      mutate(
        subgeography = case_when(
          city == "Bakersfield"     ~ beat,
          # NOTE: LA "region" could be used but needs major clean-up (has 75,
          # but could probably be trimmed to 15-20)
          city == "San Diego"       ~ service_area,
          city == "San Francisco"   ~ district,
          city == "Aurora"          ~ district,
          city == "Hartford"        ~ district,
          city == "Louisville"      ~ division,
          city == "Owensboro"       ~ sector,
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
      max_geos_per_super = max_geos_per_super
    )
  
  if(include_sg) {
    vod_tbl_sg <- prepare_vod_data(
      tbl_sg %>% rename(geography = city_state)
    )$data
    vod_tbl_sg_plus <- prepare_vod_data(
      tbl_sg %>% rename(geography = city_state_subgeography)
    )$data
    
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
  only = NULL,
  dst = F,
  week_radius = 2,
  min_stops_per_race = 200,
  max_geos_per_super = 20
) {
  
  state_geocodes <-
    geoCounty %>% 
    filter(state %in% VOD_ELIGIBLE_STATES$state) %>% 
    select(state, county_name = county, center_lat = lat, center_lng = lon) %>% 
    mutate(
      # to match how states were processed, where McHenry, ND is Mchenry, ND
      county_name = str_to_title(county_name),
      # to match how states were processed, where St. Johns, FL is St Johns, FL
      county_name = str_replace_all(county_name, "\\.", ""),
      county_state = str_c(county_name, state, sep = ", "),
      city = "Statewide"
    )
    # read_rds(here::here("resources", "state_county_geocodes.rds")) %>%
    # rename(county_state = loc)
  
  print("Loading state data...")
  tbl <- 
    load_veil_of_darkness_states(dst, only) %>%
    left_join(
      state_geocodes, 
      by = c("state", "county_name")
    ) %>% 
    rename(geography = county_state)
  
  print("preparing state data for vod analysis..")
  
  tbl <- tbl %>% 
    prepare_vod_data(
      state, 
      dst_filter = dst,
      super_geo_col = state,
      week_radius = week_radius,
      min_stops_per_race = min_stops_per_race,
      max_geos_per_super = max_geos_per_super
    )
  
  tbl$data
}

load_veil_of_darkness_cities <- function(dst_filters = F, only) {
  d <- opp_load_all_clean_data(only = only) %>%
    mutate(yr = year(date)) %>% 
    filter(type == "vehicular", yr >= 2011, yr <= 2018)
  if(!dst_filters){
    tbl <- d %>% 
      filter(
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
        | (city == "Madison"        & yr %in% 2010:2016)
        # NOTE: the above contains all valid years for each location, but
        # limiting to 2011-2018 to be less affected by locations with many more
        # years of data; incidentally, the 95% CI for the is_dark coefficient is
        # virtually identical using all valid years for all locations vs. only
        # 2011-2018
      ) 
  }
  else { # DST FILTERS
    # Spring DST is always March 8-14, fall DST is Nov 1-7; we thus restrict
    # to full Feb 15-April 15-years and full Oct-Nov-years
    # GENERAL RULE: remove ranges more than 2sd deviations outside normal stop 
    # count for a 60 period
    tbl <- select_data_with_dst_ranges(d, "dist_hist_cities.rds") 
  }
  tbl 
}

load_veil_of_darkness_states <- function(dst_filters = F, only) {
  d <- opp_load_all_clean_data(only = only) %>%
    mutate(yr = year(date)) %>% 
    filter(type == "vehicular", yr >= 2011, yr <= 2018) %>% 
    opp_filter_out_non_highway_patrol_stops_from_states()
  
  if(!dst_filters) {
    tbl <- d %>%
      filter(
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
      ) 
  }
  else { # DST FILTERS
    # Spring DST is always March 8-14, fall DST is Nov 1-7; we thus restrict
    # to full Feb 15-April 15-years and full Oct-Nov-years
    # GENERAL RULE: remove ranges more than 2sd deviations outside normal stop 
    # count for a 60 period
    tbl <- select_data_with_dst_ranges(d) 
    # EXCEPTIONS: (TODO) SD, spring 2017
  }
  tbl 
}


select_data_with_dst_ranges <- function(d, plot_path = NULL) {
  d <- d %>% 
    mutate(
      yr = year(date),
      day = day(date), 
      month = month(date),
      spring_range = month %in% 2:4 & !(month == 2 & day < 15)
      & !(month == 4 & day > 15),
      fall_range = month %in% 10:11
    ) 
  stops_per_range <- d %>% 
    count(state, city, yr, month, date) %>% 
    group_by(state, city, yr, month) %>% 
    summarize(
      avg_stops_per_day = sum(n)/n(),
      avg_stops_per_dst_range = 60 * avg_stops_per_day
    ) %>% 
    group_by(state, city, yr) %>% 
    summarize(
      sd_per_dst_range = sd(avg_stops_per_dst_range),
      avg_stops_per_dst_range = mean(avg_stops_per_dst_range)
    )
  tbl <- d %>% 
    filter(spring_range | fall_range) 
  
  full_ranges <- tbl %>% 
    count(state, city, yr, spring_range, fall_range) %>% 
    left_join(stops_per_range) %>% 
    filter(
      n > avg_stops_per_dst_range - 3*sd_per_dst_range,
      n < avg_stops_per_dst_range + 3*sd_per_dst_range
    )
  if (not_null(plot_path)) {
    p <- tbl %>% 
      count(state, city, yr, spring_range, fall_range, date) %>% 
      ggplot(aes(date, n, fill = spring_range)) + 
      geom_col() + 
      facet_grid(rows = vars(city), cols = vars(yr), scales = "free")
    write_rds(tbl, here::here("cache", plot_path))
  }
  tbl %>%
    inner_join(full_ranges)
}

vod_coef <- function(
  dst = F, 
  tbl, 
  control_col, 
  degree, 
  interact_time_location,
  interact_dark_agency
) {
  control_colq <- enquo(control_col)
  if(dst) {
    mod <-
      dst_model(
        tbl, 
        degree = degree, 
        interact_dark_agency = interact_dark_agency,
        interact_time_location = interact_time_location
      ) 
  } else {
    mod <- 
      train_vod_model(
      tbl,
      !!control_colq,
      spline_degree = degree,
      interact_time_location = interact_time_location
    )
  }
  broom::tidy(mod) %>% 
    filter(term == "is_darkTRUE") %>% 
    select(is_dark = estimate, std_error = std.error)
}

