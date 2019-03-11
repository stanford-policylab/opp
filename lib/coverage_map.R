library(here)
source(here::here("lib", "opp.R"))


compose_coverage_map <- function() {
  data(state.fips)
  city_geocodes <-
    read_csv(here::here("data", "city_coverage_geocodes.csv")) %>%
    separate(loc, c("city", "state"), sep = ",")
  all_locs <- opp_available()
  all_states <- filter(all_locs, city == "Statewide")
  all_cities <- filter(all_locs, city != "Statewide")
  analysis_locs <- locations_used_in_analyses()
  analysis_states <-
    left_join(
      analysis_locs %>% filter(city == "Statewide"),
      state.fips,
      by = c("state" = "abb")
    )
  analysis_cities <-
    left_join(
      analysis_locs %>% filter(city != "Statewide"),
      city_geocodes
    )

  state_polynames <- maps::map(database = "state")$names
  eligible_state_polynames <-
    left_join(all_states, state.fips, by = c("state" = "abb")) %>%
    pull(polyname)
  analysis_state_polynames <- pull(analysis_states, polyname)
  unused_cities <-
    left_join(all_cities, city_geocodes) %>%
    anti_join(analysis_cities)

  dir_create(here::here("plots"))
  out_fn <- here::here("plots", "coverage_map.pdf")
  pdf(out_fn), width = 16, height = 9)
  maps::map(
    database = "state",
    col = c("white", "lightblue3")[
      1
      + (state_polynames %in% analysis_state_polynames)
    ],
    fill = T,
    namesonly = T
  )
  points(
    analysis_cities$lng,
    analysis_cities$lat,
    col = "red",
    pch = 16,
    cex = 2
  )
  dev.off() 
  print(str_c("saved to ", out_fn))
}
