source("opp.R")
source("veil_of_darkness_test.R")


veil_of_darkness_cities <- function(output_dir = NULL) {
  # NOTE: all of these places have date and time at least 95% of the time and
  # subject_race at least 80% of the time
  tbl <- tribble(
    ~state, ~city, ~center_lat, ~center_lng,
    "AZ", "Mesa", 33.4151843, -111.8314724,
    "CA", "Bakersfield", 35.393528, -119.043732,
    "CA", "San Diego", 32.715736, -117.161087,
    "CA", "San Francisco", 37.7749295, -122.4194155,
    "CA", "San Jose", 37.3382082, -121.8863286,
    "CO", "Aurora", 39.7294319, -104.8319195,
    "CT", "Hartford", 41.763710, -72.685097,
    "KS", "Wichita", 37.68717609999999, -97.33005299999999,
    "KY", "Owensboro", 37.7719074, -87.1111676,
    "LA", "New Orleans", 29.95106579999999, -90.0715323,
    "MN", "Saint Paul", 44.9537029, -93.0899578,
    "NC", "Charlotte", 35.2270869, -80.8431267,
    "NC", "Durham", 35.994034, -78.898621,
    "NC", "Fayetteville", 35.0526641, -78.87835849999999,
    "NC", "Greensboro", 36.0726354, -79.7919754,
    "NC", "Raleigh", 35.7795897, -78.6381787,
    "ND", "Grand Forks", 47.9252568, -97.0328547,
    "NJ", "Camden", 39.9259463, -75.1196199,
    "OH", "Cincinnati", 39.1031182, -84.5120196,
    "OH", "Columbus", 39.9611755, -82.99879419999999,
    "OK", "Oklahoma City", 35.4675602, -97.5164276,
    "OK", "Tulsa", 36.1539816, -95.99277500000001,
    "PA", "Philadelphia", 39.9525839, -75.1652215,
    "TN", "Nashville", 36.1626638, -86.7816016,
    "TX", "Arlington", 32.735687, -97.10806559999999,
    "TX", "Plano", 33.0198431, -96.6988856,
    "TX", "San Antonio", 29.4241219, -98.49362819999999,
    "VT", "Burlington", 44.4758825, -73.21207199999999,
    "WI", "Madison", 43.0730517, -89.4012302
  )

  tbl <-
    select(tbl, state, city) %>%
    opp_load_all_clean_data() %>%
    filter(
      type == "vehicular",
      # NOTE: only keep years with complete data
      (city == "Mesa"             & year(date) %in% 2014:2016)
      | (city == "Bakersfield"    & year(date) %in% 2010:2017)
      | (city == "San Diego"      & year(date) %in% 2014:2016)
      | (city == "San Francisco"  & year(date) %in% 2007:2015)
      | (city == "San Jose"       & year(date) %in% 2014:2017)
      | (city == "Aurora"         & year(date) %in% 2012:2016)
      | (city == "Hartford"       & year(date) %in% 2014:2015)
      | (city == "Wichita"        & year(date) %in% 2006:2016)
      | (city == "New Orleans"    & year(date) %in% 2010:2017)
      | (city == "Saint Paul"     & year(date) %in% 2001:2016)
      | (city == "Charlotte"      & year(date) %in%
        setdiff(2002:2015, 2008)
      )
      | (city == "Durham"         & year(date) %in%
        setdiff(2002:2015, c(2008, 2009, 2010, 2013))
      )
      | (city == "Fayetteville"   & year(date) %in% setdiff(2002:2015, 2009))
      | (city == "Greensboro"     & year(date) %in%
        setdiff(2002:2015, c(2005, 2006, 2010, 2014, 2015))
      )
      | (city == "Raleigh"        & year(date) %in% 2010:2011)
      | (city == "Grand Forks"    & year(date) %in% 2007:2016)
      | (city == "Camden"         & year(date) %in% 2014:2017)
      | (city == "Cincinnati"     & year(date) %in% 2009:2017)
      | (city == "Columbus"       & year(date) %in% 2012:2016)
      | (city == "Oklahoma City"  & year(date) %in% 2012:2016)
      | (city == "Tulsa"          & year(date) %in% 2009:2016)
      | (city == "Philadelphia"   & year(date) %in% 2015:2017)
      | (city == "Nashville"      & year(date) %in% 2010:2016)
      | (city == "Arlington"      & year(date) %in% 2016:2016)
      | (city == "Plano"          & year(date) %in% 2012:2015)
      | (city == "San Antonio"    & year(date) %in% 2012:2017)
      | (city == "Burlington"     & year(date) %in% 2012:2017)
      | (city == "Madison"        & year(date) %in% 2010:2016),
      # NOTE: the above contains all valid years for each location, but
      # limiting to 2012-2017 to be less affected by locations with many more
      # years of data; incidentally, the 95% CI for the is_dark coefficient is
      # virtually identical using all valid years for all locations vs. only
      # 2012-2017
      year(date) >= 2012,
      year(date) <= 2017
    ) %>%
    left_join(tbl) %>%
    mutate(city_state = str_c(city, state, sep = ", "))

  tbl_subgeography <-
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
    tbl_subgeography %>%
    group_by(city_state) %>%
    summarize(
      subgeography_coverage = sum(!is.na(city_state_subgeography)) / n()
    ) %>%
    # TODO(danj): does 80% make sense?
    filter(subgeography_coverage > 0.80) %>%
    pull(city_state)

  print("Eligible subgeography locations: ")
  print(eligible_subeography_locations)

  tbl_subgeography <-
    tbl_subgeography %>%
    filter(city_state %in% eligible_subeography_locations)

  coefficients <- bind_rows(
    par_pmap(
      mc.cores = 3,
      tibble(degree = rep(1:6, 2), interact = c(rep(T, 6), rep(F, 6))),
      function(degree, interact) {
        bind_rows(
          vod_coef(tbl, city_state, degree, interact),
          vod_coef(tbl_subgeography, city_state, degree, interact),
          vod_coef(tbl_subgeography, city_state_subgeography, degree, interact)
        ) %>%
        rename(
          is_dark = Estimate,
          std_error = `Std. Error`
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
    )
  )

  plots <-
    prepare_vod_data(
      tbl,
      city_state,
      lat_col = center_lat,
      lng_col = center_lng
    )$data %>%
    compose_vod_plots()

  results <- list(
    coefficients = coefficients,
    plots = plots
  )

  if (!is.null(output_dir))
    saveRDS(results, file.path(output_dir, "vod.rds"))

  results
}


vod_coef <- function(tbl, control_col, degree, interact) {
  control_colq <- enquo(control_col)
  summary(veil_of_darkness_test(
    tbl,
    !!control_colq,
    # NOTE: use city centers instead of stop lat/lng since sunset times
    # don't vary that much within a city and it speeds things up
    lat_col = center_lat,
    lng_col = center_lng,
    spline_degree = degree,
    interact = interact
  )$results$model)$coefficients[2, 1:2]
}


veil_of_darkness_cities_daylight_savings <- function() {
  # TODO(danj)
}


veil_of_darkness_states <- function() {
  # NOTE: all of these places have date and time at least 95% of the time and
  # subject_race at least 80% of the time
  # NOTE: IL, NJ, RI, VT are elligible too, but geocoding is nontrivial, 
  # because county isn't present
  tbl <- read_rds(here::here("data", "state_county_geocodes.rds"))
  
  all_data <-
    tbl %>% 
    select(state, city) %>%
    opp_load_all_clean_data() %>% 
    filter(
      type == "vehicular",
      # NOTE: only keep years with complete data between 2012 and 2017
      # runs through nov 2015 (keep dec 2011 to be able to keep 2015)
      (state == "AZ"      & ((year(date) == 2011 & month(date) == 12)
                          | (year(date) %in% 2012:2014)
                          | (year(date) == 2015 & month(date) <= 11)))
      # runs oct 2013 to sept 2015
      | (state == "CT"    & !(year(date) == 2015 & month(date) > 9))
      # runs through oct 2016 (keep nov/dec 2011 to be able to keep 2016)
      | (state == "FL"    & ((year(date) == 2011 & month(date) >= 11)
                             | (year(date) %in% 2012:2015)
                             | (year(date) == 2016 & month(date) <= 10)))
      # | (state == "IL"    & year(date) %in% setdiff(2012:2017, 2013))
      | (state == "MI"    & year(date) %in% 2013:2015)
      | (state == "MT"    & year(date) %in% 2012:2016)
      | (state == "ND"    & year(date) %in% 2012:2014)
      # | (state == "NJ"    & year(date) %in% 2012:2016)
      # runs through nov 2017 (keep dec 2011 to be able to keep 2017)
      | (state == "NY"      & ((year(date) == 2011 & month(date) >= 12)
                               | (year(date) %in% 2012:2016)
                               | (year(date) == 2017 & month(date) <= 11)))
      | (state == "OH"    & year(date) %in% 2012:2015)
      # | (state == "RI"    & year(date) %in% 2012:2015)
      | (state == "TN"    & year(date) %in% 2012:2015)
      | (state == "TX"    & year(date) %in% 2012:2017)
      # | (state == "VT"    & year(date) %in% 2012:2015)
      | (state == "WI"    & year(date) %in% 2012:2015)
      | (state == "WY"    & year(date) == 2012)
    )
  
  print("data loaded")
  
  all_data <-
    all_data %>% 
    left_join(
      tbl %>% rename(county_state = loc), 
      by = c("state", "city", "county_name")
    ) %>% 
    filter(county_state %in% 
             eligible_sgs(all_data)#, max_counties_per_state = 20)
    )
  
  # bind_rows(
  #   par_pmap(
  #     tibble(interact = c(T, F)),
  #     function(interact) {
    print("Starting vod, without subgeo")
    
        without_subgeo <- summary(veil_of_darkness_test(
          d,
          state,
          # NOTE: use county centers instead of stop lat/lng since sunset times
          # don't vary that much within a county and it speeds things up
          lat_col = center_lat,
          lng_col = center_lng,
          spline_degree = 6,
          interact = F
        )$results$model)$coefficients[2, 1:2]
        
        without_subgeo %>% write_rds(here::here("cache", "vod_1krace_no_int_no_subgeo.rds"))
        
      print("Starting vod, with subgeo")
        
        with_subgeo <- summary(veil_of_darkness_test(
          tbl,
          county_state,
          lat_col = center_lat,
          lng_col = center_lng,
          spline_degree = 6,
          interact = F
        )$results$model)$coefficients[2, 1:2]
        
        with_subgeo %>% write_rds(here::here("cache", "vod_1krace_no_int_w_subgeo.rds"))
  #       bind_rows(
  #         without_subgeo,
  #         with_subgeo
  #       ) %>%
  #         rename(
  #           is_dark = Estimate,
  #           std_error = `Std. Error`
  #         ) %>%
  #         mutate(
  #           data = c(
  #             "county",
  #             "county"
  #           ),
  #           controls = c(
  #             "time, state",
  #             "time, county_state"
  #           ),
  #           spline_degree = 6,
  #           interact = interact
  #         )
  #     }
  #   )
  # ) 
}

# selects the top `max_counties` number of counties with at least `min_stops` 
# number of stops per demographic in `eligible demographics`
eligible_counties <- function(
  tbl,
  state_col = state,
  sub_geography_col = county_name, 
  unique_geo_col = county_state, 
  demographic_col = subject_race,
  eligible_demographics = c("white", "black"),
  min_stops = 1000,
  max_counties = 50
) {
  state_colq <- enquo(state_col)
  sub_geography_colq <- enquo(sub_geography_col)
  unique_geo_colq <- enquo(county_state_col)
  demographic_colq <- enquo(demographic_col)

  sub_geographies_with_sufficient_stops <-
    tbl %>%
    filter(!!demographic_colq %in% eligible_demographics) %>% 
    count(!!county_state_colq, !!demographic_colq) %>% 
    spread(!!demographic_colq, n, fill = 0) %>% 
    filter_at(
      vars(2:(length(eligible_demographics) + 1)), 
      all_vars(. > min_stops)
    ) %>% 
    pull(!!county_state_colq)
  
  tbl %>%
    filter(
      !!county_state_colq %in% sub_geographies_with_sufficient_stops
    ) %>%
    count(!!state_colq, !!sub_geography_colq, !!county_state_colq) %>%
    top_n(max_counties, n) %>% 
    pull(!!county_state_colq)
}


veil_of_darkness_states_daylight_savings <- function() {
  # TODO(amyshoe)
}
