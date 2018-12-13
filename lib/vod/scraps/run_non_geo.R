suppressMessages(source(here::here("lib", "opp.R")))
suppressMessages(source(here::here("lib", "veil_of_darkness_test.R")))

print("Running run_vod.R")

print("loading data...")
data <-
  read_rds(here::here("cache", "aggregated_cities_wsunset.Rds")) %>%
  filter(city != "El Paso", !(city == "Madison" & year(date) %in% c(2007, 2008))) %>% 
  mutate(geo_control = city)

print("running regression on all stops...")
results_full <- veil_of_darkness_test(data, has_sunset_times = TRUE, has_geo_control = TRUE)
print("regression complete")

print("writing results")
# write_rds(results_full$data, here::here("cache", "vod_nongeo_data.Rds"))
# write_rds(results_full$models, here::here("cache", "vod_nongeo_models.Rds"))
write_rds(results_full$results, here::here("cache", "vod_nongeo_results.Rds"))

print("running regression on DST period...")
results_dst <- veil_of_darkness_test(
  data,
  has_sunset_times = TRUE,
  has_geo_control = TRUE,
  filter_to_DST = TRUE
)
print("regression complete")

print("writing results")
# write_rds(results_dst$fall_data, here::here("cache", "vod_dst_nongeo_fall_data.Rds"))
# write_rds(results_dst$spring_data, here::here("cache", "vod_dst_nongeo_spring_data.Rds"))
write_rds(results_dst$fall, here::here("cache", "vod_dst_nongeo_fall.Rds"))
write_rds(results_dst$spring, here::here("cache", "vod_dst_nongeo_spring.Rds"))

# print("running city level regressions all stops...")
# reg <- function(city_name){
#   print(str_c("running regression on ", city_name))
#   results <-
#     data %>%
#     filter(city == city_name) %>%
#     veil_of_darkness_test(has_sunset_times = TRUE, has_geo_control = FALSE)
#   
#   broom::tidy(results$models$model_time_const) %>%
#     filter(term == "is_darkTRUE") %>%
#     mutate(city = city_name)
# }
# 
# by_city <-
#   data %>%
#   distinct(city) %>%
#   pull(city) %>% 
#   map_dfr(~reg(.))
# 
# print("writing results")
# write_rds(by_city, here::here("cache", "vod_nongeo_by_city.Rds"))
print("done!")