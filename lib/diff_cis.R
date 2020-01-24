library(here)
library(readr)
library(dplyr)
library(stringr)

printf <- function(...) invisible(print(sprintf(...)))

calculate_diff_cis <- function(rates, ses, ns) {
  z <- 1.96
  city_white_black_diff <- rates['city_white'] - rates['city_black']
  city_white_black_se <- sqrt(ses['city_white']^2 / ns['city_white'] + ses['city_black']^2 / ns['city_black'])
  city_white_black_lower_ci <- city_white_black_diff - z * city_white_black_se
  city_white_black_upper_ci <- city_white_black_diff + z * city_white_black_se

  city_white_hispanic_diff <- rates['city_white'] - rates['city_hispanic']
  city_white_hispanic_se <- sqrt(ses['city_white']^2 / ns['city_white'] + ses['city_hispanic']^2 / ns['city_hispanic'])
  city_white_hispanic_lower_ci <- city_white_hispanic_diff - z * city_white_hispanic_se
  city_white_hispanic_upper_ci <- city_white_hispanic_diff + z * city_white_hispanic_se

  state_white_black_diff <- rates['state_white'] - rates['state_black']
  state_white_black_se <- sqrt(ses['state_white']^2 / ns['state_white'] + ses['state_black']^2 / ns['state_black'])
  state_white_black_lower_ci <- state_white_black_diff - z * state_white_black_se
  state_white_black_upper_ci <- state_white_black_diff + z * state_white_black_se

  state_white_hispanic_diff <- rates['state_white'] - rates['state_hispanic']
  state_white_hispanic_se <- sqrt(ses['state_white']^2 / ns['state_white'] + ses['state_hispanic']^2 / ns['state_hispanic'])
  state_white_hispanic_lower_ci <- state_white_hispanic_diff - z * state_white_hispanic_se
  state_white_hispanic_upper_ci <- state_white_hispanic_diff + z * state_white_hispanic_se

  printf(
    'city white-black: %g (%g, %g)',
    city_white_black_diff,
    city_white_black_lower_ci,
    city_white_black_upper_ci
  )

  printf(
    'city white-hispanic: %g (%g, %g)',
    city_white_hispanic_diff,
    city_white_hispanic_lower_ci,
    city_white_hispanic_upper_ci
  )

  printf(
    'state white-black: %g (%g, %g)',
    state_white_black_diff,
    state_white_black_lower_ci,
    state_white_black_upper_ci
  )

  printf(
    'state white-hispanic: %g (%g, %g)',
    state_white_hispanic_diff,
    state_white_hispanic_lower_ci,
    state_white_hispanic_upper_ci
  )
}


pfs <- read_rds(here::here("results", "prima_facie_stats.rds"))

search_tbl <- pfs$rates$search %>% 
mutate(
  agency = if_else(city == "Statewide", "state", "city"),
  var = search_rate * (1 - search_rate) / n
) %>% 
group_by(agency, subject_race) %>%
summarize(
  average_search_rate = mean(search_rate),
  std_error = sqrt(sum(var)) / n(),
  n_locations = n(),
  lower_ci = average_search_rate - 1.96 * std_error,
  upper_ci = average_search_rate + 1.96 * std_error
) %>%
ungroup()

rates <- pull(search_tbl, average_search_rate)
ses <- pull(search_tbl, std_error)
ns <- pull(search_tbl, n_locations)
nms <- mutate(search_tbl, name = str_c(agency, "_", subject_race)) %>% pull()
names(rates) <- nms
names(ses) <- nms
names(ns) <- nms


print('Search Rates:')
calculate_diff_cis(rates, ses, ns)

disp <- read_rds(here::here("results", "disparity.rds"))

hit_rates <- bind_rows(
  disp$city$outcome$results$hit_rates %>% 
  group_by(geography, subject_race) %>% 
  summarize(
    hit_rate = weighted.mean(hit_rate, n_search_conducted),
    var = hit_rate * (1 - hit_rate) / sum(n_search_conducted)
  ) %>% 
  group_by(subject_race) %>% 
  summarize(
    agency = "city",
    hit_rate = mean(hit_rate),
    std_error = sqrt(sum(var)) / n(),
    n_locations = n(),
    lower_ci = hit_rate - 1.96 * std_error,
    upper_ci = hit_rate + 1.96 * std_error
  ),
  disp$state$outcome$results$hit_rates %>% 
  group_by(geography, subject_race) %>% 
  summarize(
    hit_rate = weighted.mean(hit_rate, n_search_conducted),
    var = hit_rate * (1 - hit_rate) / sum(n_search_conducted)
  ) %>% 
  group_by(subject_race) %>% 
  summarize(
    agency = "state",
    hit_rate = mean(hit_rate),
    std_error = sqrt(sum(var)) / n(),
    n_locations = n(),
    lower_ci = hit_rate - 1.96 * std_error,
    upper_ci = hit_rate + 1.96 * std_error
  )
)

rates <- pull(hit_rates, hit_rate)
ses <- pull(hit_rates, std_error)
ns <- pull(hit_rates, n_locations)
nms <- mutate(hit_rates, name = str_c(agency, "_", subject_race)) %>% pull()
names(rates) <- nms
names(ses) <- nms
names(ns) <- nms


print('Hit Rates:')
calculate_diff_cis(rates, ses, ns)
