#!/usr/bin/env Rscript
library(readr)
library(here)
library(maps)
library(fs)

state_names <- map(database = "state")$names
sufficient_data_states <- c(
  "arizona",
  "california",
  "colorado",
  "connecticut",
  "florida",
  "illinois",
  "maryland",
  "massachusetts:main",
  "missouri",
  "montana",
  "nebraska",
  "new jersey",
  "north carolina:main",
  "ohio",
  "rhode island",
  "south carolina",
  "texas",
  "vermont",
  "washington:main",
  "wisconsin"
)
insufficient_data_states <- c(
  "alabama",
  "iowa",
  "michigan:north",
  "michigan:south",
  "nevada",
  "new hampshire",
  "north dakota",
  "oregon",
  "south dakota",
  "tennessee",
  "virginia:main",
  "wyoming"
)

state_coverage <- c(sufficient_data_states, insufficient_data_states)
city_coverage <- read_csv(here::here("data", "city_coverage_geocodes.csv"))
dir_create(here::here("plots"))
# pdf(here::here("plots", "coverage_map.pdf"))
png(here::here("plots", "coverage_map.png"), width=1600, height=900)
map( database = "state",
  col = c("white", "lightblue3")[1 + (state_names %in% state_coverage)],
  fill=T,
  namesonly=T
)
points(city_coverage$lng, city_coverage$lat, col="red", pch=16, cex=2)
dev.off()
