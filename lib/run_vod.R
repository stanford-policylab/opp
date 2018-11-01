source(here::here("lib", "opp.R"))
source(here::here("lib", "veil_of_darkness_test.R"))

eligible_cities <- tribble(
  ~state, ~city,
  "WI", "Madison",
  "KY", "Owensboro",
  "KS", "Wichita",
  "VT", "Burlington",
  "WI", "Green Bay"
)
cities <- opp_load_all_data(only=eligible_cities)

metadata = list()
cities <- add_sunset_times(
  cities,
  metadata = metadata,
  multi_tz = TRUE
)
write_rds(cities, here::here("cache", "white_cities_wsunset.Rds"))