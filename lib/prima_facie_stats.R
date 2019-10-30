library(here)
source(here::here("lib", "eligibility.R"))
source(here::here("lib", "utils.R"))


prima_facie_stats <- function(use_cache = F) {

  all_data <- opp_load_all_clean_data()
  stop_data <- load("pfs_stop", use_cache)$data
  summary_table <- generate_summary_table(stop_data)
  search_data <- load("pfs_search", use_cache)$data
  
  stop_rates <- stop_rates(stop_data)
  search_rates <- search_rates(search_data)

  stop_rates_plot <- plot_stop_rates(stop_rates)
  search_rates_plot <- plot_search_rates(search_rates)
  
  summary_table <- generate_summary_table(stop_data)
  
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
    ),
    summary_table = summary_table
  )
}


counts <- function(tbl) {
  locs <- tbl %>% select(state, city) %>% distinct()
  list(
    n_cities = nrow(filter(locs, city != "Statewide")),
    n_states = nrow(filter(locs, city == "Statewide")),
    n_stops = nrow(tbl),
    n_stops_cities = nrow(filter(tbl, city != "Statewide")),
    n_stops_states = nrow(filter(tbl, city == "Statewide"))
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


plot_search_rates <- function(tbl, target_threshold = 0.5) {
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

generate_summary_table <- function(tbl, target_threshold = 0.5) {
  compute_coverage(tbl) %>% 
    mutate(
      order = if_else(city == "Statewide", 1, 0),
      city = if_else(city == "Statewide", "--", city),
      years = str_c(year(start_date), "-", year(end_date)),
      nrows = comma_num(nrows)
    ) %>%
    select(
      order,
      State = state,
      City = city,
      Stops = nrows,
      `Date Range` = years,
      Date = date_cvg,
      Time = time_cvg,
      Subgeography = geo_cvg,
      `Subject Race` = race_cvg,
      `Subject Age` = age_cvg,
      `Subject Gender` = gender_cvg,
      `Search Conducted` = search_cvg,
      `Contraband Found` = contraband_cvg
    ) %>%
    arrange(
      order,
      State,
      City
    ) %>%
    select(
      -order
    ) %>%
    mutate_if(
      function(v) all(is.numeric(v) & v <= 1.0, na.rm = T),
      # NOTE: put dot if coverage above 50%
      function(v) if_else(v < target_threshold | is.na(v), "", "$\bullet$")
    ) 
}

compute_coverage <- function(tbl) {
  contraband_cvg_tbl <- tbl %>% 
    filter(search_conducted) %>% 
    group_by(state, city) %>% 
    summarize(contraband_cvg = coverage_rate(contraband_found))
  
  tbl %>% 
    group_by(state, city) %>% 
    summarize(
      start_date = range(date, na.rm = TRUE)[1],
      end_date = range(date, na.rm = TRUE)[2],
      nrows = n(),
      date_cvg = coverage_rate(date),
      time_cvg = coverage_rate(time),
      geo_cvg = coverage_rate(subgeography),
      race_cvg = coverage_rate(subject_race),
      age_cvg = coverage_rate(subject_age),
      gender_cvg = coverage_rate(subject_sex),
      search_cvg = coverage_rate(search_conducted)
    ) %>% 
    left_join(contraband_cvg_tbl, by = c("state", "city")) %>% 
    mutate(contraband_cvg = replace_na(contraband_cvg, 0))
}
