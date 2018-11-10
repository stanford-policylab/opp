suppressMessages(source(here::here("lib", "opp.R")))
suppressMessages(source(here::here("lib", "veil_of_darkness_test.R")))

print("Running run_vod.R")
cities_w_data_problems <- c("Green Bay", "Camden", "Bakersfield", "Little Rock")

print("loading data...")
data <- 
  read_rds(here::here("cache", "aggregated_cities_wsunset.Rds")) %>% 
  filter(!(city %in% cities_w_data_problems))

print("adding subgeography...")
subgeos <- 
  data %>% 
  group_by(city) %>% 
  summarise_at(
    vars(
      neighborhood, 
      region, 
      precinct, 
      reporting_area, 
      district, 
      beat, 
      sector, 
      police_grid_number
    ), 
    n_distinct,
    na.rm = TRUE
  ) %>% 
  gather(-city, key = "subgeo", value = "n_distinct") %>% 
  filter(
    n_distinct >= 5, n_distinct <= 30, 
    (city != "Dallas" | subgeo != "district")
  ) %>% 
  select(-n_distinct)


get_subgeo_cities <- function(name) {
  subgeos %>% 
    filter(subgeo == name) %>% 
    pull(city)
}

region_cities <- get_subgeo_cities("region")
precinct_cities <- get_subgeo_cities("precinct")
district_cities <- get_subgeo_cities("district")
beat_cities <- get_subgeo_cities("beat")
sector_cities <- get_subgeo_cities("sector")

data <-
  data %>% 
  filter(city %in% pull(subgeos, city)) %>% 
  mutate(
    subgeography = case_when(
      city %in% region_cities ~ region,
      city %in% precinct_cities ~ precinct,
      city %in% district_cities ~ district,
      city %in% beat_cities ~ beat,
      city %in% sector_cities ~ sector
    )
  ) %>% 
  filter(!is.na(subgeography)) %>% 
  unite("geo_adj_var", city, subgeography, remove = FALSE)

print("running regression on all stops...")
results_full <- veil_of_darkness_test(data, has_sunset_times = TRUE)
print("regression complete")

# print("writing results")
# write_rds(results_full$data, here::here("cache", "vod_full_data.Rds"))
# write_rds(results_full$models, here::here("cache", "vod_full_models.Rds"))
# write_rds(results_full$results, here::here("cache", "vod_full_results.Rds"))

print("running regression on DST period...")
results_dst <- veil_of_darkness_test(data, has_sunset_times = TRUE, filter_to_DST = TRUE)
print("regression complete")

# print("writing results")
# write_rds(results_dst$data, here::here("cache", "vod_dst_data.Rds"))
# write_rds(results_dst$models, here::here("cache", "vod_dst_models.Rds"))
# write_rds(results_dst$results, here::here("cache", "vod_dst_results.Rds"))
