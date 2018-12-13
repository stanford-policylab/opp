library(here)
library(purrr)

source("opp.R")


coverage <- function() {
  cache_file <- here::here("cache", "coverage.rds")
  cvg <- get_or_create_cache(cache_file)
  cvg_to_update <- filter(
    cvg,
    is.na(nrows)
  ) %>%
  select(
    path,
    state,
    city,
    modified_time
  )

  if (nrow(cvg_to_update) > 0) {
    cvg_updates <- cvg_to_update %>% 
      select(state, city) %>%
      pmap(city_coverage) %>%
      bind_rows()

    cvg <- bind_rows(
      filter(cvg, !is.na(nrows)),
      left_join(cvg_to_update, cvg_updates)
    )
  }
  saveRDS(cvg, cache_file)
  cvg
}


get_or_create_cache <- function(cache_file) {
  paths <- opp_data_paths()
  cvg <- tibble(
    path = paths,
    state = sapply(paths, opp_extract_state_from_path),
    city = sapply(paths, opp_extract_city_from_path),
    modified_time = sapply(paths, modified_time)
  ) %>% 
  filter(
    # NOTE: sometimes we have statewide data that is processed once for all
    # cities; however, each will show up independently so no need to report
    city != "Statewide"
  )

  if (file.exists(cache_file)) {
    # NOTE: joins by: path, state, city, modified_time
    # so if the modified time isn't the same, all fields are NA
    cvg <- left_join(cvg, readRDS(cache_file))
  }
  # TODO(danj): hack to create signal column; think of something clearer
  mutate(cvg, nrows = if (exists("nrows", where = cvg)) nrows else NA)
}


city_coverage <- function(state, city) {
  tbl <- opp_load_coverage_data(state, city)
  date_range = range(tbl$date, na.rm = TRUE)
  c(
    list(
      state = state,
      city = city,
      nrows = nrow(tbl),
      population = opp_population(state, city),
      start_date = date_range[1],
      end_date = date_range[2]
    ),
    lapply(lapply(tbl, coverage_rate), pretty_percent)
  )
}
