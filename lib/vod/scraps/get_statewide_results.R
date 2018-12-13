library(tidyverse)

full_models <- read_rds(here::here("cache", "vod_statewide_full_models.Rds"))

model_time_adj <- broom::tidy(full_models$model_time_const)
model_time_geo_adj <- broom::tidy(full_models$model_geo_adjusted)

write_rds(model_time_adj, here::here("cache", "vod_statewide_time_const.rds"))
write_rds(model_time_geo_adj, here::here("cache", "vod_statewide_geo_adj.rds"))