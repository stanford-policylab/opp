coverage <- read_rds(here::here("cache", "coverage.rds"))

eligible_cities <-
  coverage %>%
  mutate(
    date = parse_number(date),
    time = parse_number(time),
    subject_race = parse_number(subject_race),
    geolocation = parse_number(geolocation)
  ) %>%
  filter_at(
    vars(date, time, subject_race, geolocation),
    all_vars(. > 75)
  ) %>%
  select(state, city)

cities <- opp_load_all_data(only=eligible_cities)

metadata = list()
cities_wsunset <-
  add_sunset_times(
    cities,
    metadata = metadata,
    multi_tz = TRUE,
    geographic_col = city
  )

write_rds(cities_wsunset, here::here("cache", "aggregated_cities_wsunset.Rds"))