suppressMessages(source(here::here("lib", "opp.R")))
suppressMessages(source(here::here("lib", "veil_of_darkness_test.R")))

# coverage <- read_rds(here::here("cache", "oldcoverage.rds"))
# 
# eligible_cities <-
#   coverage %>%
#   mutate(
#     date = parse_number(date),
#     time = parse_number(time),
#     subject_race = parse_number(subject_race),
#     geolocation = parse_number(geolocation)
#   ) %>%
#   filter_at(
#     vars(date, time, subject_race, geolocation),
#     all_vars(. > 75)
#   ) %>%
#   select(state, city)
# 
# cities_w_data_problems <- c("Green Bay", "Dallas", "Camden", "Bakersfield", "Little Rock", "Plano", "Hartford", "Owensboro", "El Paso")

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
  mutate(subgeography = city)

metadata = list()
cities_wsunset <-
  add_sunset_times(
    cities,
    metadata = metadata
  )

write_rds(cities_wsunset, here::here("cache", "aggregated_cities_wsunset.Rds"))