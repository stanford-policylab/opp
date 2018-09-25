library(tidyverse)
library(ggmap)

source('opp.R')

stop_maps <- function(
    state,
    city,
    api_key = NA,
    n_samples = 10000,
    pad = 0.0275
) {
  if (is.na(api_key)) {
    api_key <- load_default_api_key()
  }
  tbl <- opp_load_data(state, city) 
  bounding_box <- calculate_bounding_box(tbl, pad)
  population_samples <- sample_block_groups(state, bounding_box, n_samples)
  stop_samples <- sample_stops(tbl, bounding_box, n_samples)
  title <- create_title(state, city)
  save_plot(
    population_samples,
    bounding_box,
    str_c("Population: ", title),
    api_key
  )
  save_plot(
    stop_samples,
    bounding_box,
    str_c("Stops: ", title),
    api_key
  )
}


load_default_api_key <- function() {
  trimws(read_file(here::here("lib", "gmaps_api.key")))
}


calculate_bounding_box <- function(tbl, pad) {
  # NOTE: get 1st and 99th percentiles, the others are likely outliers
  corners <- summarize(
    tbl,
    bottom = quantile(lat, 0.01, na.rm = T) + -pad,
    left = quantile(lng, 0.01, na.rm = T) + -pad,
    top = quantile(lat, 0.99, na.rm = T) + pad,
    right = quantile(lng, 0.99, na.rm = T) + pad
  )
  bounding_box <- as.numeric(corners)
  names(bounding_box) <- names(corners)
  bounding_box
}


sample_block_groups <- function(state, bounding_box, n_samples) {
    select(
      opp_load_block_group_data(state),
      -state,
      -gis_block_group_id
    ) %>%
    filter(
      lat > bounding_box["bottom"] & lat < bounding_box["top"],
      lng > bounding_box["left"] & lng < bounding_box["right"]
    ) %>%
    gather(
      key = "race",
      value = "count",
      -lat,
      -lng
    ) %>%
    sample_n(
      n_samples,
      weight = count,
      replace = T
    ) %>%
    mutate(
      race = factor(race, levels=valid_races)
    ) %>%
    select(
      lat,
      lng,
      race
    )
}


sample_stops <- function(tbl, bounding_box, n_samples) {
  filter(
    tbl,
    lat > bounding_box["bottom"] & lat < bounding_box["top"],
    lng > bounding_box["left"] & lng < bounding_box["right"]
  ) %>%
  sample_n(
    n_samples,
    replace = T
  ) %>%
  rename(
    race = subject_race
  ) %>%
  select(
    lat,
    lng,
    race
  )
}


save_plot <- function(
  samples,
  bounding_box,
  title,
  api_key
) {
  ggmap(get_map(
    location = bounding_box,
    maptype = "roadmap",
    api_key = api_key
  )) +
  geom_jitter(
    data=samples,
    aes(
      x=lng,
      y=lat,
      color=race
    ),
    width=0.005,
    height=0.005,
    size=0.5
  ) +
  guides(color = guide_legend(override.aes = list(size=3))) +
  scale_color_discrete(breaks=valid_races, labels=valid_races) +
  theme(legend.title = element_blank(), legend.key = element_blank()) +
  xlab("longitude") +
  ylab("latitude") +
  ggtitle(title)

  ggsave(here::here("plots", str_c(title, ".png")))
}
