suppressMessages(source(here::here("lib", "opp.R")))
suppressMessages(source(here::here("lib", "veil_of_darkness_test.R")))

print("loading data...")
data <-
  read_rds(here::here("cache", "states_wsunset.rds")) %>%
  filter(year(date) >= 2010)
# 
# print("running regression on all stops...")
# results_full <- veil_of_darkness_test(data, has_sunset_times = TRUE, has_geo_control = TRUE)
# print("regression complete")
# 
# print("writing results")
# write_rds(results_full$data, here::here("cache", "vod_statewide_full_data.Rds"))
# write_rds(results_full$models, here::here("cache", "vod_statewide_full_models.Rds"))
# write_rds(results_full$results, here::here("cache", "vod_statewide_full_results.Rds"))
# 
# print("running regression on DST period...")
# results_dst <- veil_of_darkness_test(
#   data,
#   has_sunset_times = TRUE,
#   has_geo_control = TRUE,
#   filter_to_DST = TRUE
# )
# print("regression complete")
# 
# print("writing results")
# write_rds(results_dst$data, here::here("cache", "vod_statewide_dst_data.Rds"))
# write_rds(results_dst$models, here::here("cache", "vod_statewide_dst_models.Rds"))
# write_rds(results_dst$results, here::here("cache", "vod_statewide_dst_results.Rds"))

print("running state level regressions...")
reg <- function(state) {
  print(str_c("running regression on ", state))
  results <-
    data %>%
    filter(state == state) %>%
    veil_of_darkness_test(has_sunset_times = TRUE, has_geo_control = TRUE)

  broom::tidy(results$models$model_geo_adjusted) %>%
    filter(term == "is_darkTRUE") %>%
    mutate(state = state)
}

by_state <-
  data %>%
  distinct(state) %>%
  pull(state) %>%
  map_dfr(~reg(.))

print("writing results")
write_rds(by_state, here::here("cache", "vod_geo_adj_by_state.Rds"))
print("done")
