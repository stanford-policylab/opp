library(tidyverse)
library(ggmap)

source('opp.R')

stop_map <- function(state, city, api_key = NA) {
  # TODO(danj): get lab key
  if (is.na(api_key)) {
    api_key <- trimws(read_file(here::here("lib", "personal_gmaps_api.key")))
  }
  tbl <- opp_load_data(state, city) 
  blk_pop <- opp_load_block_group_populations(state)
  # NOTE: get 1st and 99th percentiles, the others are likely outliers
  corners <- summarize(
    tbl,
    bottom = quantile(lat, 0.01, na.rm = T),
    left = quantile(lng, 0.01, na.rm = T),
    top = quantile(lat, 0.99, na.rm = T),
    right = quantile(lng, 0.99, na.rm = T)
  )
  bounding_box <- as.numeric(corners)
  names(bounding_box) <- names(corners)
  title <- create_title(state, city)
  map <- ggmap(get_map(
    location = bounding_box,
    maptype = "roadmap",
    api_key = api_key
  )) +
  xlab("longitude") +
  ylab("latitude") +
  ggtitle(title)
  ggsave(here::here("plots", str_c(title, ".png")))
}

