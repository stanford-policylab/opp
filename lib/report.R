library(ggplot2)
source("opp.R")

d <- opp_load(state, city)

nrows <- nrow(d)

by_type <- group_by(d, incident_type) %>% count
by_type_plot <- ggplot(by_type) +
  geom_bar(aes(x = factor(type), y = n), stat = "identity") +
  xlab("type") +
  ylab("count")

by_year <- group_by(d, year = year(incident_date)) %>% count
by_year_plot <- ggplot(by_year) +
  geom_bar(aes(x = factor(year), y = n), stat = "identity") +
  xlab("year") +
  ylab("count")
