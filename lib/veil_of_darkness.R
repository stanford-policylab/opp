library(here)
source(here::here("lib", "opp.R"))
source(here::here("lib", "veil_of_darkness_test.R"))


ELIGIBLE_CITIES <- tribble(
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
  ~state, ~city,
  "AZ", "Statewide",
  "CT", "Statewide",
  "FL", "Statewide",
  "MI", "Statewide",
  "MT", "Statewide",
  "ND", "Statewide",
  "NY", "Statewide",
  "OH", "Statewide",
  "TN", "Statewide",
  "TX", "Statewide",
  "WI", "Statewide",
  "WY", "Statewide"
)


veil_of_darkness_cities <- function() {
  # NOTE: all of these places have date and time at least 95% of the time and
  # subject_race at least 80% of the time

  city_geocodes <-
    read_csv(here::here("resources", "city_coverage_geocodes.csv")) %>%
    separate(loc, c("city", "state"), sep = ",") %>%
    rename(center_lat = lat, center_lng = lng)

  tbl <-
    opp_load_all_clean_data(only = ELIGIBLE_CITIES) %>%
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
    left_join(city_geocodes) %>%
    mutate(city_state = str_c(city, state, sep = ", ")) %>%
    prepare_vod_data(city_state)

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

  print("eligible subgeography locations: ")
  print(eligible_subeography_locations)

  tbl_subgeography <-
    tbl_subgeography %>%
    filter(city_state %in% eligible_subeography_locations) %>%
    prepare_vod_data(city_state_subgeography)
  
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

  list(coefficients = coefficients, plots = compose_vod_plots(tbl))
}


vod_coef <- function(tbl, control_col, degree, interact) {
  control_colq <- enquo(control_col)
  summary(train_vod_model(
    tbl,
    !!control_colq,
    spline_degree = degree,
    interact = interact
  ))$coefficients[2, 1:2]
}


veil_of_darkness_cities_daylight_savings <- function() {
  # TODO(danj)
}


veil_of_darkness_states <- function() {
  # NOTE: all of these places have date and time at least 95% of the time and
  # subject_race at least 85% of the time
  # NOTE: IL, NJ, RI, VT are elligible too, but geocoding is nontrivial, 
  # because county isn't present
  tbl <-
    opp_load_all_clean_data(only = ELIGIBLE_STATES) %>% 
    filter(
      type == "vehicular",
      # NOTE: only keep years with complete data between 2012 and 2017
      # runs through nov 2015 (keep dec 2011 to be able to keep 2015)
      (state == "AZ"      & ((year(date) == 2011 & month(date) == 12)
                          | (year(date) %in% 2012:2014)
                          | (year(date) == 2015 & month(date) <= 11)))
      # runs oct 2013 to sept 2015
      | (state == "CT"    & !(year(date) == 2015 & month(date) > 9)
                          & department_name == "State Police")
      # runs through oct 2016 (keep nov/dec 2011 to be able to keep 2016)
      | (state == "FL"    & ((year(date) == 2011 & month(date) >= 11)
                             | (year(date) %in% 2012:2015)
                             | (year(date) == 2016 & month(date) <= 10)))
      | (state == "MI"    & year(date) %in% 2013:2015)
      | (state == "MT"    & year(date) %in% 2012:2016)
      | (state == "ND"    & year(date) %in% 2012:2014)
      # runs through nov 2017 (keep dec 2011 to be able to keep 2017)
      | (state == "NY"      & ((year(date) == 2011 & month(date) >= 12)
                               | (year(date) %in% 2012:2016)
                               | (year(date) == 2017 & month(date) <= 11)))
      | (state == "OH"    & year(date) %in% 2012:2015)
      | (state == "TN"    & year(date) %in% 2012:2015)
      | (state == "TX"    & year(date) %in% 2012:2017)
      | (state == "WI"    & year(date) %in% 2012:2015)
      | (state == "WY"    & year(date) == 2012)
    ) %>%
    left_join(
      read_rds(here::here("resources", "state_county_geocodes.rds")) %>%
        rename(county_state = loc), 
      by = c("state", "city", "county_name")
    ) %>% 
    filter(
      county_state %in% eligible_counties(
        ., 
        min_stops_per_race = 1000,
        max_counties_per_state = 20
      )
    ) %>%
    prepare_vod_data(county_state)

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
  
  list(coefficients = coefficients, plots = compose_vod_plots(tbl))
}


eligible_counties <- function(
  tbl,
  state_col = state,
  county_col = county_name, 
  unique_geo_col = county_state, 
  demographic_col = subject_race,
  eligible_demographics = c("white", "black"),
  min_stops_per_race = 1000,
  max_counties_per_state = 50
) {
  # selects the top `max_counties` number of counties with at least `min_stops`
  # number of stops per demographic in `eligible demographics`
  state_colq <- enquo(state_col)
  county_colq <- enquo(county_col)
  unique_geo_colq <- enquo(unique_geo_col)
  demographic_colq <- enquo(demographic_col)

  counties_with_sufficient_stops <-
    tbl %>%
    filter(!!demographic_colq %in% eligible_demographics) %>% 
    count(!!unique_geo_colq, !!demographic_colq) %>% 
    spread(!!demographic_colq, n, fill = 0) %>% 
    filter_at(
      vars(2:(length(eligible_demographics) + 1)), 
      all_vars(. > min_stops_per_race)
    ) %>% 
    pull(!!unique_geo_colq)
  
  tbl %>%
    filter(
      !!unique_geo_colq %in% counties_with_sufficient_stops
    ) %>%
    count(!!state_colq, !!county_colq, !!unique_geo_colq) %>%
    group_by(!!state_colq) %>% 
    top_n(max_counties_per_state, n) %>% 
    pull(!!unique_geo_colq)
}


veil_of_darkness_states_daylight_savings <- function() {
  # TODO(amyshoe)
}
