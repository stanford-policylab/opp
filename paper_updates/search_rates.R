source(here::here("lib", "opp.R"))

coverage <- read_rds(here::here("cache", "coverage.rds"))

search_conducted_cities <- 
  coverage %>% 
  filter(
    city != "Statewide",
    subject_race > 0.85, 
    search_conducted > 0.85
  ) %>% 
  select(state, city)

search_conducted_cities %>% 
  opp_load_all_clean_data() %>% 
  filter(
    year(date) >= 2012, year(date) <= 2017,
    !is.na(subject_race), !is.na(search_conducted)
  ) %>% 
  group_by(subject_race) %>% 
  summarize(
    search_rate = mean(search_conducted),
    n = n()
  ) %>% 
  write_rds(here::here("cache", "city_search_rates.rds"))

print("Finished cities.")

search_conducted_states <- 
  coverage %>% 
  filter(
    city == "Statewide",
    subject_race > 0.85, 
    search_conducted > 0.85
  ) %>% 
  select(state, city)

search_conducted_states %>% 
  opp_load_all_clean_data() %>% 
  filter(
    year(date) >= 2012, year(date) <= 2017,
    !is.na(subject_race), !is.na(search_conducted)
  ) %>% 
  group_by(subject_race) %>% 
  summarize(
    search_rate = mean(search_conducted),
    n = n()
  ) %>% 
  write_rds(here::here("cache", "state_search_rates.rds"))



