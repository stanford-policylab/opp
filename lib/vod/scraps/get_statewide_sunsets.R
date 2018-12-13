suppressMessages(source(here::here("lib", "opp.R")))
suppressMessages(source(here::here("lib", "veil_of_darkness_test.R")))

# COUNTY_FILE <- here::here("data", "state_centroids.rds")
# STATE_FILE <- here::here("data", "stateFIPS.csv")

print("loading data...")
states <- read_rds(here::here("cache", "states_wsunset.rds"))

print("getting intertwilight zone by county")
intertwilight <-
  states %>% 
  group_by(geo_control) %>% 
  summarise(
    min_dusk = min(dusk_minute),
    max_sunset = max(sunset_minute)
  )

print("filtering to county-level intertwilight zone")
states <-
  states %>% 
  left_join(intertwilight, by = "geo_control") %>% 
  filter(minute > min_dusk, minute < max_sunset)

# counties <- 
#   read_rds(COUNTY_FILE) %>% 
#   transmute(
#     FIPS = parse_number(STATEFP),
#     county = str_to_lower(as.character(NAME)),
#     county = if_else(str_detect(county, "county"), county, str_c(county, " county")),
#     lat = parse_number(INTPTLAT),
#     lng = parse_number(INTPTLON)
#   )
# 
# fips <-
#   read_csv(STATE_FILE) %>% 
#   transmute(FIPS = parse_number(STATE), state = STUSAB)
# 
# state_abbs <- c("AZ", "CT", "MI", "MT", "ND", "OH", "TN", "TX", "WY", "WI")
# get_statewide <- function(state) {
#   print(str_c("loading ", state))
#   opp_load_data(state, city = "statewide") %>% 
#     mutate(state = state) %>% 
#     filter(year(date) >= 2010)
# }
# 
# state_data <- map_dfr(state_abbs, get_statewide)
# 
# print("adding lat/lng to subgeographies...")
# 
# states <-
#   state_data %>% 
#   select(-lat, -lng) %>% 
#   mutate(
#     county_name = str_to_lower(county_name),
#     county = if_else(str_detect(county_name, "county"), county_name, str_c(county_name, " county"))
#   ) %>%
#   left_join(fips, by = "state") %>% 
#   left_join(counties, by = c("FIPS", "county")) %>% 
#   unite("geo_control", state, county, remove = FALSE) %>% 
#   mutate(subgeography = geo_control)
# 
# print("saving data with lat/lng")
# 
# write_rds(states, here::here("cache", "states_aggregated.rds"))
# 
# print("adding sunset times")
# states_wsunset <- add_sunset_times(states, metadata = list(), multi_tz = TRUE)

print("saving data...")
write_rds(states, here::here("cache", "states_wsunset.rds"))