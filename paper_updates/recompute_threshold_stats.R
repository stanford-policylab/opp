states <- read_rds(here::here("cache", "disparity_results.rds"))$state
cities <- read_rds(here::here("cache", "disparity_results_cities.rds"))$city
state_posteriors <- rstan::extract(states$threshold$metadata$fit)
city_posteriors <- rstan::extract(cities$threshold$metadata$fit)

recompute_average_threshold_test_summary_stats <- function(
  thresholds,
  posteriors,
  demographic_col = subject_race,
  majority_demographic = "white"
) {
  demographic_colq <- enquo(demographic_col)
  # get weighted avg of thresholds by geography
  avg_thresh_geo <- accumulateRowMeans(
    t(signal_to_percent(
      posteriors$threshold,
      posteriors$phi,
      posteriors$delta
    )),
    pull(thresholds, geography_race),
    thresholds$n
  )
  dict <- thresholds %>% 
    group_by(geography_race, race) %>% 
    summarize(count = n(), n = sum(n))
  # get unweighted averages of thresholds across geographies
  avg_thresh <- accumulateRowMeans(
    avg_thresh_geo,
    pull(dict, race)
  )
  format_summary_stats(
    thresholds, 
    avg_thresh,
    !!demographic_colq,
    majority_demographic
  )
}

recompute_average_hit_rates <- function(
  hit_rates,
  demographic_col = subject_race,
  rate_col = `contraband_found where search_conducted`,
  n_col = n_search_conducted
) {
  demographic_colq <- enquo(demographic_col)
  rate_colq <- enquo(rate_col)
  n_colq <- enquo(n_col)
  hit_rates %>% 
    group_by(!!demographic_colq, geography) %>% 
    summarize(rate = weighted.mean(!!rate_colq, w = !!n_colq)) %>% 
    group_by(!!demographic_colq) %>% 
    summarize(rate = mean(rate))
}
#### avg hit rates
states$outcome$results %>% 
  recompute_average_hit_rates()
cities$outcome$results %>% 
  recompute_average_hit_rates()

#### avg thresholds
states$threshold$results$thresholds %>% 
  recompute_average_threshold_test_summary_stats(state_posteriors)
cities$threshold$results$thresholds %>% 
  recompute_average_threshold_test_summary_stats(city_posteriors)
