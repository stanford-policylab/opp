library(tidyverse)
library(ggmap)

source('opp.R')

stop_map <- function(state, city) {
  # TODO(danj): get lab key
  api_key <- trimws(read_file(here::here("lib", "personal_gmaps_api.key")))
  register_google(api_key)
  tbl <- opp_load_data(state, city) 
  # TODO(danj): parsing errors for block group data?
  blk_pop <- opp_load_block_group_populations(state)
  summarize(
    tbl,
    min_lat = min(lat, na.rm = T),
    max_lat = max(lat, na.rm = T),
    min_lng = min(lng, na.rm = T),
    max_lng = max(lng, na.rm = T)
  )
}
