source("eligible_location_generator.R")

all_cities <- coverage(
  locations = opp_available() %>% filter(city != "Statewide"),
  years = 2011:2018,
  vehicular_only = T,
  exclude_non_highway_patrol_from_states = T,
  only_analysis_demographics = T,
  cast_unk_race_to_na = T
)

all_states <- coverage(
  locations = opp_available() %>% filter(city == "Statewide"),
  years = 2011:2018,
  vehicular_only = T,
  exclude_non_highway_patrol_from_states = T,
  only_analysis_demographics = T,
  cast_unk_race_to_na = T
)

#################
###### VOD ######
#################

VOD_ELIGIBLE_CITIES <- 
  all_cities %>% 
  ### GENERAL RULE:
  filter(
    subject_race >= 0.8,
    date >= 0.95,
    time >= 0.95
  ) %>% 
  mutate(no_hispanics = race_hispanic == 0) %>% 
  select(state, city, full_universe = universe, no_hispanics) %>% 
  ### SPECIFIC CAVEATS:
  bind_rows(
    # only has 70% race coverage (66% relevant race coverage), but we include it
    tibble(
      state = "MN", city = "Saint Paul", 
      full_universe = FALSE, no_hispanics = FALSE
    )
  ) %>% 
  mutate(
    # We have information on arrests (5%), but no data on whether the remaining
    # stops include warnings our not
    full_universe = if_else(city == "Philadelphia", NA, full_universe)
  )
  ### OTHER NOTES:
  # Oakland: 2013 is missing the first 3 months of data and 2015 is missing the 
  #          last 3 months of data
  # San Diego: 2017 only has data for part of the year
  # San Jose: 2013 and 2018 only have partial data
  # Hartford: 2013 and 2016 have only partial data
  # Louisville: 2018 has data only from January
  # Owensboro: 2015 and 2017 only have data for part of the year
  # New Orleans: 2018 only has partial data
  # Durham: Missing data from May 2013
  # Greensboro: Missing data 8/2015, 11/2015, 11/2016, and 3/2014
  # Raleigh: Missing data 11/2012, 9/2013, 11/2013, 7/2014, 10/2014, 10/2015
  # Winston-Salem: Missing data 8/2014, 1/2015, 2/2015, and 5/2015
  # Henderson: 2012 has no or very little data for July, August, and September, 
  #            we have an outstanding inquiry as to why
  # Cincinnati: 2018 only has partial data, and there is Hispanic data for
  #             2009-10, but 0 occurrences for the rest of the data
  # Oklahoma City: the last few months of 2017 are missing
  # Philadelphia: 2018 has only partial data, and it appears to be the 
  #               same for early 2014
  # Pittsburgh: 2018 only has the first 4 months
  # Garland: 2012 and 2018 have only partial data
  # San Antonio: 2018 has only the first 4 months of data
  # Madison: 2017 is missing October, November, and December


VOD_ELIGIBLE_STATES <- 
  all_states %>% 
  ### GENERAL RULE:
  filter(
    subject_race >= 0.8,
    date >= 0.95,
    time >= 0.95
  ) %>% 
  mutate(no_hispanics = race_hispanic == 0) %>% 
  select(state, city, full_universe = universe, no_hispanics) %>% 
  ### SPECIFIC CAVEATS:
  filter(
    # County is not present in these datasets, making geocoding nontrivial;
    # but they'd be fine to include if future analysis has the time to do so
    !state %in% c("IL", "NJ", "RI", "VT")
  ) %>% 
  bind_rows(
    # NOTE: WA only has 72% race coverage (70% relevant race coverage), but we 
    #       include it
    tibble(
      state = "WA", city = "Statewide", 
      full_universe = TRUE, no_hispanics = FALSE
    )
    # NOTE: CO has 75% relevant race coverage, but time of stop is not recorded
  )
  ### OTHER NOTES:
  # AZ: There is a two-week period in Oct 2012 and a two-week period in Nov 2013 
  #     when no stops are recorded. We also are missing Dec 2015.
  # NY: The data stops at 2017-12-14.

####################
### DISPARITY ######
####################

# NOTE: AZ, MA, and VT also have contraband info and thus could have these
# tests run, but for various reasons (contraband info unreliable or messy,
# or too large a white population to be able to compare at the county level)
# we omit them because we wouldn't trust analysis on those states.
DISPARITY_ELIGIBLE_STATES <- tribble(
  ~state, ~city,
  "CO", "Statewide",
  "CT", "Statewide",
  "IL", "Statewide", # don't use search_basis (too sparse.)
  "NC", "Statewide",
  "RI", "Statewide",
  "SC", "Statewide",
  "TX", "Statewide",
  "WA", "Statewide",
  "WI", "Statewide"
)

# NOTE: Cities in NC can also be used for aggregate disparity tests, but
# do not have sub-geography and thus we do not use them in our paper.
DISPARITY_ELIGIBLE_CITIES <- tribble(
  ~state, ~city,
  "CA", "San Diego",
  "CA", "San Francisco",
  "LA", "New Orleans",
  "PA", "Philadelphia",
  "TN", "Nashville",
  "TX", "San Antonio"
)

#################
###### MJ #######
#################

MJ_ELIGIBLE_STATES <- 
  all_states %>% 
  ### GENERAL RULE:
  filter(
    # NOTE: this race cutoff is needed to include CO and WA; all other states
    #       included are >= 0.849
    subject_race >= 0.7, 
    date >= 0.95,
    search_conducted >= 0.5,
    year(start_date) <= 2012,
    year(end_date) > 2012
  ) %>% 
  mutate(no_hispanics = race_hispanic == 0) %>% 
  select(state, city, full_universe = universe, no_hispanics) %>% 
  ### SPECIFIC CAVEATS:
  filter(
    !state %in% c("IL", "MD", "MO", "NE")
    # IL: Search recording policy changes year to year, making time series
    #     analysis unreliable.
    # MD: Before 2013, we were only given annual data
    # MO: All annual data
    # NE: Unreliable quarterly dates (in 2012, all ptrol stops are listed as Q1)
  )
  #va??: Only data for citations and searches without further action taken. 
  #       No record of warnings
