library(ggplot2)
library(zoo)

source("opp.R")

d <- opp_load(state, city)

total_rows <- nrow(d)
date_range <- range(d$incident_date)

by_incident_type <- group_by(d, incident_type) %>% count
by_incident_type_table <- kable(by_incident_type)

by_year <- group_by(d, year = year(incident_date)) %>% count
by_year_plot <- ggplot(by_year) +
  geom_bar(aes(x = factor(year), y = n), stat = "identity") +
  xlab("year") +
  ylab("count")

by_year_by_month_plot <- ggplot(d) +
  geom_bar(aes(as.yearmon(incident_date))) +
  scale_x_yearmon() +
  xlab("month-year") +
  ylab("count")

by_year_by_day_plot <- ggplot(d) +
  geom_histogram(aes(x = yday(incident_date)), bins = 365) + 
  facet_grid(year(incident_date) ~ .) +
  xlab("day of year") +
  ylab("count")
