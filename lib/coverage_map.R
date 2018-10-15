library(readr)
library(here)
library(maps)

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
pdf(here::here("plots", "coverage_map.pdf"))
map( database = "state",
  col = c("white", "lightblue3")[1 + (state_names %in% state_coverage)],
  fill=T,
  namesonly=T
)
points(city_coverage$lng, city_coverage$lat, col="red", pch=16)
dev.off()
