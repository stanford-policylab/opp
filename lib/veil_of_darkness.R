source("opp.R")
source("veil_of_darkness_test.R")


veil_of_darkness_cities <- function() {
  # NOTE: all of these places have at least date and time 95% of the time and
  # race at least 80% of the time
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
    "KY", "Owensboro", 
    "LA", "New Orleans", 29.95106579999999, -90.0715323,
    "MN", "Saint Paul", 44.9537029, -93.0899578,
    "NC", "Charlotte",
    "NC", "Durham",
    "NC", "Fayetteville",
    "NC", "Greensboro",
    "NC", "Raleigh",
    "ND", "Grand Forks", 47.9252568, -97.0328547,
    "NJ", "Camden",
    "OH", "Cincinnati",
    "OH", "Columbus",
    "OH", "Columbus", 39.9611755, -82.99879419999999,
    "OK", "Oklahoma City", 35.4675602, -97.5164276,
    "OK", "Tulsa", 36.1539816, -95.99277500000001,
    "PA", "Philadelphia", 39.9525839, -75.1652215,
    "TN", "Nashville", 36.1626638, -86.7816016,
    "TX", "Arlington", 32.735687, -97.10806559999999,
    "TX", "San Antonio", 29.4241219, -98.49362819999999,
    "VT", "Burlington", 44.4758825, -73.21207199999999,
    "WI", "Madison", 43.0730517, -89.4012302
  )

  select(tbl, state, city) %>%
  opp_load_all_clean_data() %>%
  filter(
    type == "vehicular",
    # NOTE: only keep years with complete data
    (city == "Mesa"           & year(date) %in% 2014:2016),
    (city == "Bakersfield"    & year(date) %in% 2010:2017),
    (city == "San Diego"      & year(date) %in% 2014:2016),
    (city == "San Francisco"  & year(date) %in% 2007:2015),
    (city == "San Jose"       & year(date) %in% 2014:2017),
    (city == "Aurora"         & year(date) %in% 2012:2016),
    (city == "Hartford"       & year(date) %in% 2014:2015),
    (city == "Wichita"        & year(date) %in% 2006:2016),
    (city == "New Orleans"    & year(date) %in% 2010:2017),
    (city == "Saint Paul"     & year(date) %in% 2001:2016),
    (city == "Charlotte"      & year(date) %in%
      setdiff(2002:2015, 2008)
    ),
    (city == "Durham"         & year(date) %in%
      setdiff(2002:2015, c(2008, 2009, 2010, 2013))
    ),
    (city == "Fayetteville"   & year(date) %in% setdiff(2002:2015, 2009)),
    (city == "Greensboro"     & year(date) %in%
      setdiff(2002:2015, c(2005, 2006, 2010, 2014, 2015))
    ),
    (city == "Raleigh"        & year(date) %in% 2010:2011),
    (city == "Grand Forks"    & year(date) %in% 2007:2016),
    (city == "Camden"         & year(date) %in% 2014:2017),
    (city == "Cincinnati"     & year(date) %in% 2009:2017),
    (city == "Columbus"       & year(date) %in% 2012:2016),

    (city == "Madison"        & year(date) %in% c(2007, 2008, 2017)),
  ) %>%
  left_join(tbl) %>%
  mutate(city_state = str_c(city, state, sep = ", ")) %>%
  # NOTE: use city centers instead of stop lat/lng since sunset times
  # don't vary that much within a city and it speeds things up
  veil_of_darkness_test(city_state, lat_col=center_lat, lng_col=center_lng)
}


veil_of_darkness_cities_daylight_savings <- function() {
  # TODO(danj)
}


veil_of_darkness_states <- function() {
  # TODO(danj)
}


veil_of_darkness_states_daylight_savings <- function() {
  # TODO(danj)
}
