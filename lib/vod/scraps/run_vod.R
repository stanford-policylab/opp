suppressMessages(source(here::here("lib", "opp.R")))
suppressMessages(source(here::here("lib", "veil_of_darkness_test.R")))

print("Running run_vod.R")

print("loading data...")
data <-
  read_rds(here::here("cache", "aggregated_cities_wsunset.Rds")) %>% 
  filter(city != "El Paso", !(city == "Madison" & year(date) %in% c(2007, 2008)))

print("adding subgeography...")
subgeos <-
  data %>%
  group_by(city) %>%
  summarise_at(
    vars(
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
    n_distinct >= 5, n_distinct <= 30
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
    subgeography = city,
    geo_control_var = case_when(
      city %in% region_cities ~ region,
      city %in% precinct_cities ~ precinct,
      city %in% district_cities ~ district,
      city %in% beat_cities ~ beat,
      city %in% sector_cities ~ sector
    )
  ) %>%
  filter(!is.na(subgeography)) %>%
  unite("geo_control", city, geo_control_var, remove = FALSE)

print("running regression on all stops...")
results_full <- veil_of_darkness_test(data, has_sunset_times = TRUE, has_geo_control = TRUE)
print("regression complete")

print("writing results")
write_rds(results_full$data, here::here("cache", "vod_full_data.Rds"))
write_rds(results_full$models, here::here("cache", "vod_full_models.Rds"))
write_rds(results_full$results, here::here("cache", "vod_full_results.Rds"))

print("running regression on DST period...")
results_dst <- veil_of_darkness_test(
  data,
  has_sunset_times = TRUE,
  has_geo_control = TRUE,
  filter_to_DST = TRUE
)
print("regression complete")

print("writing results")
write_rds(results_dst$fall_data, here::here("cache", "vod_dst_fall_data.Rds"))
write_rds(results_dst$spring_data, here::here("cache", "vod_dst_spring_data.Rds"))
write_rds(results_dst$fall, here::here("cache", "vod_dst_fall.Rds"))
write_rds(results_dst$spring, here::here("cache", "vod_dst_spring.Rds"))

print("running city level regressions all stops...")
reg <- function(city_name){
  print(str_c("running regression on ", city_name))
  results <-
    data %>%
    filter(city == city_name) %>%
    veil_of_darkness_test(has_sunset_times = TRUE, has_geo_control = TRUE)

  broom::tidy(results$models$model_geo_adjusted) %>%
    filter(term == "is_darkTRUE") %>%
    mutate(city = city_name) %>%
    select(city, estimate, std.error)
}

by_city <-
  subgeos %>%
  pull(city) %>%
  map_dfr(~reg(.))

print("writing results")
write_rds(by_city, here::here("cache", "vod_geo_adj_by_city.Rds"))

print("running city level regressions DST...")
reg <- function(city_name){
  print(str_c("running DST regression on ", city_name))
  results <-
    data %>%
    filter(city == city_name) %>%
    veil_of_darkness_test(has_sunset_times = TRUE, has_geo_control = TRUE, filter_to_DST = TRUE)

  rbind(
    broom::tidy(results$fall$model_geo_adjusted) %>%
      filter(term == "is_darkTRUE") %>%
      mutate(season = "spring", city = city_name),
    broom::tidy(results$spring$model_geo_adjusted) %>%
      filter(term == "is_darkTRUE") %>%
      mutate(season = "fall", city = city_name)
  )
}

by_city <-
  subgeos %>%
  pull(city) %>%
  map_dfr(~reg(.))

print("writing results")
write_rds(by_city, here::here("cache", "vod_dst_by_city.Rds"))
print("done")