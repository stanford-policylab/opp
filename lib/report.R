library(ggplot2)
library(rlang)
library(zoo)

source("opp.R")


title <- str_c(capitalize_first_letters(city), toupper(state), sep = ", ")


d <- opp_load(state, city)


population <- opp_population(state, city)
total_rows <- nrow(d$data)
date_range <- range(d$data$incident_date)
null_rates_table <- kable(null_rates(d$data), align = c('l', 'r'))


by_incident_type <- group_by(d$data, incident_type) %>% count
by_incident_type_table <- kable(by_incident_type)


by_year <- group_by(d$data, year = year(incident_date)) %>% count
by_year_plot <- ggplot(by_year) +
  geom_bar(aes(x = factor(year), y = n), stat = "identity") +
  xlab("year") +
  ylab("count")


by_year_by_month_plot <- ggplot(d$data) +
  geom_bar(aes(as.yearmon(incident_date))) +
  scale_x_yearmon() +
  xlab("month-year") +
  ylab("count")


d_yd <- mutate(
		d$data,
		yr = year(incident_date),
		year_day = yday(incident_date)
	) %>%
  group_by(
		yr,
		year_day
	) %>%
  count
by_year_by_day_plot <- ggplot(d_yd) +
  geom_bar(aes(x = year_day, y = n), stat = "identity") +
  facet_grid(yr ~ .) +
  xlab("day of year") +
  ylab("count")


d_yw <- mutate(
		d$data,
		yr = year(incident_date),
		day_of_week = wday(incident_date, label = TRUE)
	) %>%
  group_by(
		yr,
		day_of_week
	) %>%
  count
by_year_by_day_of_week_plot <- ggplot(d_yw) +
  geom_bar(aes(x = day_of_week, y = n), stat = "identity") +
  facet_grid(yr ~ .) +
  xlab("day of week") +
  ylab("count")


d_yh <- mutate(
		d$data,
		yr = year(incident_date),
		hr = hour(incident_time)
	) %>%
  group_by(
		yr,
		hr
	) %>%
  count
by_year_by_hour_of_day_plot <- ggplot(d_yh) +
  geom_bar(aes(x = hr, y = n), stat = "identity") +
  facet_grid(yr ~ .) +
  xlab("hour of day") +
  ylab("count")


race_pct_tbl <- pct_tbl(d$data$subject_race, c("race", "percent"))
race_present_pct <- pretty_percent(1 - null_rate(d$data$subject_race))
race_pct_plot <- ggplot(race_pct_tbl) +
  geom_bar(aes(x = reorder(race, -percent), y = percent), stat = "identity") +
  xlab(str_c(
		"race",
		str_c("(represents", race_present_pct, "of stops)", sep = " "),
		sep = "\n"
	))


reason_for_stop_top_20 <- top_n_by(d$data, reason_for_stop, top_n = 20)
reason_for_stop_top_20_pct <-
  pretty_percent(sum(reason_for_stop_top_20$n) / nrow(d$data))
reason_for_stop_top_20_plot <- ggplot(reason_for_stop_top_20) +
  geom_bar(aes(x = reorder(reason_for_stop, -n), y = n), stat = "identity") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  xlab(str_c(
		"reason for stop",
		str_c("(represents", reason_for_stop_top_20_pct, "of stops)", sep = " "),
		sep = "\n"
	))


search_types_tbl <- group_by(d$data, search_type) %>% count
search_types_plot <- ggplot(search_types_tbl) +
  geom_bar(aes(x = reorder(search_type, -n), y = n), stat = "identity") +
  xlab("search type")


pct <- function(colname) {
  pretty_percent(mean(d$data[[colname]], na.rm = TRUE))
}


search_conducted_pct <- pct("search_conducted")
contraband_found_pct <- pct("contraband_found")


plot_prop_by_race <- function(col) {
  colq <- enquo(col)
  tbl <- group_by(
    d$data,
    subject_race
  ) %>% summarize(
    rate = mean(UQE(colq), na.rm = TRUE)
  )
  ggplot(tbl) + 
    geom_bar(aes(x = subject_race, y = rate), stat = "identity") +
    xlab("race") +
    ylab(str_c(deparse(substitute(col)), "rate", sep = " "))
}


search_conducted_by_race_plot <- plot_prop_by_race(search_conducted)
contraband_found_by_race_plot <- plot_prop_by_race(contraband_found)


d_o <- group_by(
		d$data,
    subject_race,
    incident_outcome
	) %>%
  summarize(
    n = n()
  ) %>%
  mutate(
    proportion = n / sum(n)
  )
outcome_by_race_plot <- ggplot(d_o) +
  geom_bar(aes(x = incident_outcome, y = proportion), stat = "identity") +
  facet_grid(subject_race ~ .) +
  xlab("outcome")


loading_problems <- d$metadata$loading_problems %>%
  lapply(function(x) mutate_each(x, funs('as.character'))) %>% bind_rows()
loading_problems_count_table <- kable(tibble())
loading_problems_random_sample_sorted_table <- kable(tibble())
if (nrow(loading_problems) > 0) {
  loading_problems_count <- group_by(
      loading_problems,
      col,
      expected
    ) %>%
    count
  loading_problems_count_table <- kable(
    loading_problems_count,
    caption = "Loading problems"
  )
  sample_number = min(nrow(loading_problems), 20)
  loading_problems_random_sample_sorted <- sample_n(
      loading_problems,
      sample_number
    ) %>%
    arrange(
      expected,
      actual
    ) %>%
    mutate(
      actual = str_replace(actual, "\\\\", "::backslash::") # to make printable
    ) %>%
    select(
      col,
      expected,
      actual
    )	
  loading_problems_random_sample_sorted_table <- kable(
    loading_problems_random_sample_sorted,
    caption = "20 Random loading problem errors, sorted"
  )
}


enforce_types_table <- kable(
	d$metadata$standardize$enforce_types,
	caption = "Enforce data types null rates"
)


sanitize_table <- kable(
	d$metadata$standardize$sanitize,
	caption = "Sanitize data null rates"
)


missing_columns_added_table <- kable(tibble())
if ("add_missing_required_columns" %in% d$metadata$standardize) {
  missing_columns_added_table <- kable(
    tibble(added_columns = d$metadata$standardize$add_missing_required_columns),
    caption = "Missing columns added"
  )
}
