## @knitr load
setwd("..")
source("opp.R")
d <- opp_load(state, city)

## @knitr counts
nrows <- nrow(d)
# by_type <- group_by(d, incident_type) %>% count
# by_year <- group_by(d, year = year(incident_date)) %>% count

## @knitr part2
print(city)
print(state)
