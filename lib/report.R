library(here)
source(here::here("lib", "opp.R"))

# SOURCE
d <- opp_load_clean(state, city)
data <- d$data
metadata <- d$metadata


# HELPERS
has_col <- function(col) {
  has_cols(c(col))
}


has_cols <- function(cols) {
  all(cols %in% colnames(data))
}


calculate_if_col <- function(col, func) {
  calculate_if_cols(c(col), func)
}


calculate_if_cols <- function(cols, func) {
  if (has_cols(cols)) {
    func()
  }
}


display_if_exists <- function(var_name) {
  if (exists(var_name)) {
    str_to_expr(var_name)
  }
}


percent <- function(col) {
  pretty_percent(mean(data[[col]], na.rm = TRUE))
}


# NOTE: this can make some percentages appear high; for instance,
# when search_conducted is true and contraband_found is only TRUE or NA, it
# will remove the NAs so only count TRUE instances
predicated_percent <- function(col, pred_col) {
  idx <- data[[pred_col]]
  pretty_percent(mean(data[[col]][idx], na.rm = TRUE))
}


plot_prop_by_race <- function(col, pred_col = TRUE) {
  colq <- enquo(col)
  pred_colq <- enquo(pred_col)
  tbl <- group_by(
    data,
    subject_race
  ) %>%
  summarize(
    rate = mean(`!!`(colq)[`!!`(pred_colq)], na.rm = TRUE)
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


# REPORT VARIABLES
title <- create_title(state, city)

if (str_to_title(city) == "Statewide") {
  population <- opp_state_population(state, city)
} else {
  population <- opp_city_population(state, city)
}

total_rows <- nrow(data)

date_range <- range(data$date, na.rm = TRUE)
start_date <- date_range[1]
end_date <- date_range[2]

by_type <- group_by(data, type) %>% count

by_type_table <- kable(by_type)

null_rates_table <- kable(
  predicated_null_rates(data, reporting_predicated_columns) %>%
  mutate(`null rate` = pretty_percent(`null rate`, 2)),
  align = c("l", "r")
)

by_year <- group_by(data, yr = year(date)) %>% count

by_year_plot <- ggplot(by_year) +
  geom_bar(aes(x = factor(yr), y = n), stat = "identity") +
  xlab("year") +
  ylab("count")


d_ym <- mutate(
		data,
		yr = year(date),
		year_month = month(date)
	) %>%
  group_by(
		yr,
		year_month
	) %>%
  count

by_year_by_month_plot <- ggplot(d_ym) +
  geom_bar(
    aes(x = factor(year_month, levels = seq(1:12)), y = n),
    stat = "identity"
  ) +
  facet_grid(yr ~ .) +
  xlab("month of year") +
  ylab("count") +
  scale_fill_discrete(drop=FALSE) +
  scale_x_discrete(drop=FALSE)

d_yd <- mutate(
		data,
		yr = year(date),
		year_day = yday(date)
	) %>%
  group_by(
		yr,
		year_day
	) %>%
  count

by_year_by_day_plot <- ggplot(d_yd) +
  geom_bar(
    aes(x = year_day, y = n),
    stat = "identity"
  ) +
  facet_grid(yr ~ .) +
  xlab("day of year") +
  ylab("count") +
  xlim(0, 366)

d_yw <- mutate(
		data,
		yr = year(date),
		day_of_week = wday(date, label = TRUE)
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


calculate_if_col("time", function() {
  d_yh <- mutate(
      data,
      yr = year(date),
      hr = hour(time)
    ) %>%
    group_by(
      yr,
      hr
    ) %>%
    count

  by_year_by_hour_of_day_plot <<- ggplot(d_yh) +
    geom_bar(aes(x = hr, y = n), stat = "identity") +
    facet_grid(yr ~ .) +
    xlab("hour of day") +
    ylab("count")
})

calculate_if_col("subject_race", function() {
  race_pct_tbl <- pct_tbl(data$subject_race, c("race", "percent"))
  race_present_pct <- pretty_percent(1 - null_rate(data$subject_race))
  race_pct_plot <<- ggplot(race_pct_tbl) +
    geom_bar(
      aes(x = reorder(race, -percent), y = percent),
      stat = "identity"
    ) +
    xlab(str_c(
      "race",
      str_c("(represents", race_present_pct, "of stops)", sep = " "),
      sep = "\n"
    ))
})

calculate_if_col("reason_for_stop", function() {
  reason_for_stop_top_20 <- top(data, reason_for_stop, n = 20)
  reason_for_stop_top_20_pct <-
    pretty_percent(sum(reason_for_stop_top_20$count) / nrow(data))
  reason_for_stop_top_20_plot <<- ggplot(reason_for_stop_top_20) +
    geom_bar(
      aes(x = reorder(reason_for_stop, -count), y = count),
      stat = "identity"
    ) +
    theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
    xlab(str_c(
      "reason for stop",
      str_c("(represents", reason_for_stop_top_20_pct, "of stops)", sep = " "),
      sep = "\n"
    ))
})

calculate_if_col("search_basis", function() {
  search_bases_tbl <- filter(data, !is.na(search_basis)) %>% 
    group_by(search_basis) %>%
    summarize(n = n()) %>%
    mutate(pct = n / sum(n))
  search_bases_plot <<- ggplot(search_bases_tbl) +
    geom_bar(
      aes(x = reorder(search_basis, -pct), y = pct),
      stat = "identity"
    ) +
    xlab("search type (where search conducted)")
})

search_conducted_pct <- percent("search_conducted")
contraband_found_pct <- percent("contraband_found")
predicated_contraband_found_pct <- predicated_percent(
  "contraband_found",
  "search_conducted"
)

calculate_if_cols(c("subject_race", "search_conducted"), function() {
  search_conducted_by_race_plot <<- plot_prop_by_race(search_conducted)
})

calculate_if_cols(c("subject_race", "contraband_found"), function() {
  contraband_found_by_race_plot <<- plot_prop_by_race(contraband_found)
})

calculate_if_cols(
  c("subject_race", "contraband_found", "search_conducted"),
  function() {
    predicated_contraband_found_by_race_plot <<- 
      plot_prop_by_race(contraband_found, search_conducted)
  }
)

calculate_if_cols(
  c("subject_race", "contraband_drugs"),
  function() {
    predicated_contraband_drugs_by_race_plot <<- 
      plot_prop_by_race(contraband_drugs, search_conducted)
  }
)

calculate_if_cols(
  c("subject_race", "contraband_weapons"),
  function() {
    predicated_contraband_weapons_by_race_plot <<- 
      plot_prop_by_race(contraband_weapons, search_conducted)
  }
)

calculate_if_cols(
  c("subject_race", "outcome"),
  function() {
    d_o <- group_by(
        data,
        subject_race,
        outcome
      ) %>%
      summarize(
        n = n()
      ) %>%
      mutate(
        proportion = n / sum(n)
      )

    outcome_by_race_plot <<- ggplot(d_o) +
      geom_bar(aes(x = outcome, y = proportion), stat = "identity") +
      facet_grid(subject_race ~ .) +
      xlab("outcome")
  }
)



# NOTE: convert to char because of weird print representation of some numbers
loading_problems <-
  metadata$loading_problems %>%
  lapply(function(x) mutate_all(x, funs('as.character'))) %>%
  bind_rows()

if (nrow(loading_problems) > 0) {

  loading_problems_count <- group_by(
      loading_problems,
      col,
      expected
    ) %>%
    count

  loading_problems_count_table <<- kable(
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

  loading_problems_random_sample_sorted_table <<- kable(
    loading_problems_random_sample_sorted,
    caption = "20 Random loading problem errors, sorted"
  )

}

enforce_types_table <- kable(
	metadata$standardize$enforce_types,
	caption = "Enforce data types null rates"
)

if (nrow(metadata$standardize$predication_correction) > 0)
  correct_predicates_table <- kable(
    metadata$standardize$predication_correction,
    caption = "Correct predicated columns"
  )

sanitize_table <- kable(
	metadata$standardize$sanitize,
	caption = "Sanitize data null rates"
)
