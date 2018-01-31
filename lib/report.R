library(ggplot2)
library(rlang)
library(zoo)

source("opp.R")
source("standards.R")


title <- str_c(capitalize_first_letters(city), toupper(state), sep = ", ")


d <- opp_load(state, city)


population <- opp_population(state, city)
total_rows <- nrow(d$data)
date_range <- range(d$data$incident_date)


by_incident_type <- group_by(d$data, incident_type) %>% count
by_incident_type_table <- kable(by_incident_type)


null_rates_table <- kable(predicated_null_rates(d$data, predicated_columns),
                          align = c("l", "r"))


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


search_types_tbl <- filter(d$data, !is.na(search_type)) %>% 
  group_by(search_type) %>%
  count %>%
  mutate(pct = n / sum(n))
search_types_plot <- ggplot(search_types_tbl) +
  geom_bar(aes(x = reorder(search_type, -pct), y = pct), stat = "identity") +
  xlab("search type (where search conducted)")


pct <- function(colname) {
  pretty_percent(mean(d$data[[colname]], na.rm = TRUE))
}

ppct <- function(colname, pred_colname) {
  idx <- d$data[[pred_colname]]
  pretty_percent(mean(d$data[[colname]][idx], na.rm = TRUE))
}


search_conducted_pct <- pct("search_conducted")
contraband_found_pct <- pct("contraband_found")
predicated_contraband_found_pct <- ppct("contraband_found", "search_conducted")


plot_prop_by_race <- function(col, pred_col = TRUE) {
  colq <- enquo(col)
  pred_colq <- enquo(pred_col)
  tbl <- group_by(
    d$data,
    subject_race
  ) %>%
  summarize(
    rate = mean(UQE(colq)[UQE(pred_colq)], na.rm = TRUE)
  )

  colname <- deparse(substitute(col))
  pred_colname <- deparse(substitute(pred_col))
  pred_str <- "(all)" 
  if (pred_colname != "TRUE") {
    pred_str <- str_c("(", pred_colname, ")")
  }
  y_label <- str_c(colname, "rate", pred_str, sep = " ")

  ggplot(tbl, aes(x = reorder(subject_race, -rate), y = rate)) + 
    geom_bar(stat = "identity") +
    xlab("race") +
    ylab(y_label)
}


search_conducted_by_race_plot <- plot_prop_by_race(search_conducted)
contraband_found_by_race_plot <- plot_prop_by_race(contraband_found)
predicated_contraband_found_by_race_plot <- 
  plot_prop_by_race(contraband_found, search_conducted)
if ("contraband_drugs" %in% colnames(d$data)) {
  predicated_contraband_drugs_by_race_plot <- 
    plot_prop_by_race(contraband_drugs, search_conducted)
}
predicated_contraband_weapons_by_race_plot <- NA
if ("contraband_weapons" %in% colnames(d$data)) {
  predicated_contraband_weapons_by_race_plot <- 
    plot_prop_by_race(contraband_weapons, search_conducted)
}


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
