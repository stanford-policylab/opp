library(here)
source(here::here("lib", "opp.R"))
source(here::here("lib", "eligibility.R"))


compose_coverage_map <- function() {
  data(state.fips)
  analysis_locs <- locations_used_in_analyses()
  analysis_state_polynames <-
    left_join(
      analysis_locs %>% filter(city == "Statewide"),
      state.fips,
      by = c("state" = "abb")
    ) %>%
    pull(polyname)
  analysis_cities <-
    left_join(
      analysis_locs %>% filter(city != "Statewide"),
      city_center_lat_lngs()
    )

  state_polynames <- maps::map(database = "state")$names

  dir_create(here::here("plots"))
  out_fn <- here::here("plots", "coverage_map.pdf")
  pdf(out_fn, width = 16, height = 9)
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
