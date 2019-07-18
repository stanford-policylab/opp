library(here)
source(here::here("lib", "opp.R"))
source(here::here("lib", "e.R"))


prima_facie_stats <- function() {

  all_data <- opp_load_all_clean_data()
  stop_data <- load("pfs_stop", use_cache)$data
  search_data <- load("pfs_search", use_cache)$data

  stop_rates <- stop_rates(stop_data)
  search_rates <- search_rates(search_data)

  stop_rates_plot <- plot_stop_rates(stop_rates)
  search_rates_plot <- plot_search_rates(search_rates)

  list(
    counts = list(
      collected = counts(all_data),
      analyzed = counts(stop_data)
    ),
    rates = list(
      stop = stop_rates,
      search = search_rates
    ),
    plots = list(
      stop = stop_rates_plot,
      search = search_rates_plot
    )
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
  mutate(
    average_annual_stops = average_monthly_stops * n_months,
    annual_stop_rate = average_annual_stops / population
  )
}


search_rates <- function(tbl) {
  tbl %>%
  filter(
  ) %>%
  group_by(state, city, subject_race) %>%
  summarize(
    n = n(),
    n_searches = sum(search_conducted, na.rm = T),
    search_rate = n_searches / n
  ) %>%
  ungroup()
}


plot_stop_rates <- function(tbl) {
  ggplot(
    tbl %>% mutate(location = str_c(city, state, sep = ", ")),
    aes(x = location, y = annual_stop_rate)
  ) +
  geom_bar(stat="identity") +
  facet_grid(subject_race ~ .) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  ylab("Annual Stop Rate") +
  ggtitle("Annual Stop Rates by Location")
}


plot_search_rates <- function(tbl) {
  ggplot(
    tbl %>%
      mutate(location = str_c(city, state, sep = ", ")) %>%
      filter(n_searches > 0),
    aes(x = location, y = search_rate)
  ) +
  geom_bar(stat="identity") +
  facet_grid(subject_race ~ .) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  ylab("Search Rate") +
  ggtitle("Search Rates by Location")
}
