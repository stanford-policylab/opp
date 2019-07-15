library(here)
source(here::here("lib", "opp.R"))
source(here::here("lib", "e.R"))


prima_facie_stats <- function(use_cache = F) {

  all_data <- opp_load_all_clean_data()
  analysis_data <- load("pfs", use_cache)$data

  list(
    basic_counts = list(
      collected = counts(all_data),
      analyzed = counts(analysis_data)
    ),
    stop_rates = stop_rates(all_data),
    search_rates = search_rates(analysis_data)
  )
}


counts <- function(tbl) {
  locs <- tbl %>% select(state, city) %>% distinct()
  cities <- filter(locs, city != "Statewide")
  states <- filter(locs, city == "Statewide")
  list(
    n_stops = nrow(tbl),
    n_cities = nrow(cities),
    n_states = nrow(states)
  )
}


stop_rates <- function(tbl) {

  pop <- par_pmap(
    select(tbl, state, city) %>% distinct(),
    function(state, city) {
      opp_demographics(state, city) %>%
        select(-place, -state, -fip) %>%
        rename(state = state_abbreviation, subject_race = race) %>%
        mutate(city = city)
    }
  ) %>%
  bind_rows()

  n_months <- 12
  if (tbl$state[[1]] == "MO" && tbl$city[[1]] == "Statewide") {
    # NOTE: MO has only annualized data
    n_months <- 1
  }

  tbl %>%
  group_by(state, city, subject_race, year_month = format(date, "%Y-%m")) %>%
  summarize(n_monthly_stops = n()) %>%
  group_by(state, city, subject_race) %>%
  summarize(average_monthly_stops = mean(n_monthly_stops)) %>%
  left_join(pop) %>%
  mutate(annual_stop_rate = average_monthly_stops / population * n_months)
}


search_rates <- function(tbl) {
  tbl %>%
  group_by(state, city, subject_race) %>%
  summarize(
    n = n(),
    n_searches = sum(search_conducted, na.rm = T),
    search_rate = n_searches / n
  ) %>%
  ungroup()
}
