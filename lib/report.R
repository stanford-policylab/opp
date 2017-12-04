library(ggplot2)
library(zoo)

source("opp.R")

d <- opp_load(state, city)

total_rows <- nrow(d)
date_range <- range(d$incident_date)
null_rates_table <- kable(null_rates(d), align = c('l', 'r'))

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

race_pct_tbl <- pct_tbl(d$subject_race, c("race", "percent"))
race_pct_plot <- ggplot(race_pct_tbl) +
  geom_bar(aes(x = race, y = percent), stat = "identity")

reason_for_stop_top_20 <- top_n_by(tbl, reason_for_stop)
reason_for_stop_top_20_plot <- ggplot(reason_for_stop_top_20) +
  geom_bar(aes(x = reorder(reason_for_stop, -n), y = n, stat = "identity")) +
  theme(axis.text.x = element_text(angle = 90)) +
  xlab("reason for stop")
