library(ggplot2)
library(rlang)
library(zoo)

source("opp.R")

d <- opp_load(state, city)
prop_plot <- function(col) {
  ggplot(d, aes_string(x = col)) +
    geom_bar(aes(y = (..count..)/sum(..count..))) + 
    ylab("proportion")
}

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

d_yd <- mutate(d, yr = year(incident_date), year_day = yday(incident_date)) %>%
  group_by(yr, year_day) %>%
  count
by_year_by_day_plot <- ggplot(d_yd) +
  geom_bar(aes(x = year_day, y = n), stat = "identity") +
  facet_grid(yr ~ .) +
  xlab("day of year") +
  ylab("count")

d_wd <- mutate(d,
               yr = year(incident_date),
               day_of_week = wday(incident_date, label = TRUE)) %>%
  group_by(yr, day_of_week) %>%
  count
by_year_by_day_of_week_plot <- ggplot(d_wd) +
  geom_bar(aes(x = day_of_week, y = n), stat = "identity") +
  facet_grid(yr ~ .) +
  xlab("day of week") +
  ylab("count")

race_pct_tbl <- pct_tbl(d$subject_race, c("race", "percent"))
race_pct_plot <- ggplot(race_pct_tbl) +
  geom_bar(aes(x = reorder(race, -percent), y = percent), stat = "identity") +
  xlab("race")

reason_for_stop_top_20 <- top_n_by(d, reason_for_stop, top_n = 20)
reason_for_stop_top_20_plot <- ggplot(reason_for_stop_top_20) +
  geom_bar(aes(x = reorder(reason_for_stop, -n), y = n), stat = "identity") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  xlab("reason for stop")

reason_for_stop_top_20_pct <-
  pretty_percents(sum(reason_for_stop_top_20$n) / nrow(d))

search_conducted_plot <- ggplot(d) +
  geom_bar(aes(x = search_conducted, y = (..count..)/sum(..count..)))

search_types_tbl <- group_by(d, search_type) %>% count
search_types_plot <- ggplot(search_types_tbl) +
  geom_bar(aes(x = reorder(search_type, -n), y = n), stat = "identity") +
  xlab("search type")

contraband_found_plot <- prop_plot("contraband_found")

contraband_found_by_race_tbl <- group_by(d, subject_race) %>%
  summarize(rate = mean(contraband_found))
contraband_found_by_race_plot <- ggplot(contraband_found_by_race_tbl) +
  geom_bar(aes(x = subject_race, y = rate), stat = "identity") +
  xlab("race") +
  ylab("contraband found rate")

citation_issued_plot <- prop_plot("citation_issued")

arrest_made_plot <- prop_plot("arrest_made")
