#!/usr/bin/env Rscript
source(here::here("lib", "opp.R"))
source(here::here("lib", "analysis_common.R"))
library(rstan)


ELIGIBLE_STATES <- tribble(
  ~state, ~city,
  # test
  "CO", "Statewide",
  "WA", "Statewide",
  # control
  "AZ", "Statewide",
  "CA", "Statewide",
  "FL", "Statewide",
  "MA", "Statewide",
  "MT", "Statewide",
  "NC", "Statewide",
  "OH", "Statewide",
  "RI", "Statewide",
  "SC", "Statewide",
  "TX", "Statewide",
  "VT", "Statewide",
  "WI", "Statewide"
)


marijuana_legalization_analysis <- function(output_dir = NULL) {
  tbl <- load()
  test <- filter(tbl, state %in% c("CO", "WA"))
  control <- filter(tbl, !(state %in% c("CO", "WA")))
  results <- list(
    tables = list(
      search_rate_difference_in_difference_coefficients =
        calculate_search_rate_difference_in_difference_coefficients(tbl)
    ),
    plots = list(
      test_search_rates = compose_search_rate_plots(test),
      control_search_rates = compose_search_rate_plots(control, is_test = F),
      test_misdemeanor_rates = compose_misdemeanor_rate_plots(test),
      inferred_threshold_changes =
        compose_inferred_threshold_changes_plot(test)
    )
  )

  if (!is.null(output_dir))
    saveRDS(results, file.path(output_dir, "mj.rds"))

  results
}


load <- function() {
  opp_load_all_clean_data(ELIGIBLE_STATES) %>%
  filter(
    type == "vehicular",
    subject_race %in% c("black", "white", "hispanic"),
    year(date) >= 2011 & year(date) <= 2015,
    !(state == "FL" && department_name == "FLORIDA DEPARTMENT OF AGRICULTURE"),
    !(state == "NC" && department_name != "NC State Highway Patrol"),
    # NOTE: collison stops are qualitatively different: they have 3x the search
    # rate and lower hit rates with a larger impact on whites and hispanics
    !(state == "SC" && reason_for_stop == "Collision")
  ) %>%
  mutate(
    subject_race = relevel(droplevels(subject_race), "white")
  ) %>%
  add_legalization_info()
}


add_legalization_info <- function(tbl) {
  mutate(
    tbl,
    # NOTE: default for control and WA is WA's legalization date
    legalization_date = as.Date("2012-12-09"),
    legalization_date = if_else(
      state == "CO",
      as.Date("2012-12-10"),
      legalization_date
    ),
    is_before_legalization = date < legalization_date,
    is_test = state %in% c("WA", "CO"),
    is_treatment = is_test & !is_before_legalization
  )
}


calculate_search_rate_difference_in_difference_coefficients <- function(tbl) {
  tbl <- 
    tbl %>%
    filter(
      type == "vehicular",
      !is.na(date),
      !is.na(subject_race),
      # NOTE: search_basis = NA is interpreted as an eligible search, so don't
      # filter out
      !is.na(search_conducted)
    ) %>%
    select(
      is_treatment,
      state,
      date,
      legalization_date,
      subject_race,
      search_basis,
      search_conducted
    ) %>%
    mutate(
      # NOTE: excludes other (non-discretionary)
      is_eligible_search = search_conducted & (is.na(search_basis)
        | search_basis %in% c("k9", "plain view", "probable cause", "consent"))
    ) %>%
    group_by(
      is_treatment,
      state,
      date,
      legalization_date,
      subject_race
    ) %>%
    summarize(
      n_eligible_searches = sum(is_eligible_search, na.rm = T),
      n_stops_with_search_data = n()
    ) %>%
    ungroup(
    ) %>%
    mutate(
      years_since_legalization = as.numeric(date - legalization_date) / 365
    )

  m <- glm(
    cbind(n_eligible_searches, n_stops_with_search_data - n_eligible_searches)
      ~ state + years_since_legalization + subject_race +
        is_treatment:subject_race,
    binomial,
    tbl
  )

  coefs <- summary(m)$coefficients[, c("Estimate", "Std. Error")]

  as_tibble(coefs) %>%
    mutate(coefficient = rownames(coefs)) %>%
    rename(estimate = Estimate, std_error = `Std. Error`) %>%
    select(coefficient, estimate, std_error)
}


compose_search_rate_plots <- function(tbl, is_test = T) {
  tbl <-
    tbl %>%
    filter(
      type == "vehicular",
      !is.na(date),
      !is.na(subject_race)
    ) %>%
    select(
      state,
      date,
      legalization_date,
      is_before_legalization,
      subject_race,
      search_basis,
      search_conducted
    ) %>%
    mutate(
      is_eligible_search = search_conducted & (is.na(search_basis)
        # NOTE: excludes other (non-discretionary)
        | search_basis %in% c("k9", "plain view", "probable cause", "consent"))
    ) %>%
    group_by(
      state,
      date,
      legalization_date,
      is_before_legalization,
      subject_race
    ) %>%
    summarize(
      n_eligible_searches = sum(is_eligible_search, na.rm = T),
      n_stops_with_search_data = sum(!is.na(search_conducted))
    ) %>%
    ungroup()

  trends <- compute_trendlines(tbl)

  tbl <-
    tbl %>%
    # NOTE: roll up to quarters to reduce noisiness
    to_rates_by_quarter(n_eligible_searches, n_stops_with_search_data) %>%
    # NOTE: remove data around legalization quarter since it will be mixed
    filter(quarter != as.Date("2012-11-15"))

  compose_timeseries_rate_plot(tbl, "Search Rate", trends, is_test)
}


compute_trendlines <- function(tbl) {
  trendlines <- group_by(tbl, state) %>% do(compute_search_trendline(.))
  endpoints <-
    trendlines %>%
    group_by(state, subject_race, is_before_legalization) %>%
    filter(date == min(date) | date == max(date)) %>%
    mutate(position = if_else(date == min(date), "start", "end"))
  dt <- select(endpoints, -predicted_search_rate) %>% spread(position, date)
  rt <- select(endpoints, -date) %>% spread(position, predicted_search_rate)
  left_join(
    rename(dt, start_date = start, end_date = end),
    rename(rt, start_rate = start, end_rate = end)
  )
}


compute_search_trendline <- function(tbl) {
  fit <- function(tbl) {
    glm(
      # NOTE: (n_successes, n_failures) ~ X
      # NOTE: date is interpreted numerically
      cbind(n_eligible_searches, n_stops_with_search_data - n_eligible_searches)
        ~ subject_race + date,
      binomial,
      tbl
    )
  }
  m_before <- fit(filter(tbl, is_before_legalization))
  m_after <- fit(filter(tbl, !is_before_legalization))
  score <- function(model, tbl) { predict(model, tbl, type = "response") }
  tbl %>%
    group_by(state, subject_race, is_before_legalization) %>%
    filter(date == min(date) | date == max(date)) %>%
    distinct() %>%
    ungroup() %>%
    mutate(
      predicted_search_rate = if_else(
        is_before_legalization,
        score(m_before, .),
        score(m_after, .)
      )
    ) %>%
    select(
      state,
      subject_race,
      date,
      is_before_legalization,
      predicted_search_rate
    )
}


to_rates_by_quarter <- function(tbl, numerator_col, denominator_col) {
  nq <- enquo(numerator_col)
  dq <- enquo(denominator_col)
  n_name <- quo_name(nq)
  d_name <- quo_name(dq)
  group_by_colnames <- c(
    setdiff(
      colnames(tbl),
      c(n_name, d_name, "date")
    ),
    "quarter"
  )
  tbl <-
    tbl %>%
    mutate(
      quarter = as.Date(str_c(
        year(date),
        c("-02-", "-05-", "-08-", "-11-")[quarter(date)],
        "15"
      ))
    ) %>%
    group_by(.dots = group_by_colnames) %>%
    summarize(rate = sum(!!nq) / sum(!!dq)) %>%
    ungroup()
}


compose_timeseries_rate_plot <- function(
  tbl,
  y_axis_label,
  trends = NULL,
  is_test = T
) {
  p <-
    ggplot(
      tbl,
      aes(
        x = quarter,
        y = rate,
        color = subject_race,
        group = interaction(subject_race, is_before_legalization)
      )
    ) +
    geom_line(
    ) +
    geom_vline(
      xintercept = tbl$legalization_date,
      linetype = "longdash"
    ) +
    facet_wrap(
      state ~ .,
      scales = "free_y"
    ) +
    scale_color_manual(
      values = c("blue", "black", "red"),
      labels = c("White", "Black", "Hispanic")
    ) +
    scale_y_continuous(
      y_axis_label,
      labels = function(x) scales::percent(x, accuracy = 0.01),
      expand = c(0, 0)
    ) +
    expand_limits(
      y = -0.0001
    ) +
    base_theme(
    ) +
    theme(
      # NOTE: ifelse and if_else can't return vectors
      legend.position = if (is_test) c(0.88, 0.88) else c(0.96, 0.95),
      axis.title.x = element_blank(),
      panel.spacing = unit(0.5, "lines"),
      plot.margin = unit(c(0.1, 0.2, 0.1, 0.1), "in")
    )

  if (!is.null(trends)) {
    p <-
      p +
      geom_segment(
        data = trends,
        aes(
          x = start_date,
          xend = end_date,
          y = start_rate,
          yend = end_rate,
          color = subject_race,
          group = interaction(subject_race, is_before_legalization)
        ),
        linetype = "longdash",
        size = 0.8
      )
  }

  p
}


compose_misdemeanor_rate_plots <- function(tbl) {
  filter(
    tbl,
    type == "vehicular",
    is_test,
    !is.na(date),
    !is.na(subject_race)
  ) %>%
  select(
    state,
    date,
    legalization_date,
    is_before_legalization,
    subject_race,
    violation
  ) %>%
  mutate(
    violation = str_to_lower(violation),
    is_drugs_infraction_or_misdemeanor = if_else(
      state == "CO",
      # NOTE: Details on Colorado's marijuana policies:
      # https://www.colorado.gov/pacific/marijuana/driving-and-traveling
      str_detect(
        violation,
        str_c(
          "possession of 1 oz or less of marijuana",
          # NOTE: these spike after legalization
          # "open marijuana container",
          sep = "|"
        )
      ),
      # NOTE: WA violations
      str_detect(
        violation,
        str_c(
          "drugs - misdemeanor",
          "drugs paraphernalia - misdemeanor",
          sep = "|"
        )
      )
    )
  ) %>%
  group_by(
    state,
    date,
    legalization_date,
    is_before_legalization,
    subject_race
  ) %>%
  summarize(
    n_drugs_infraction_or_misdemeanor =
      sum(is_drugs_infraction_or_misdemeanor, na.rm = T),
    n_stops_with_violation_data = sum(!is.na(violation))
  ) %>%
  ungroup(
  ) %>%
  # NOTE: roll up to quarters to reduce noisiness
  to_rates_by_quarter(
    n_drugs_infraction_or_misdemeanor,
    n_stops_with_violation_data
  ) %>%
  # NOTE: remove data around legalization quarter since it will be mixed
  filter(
    quarter != as.Date("2012-11-15")
  ) %>%
  compose_timeseries_rate_plot("Drugs Infraction & Misdemeanor Rate")
}


compose_inferred_threshold_changes_plot <- function(tbl) {
  bind_rows(
    collect_aggregate_thresholds_for_state(tbl, "CO"),
    collect_aggregate_thresholds_for_state(tbl, "WA")
  ) %>% 
  plot_threshold_changes()
}


collect_aggregate_thresholds_for_state <- function(tbl, state) {
  data_summary <- summarise_for_stan(filter(tbl, state == state)) 
  stan_data <- format_data_summary_for_stan(data_summary)
  fit <- stan_marijuana_threshold_test(stan_data)
  posteriors <- rstan::extract(fit)
  data_with_thresholds <- add_thresholds(data_summary, posteriors)
  summary_stats(data_with_thresholds, posteriors, state)
}


summarise_for_stan <- function(tbl) {
  filter(
    tbl,
    !is.na(subject_race), 
    !is.na(county_name)
  ) %>% 
  mutate(
    # NOTE: excludes consent and other (non-discretionary)
    eligible_search_conducted = search_conducted & (is.na(search_basis) | 
      search_basis %in% c("k9", "consent", "plain view", "probable cause")),
    race_cd = as.integer(subject_race),
    county_cd = as.integer(as.factor(county_name)),
    legal = !is_before_legalization
  ) %>% 
  group_by(
    state, county_name, county_cd,
    race_cd, subject_race, legal
  ) %>%
  summarize(
    num_stops = n(),
    num_searches = sum(eligible_search_conducted, na.rm = T),
    num_hits = sum(eligible_search_conducted & contraband_found, na.rm = T)
  ) %>% 
  ungroup()
}


format_data_summary_for_stan <- function(d) {
  list(
    n_groups = nrow(d),
    n_sub_geographies = n_distinct(pull(d, county_name)),
    n_races = n_distinct(pull(d, subject_race)),
    sub_geography = pull(d, county_cd),
    legal = pull(d, as.integer(legal)),
    race = pull(d, race_cd),
    stop_count = pull(d, num_stops),
    search_count = pull(d, num_searches),
    hit_count = pull(d, num_hits)
  )
}


stan_marijuana_threshold_test <- function(
  data,
  n_iter = 5000,
  n_cores = min(5, parallel::detectCores() / 2)
) {
  # NOTE: defaults; may expose more of these in the future
  allow_adaptive_step_size <- T
  initialization_method <- "random"
  min_acceptable_divergence_rate <- 0.05
  n_iter_per_progress_update <- 50
  n_iter_warmup <- min(2500, round(n_iter / 2))
  n_markov_chains <- 5
  nuts_max_tree_depth <- 12
  path_to_stan_model <- here::here("stan", "threshold_test_marijuana.stan")
  
  rstan::sampling(
    stan_model(path_to_stan_model),
    data,
    chains = n_markov_chains,
    control = list(
      adapt_delta = 1 - min_acceptable_divergence_rate,
      adapt_engaged = allow_adaptive_step_size,
      max_treedepth = nuts_max_tree_depth
    ),
    cores = n_cores,
    init = initialization_method,
    iter = n_iter,
    refresh = n_iter_per_progress_update,
    warmup = n_iter_warmup
  )
}


add_thresholds <- function(
  data_summary,
  posteriors
) {
  data_summary %>%
    mutate(
      threshold = colMeans(signal_to_percent(
        posteriors$threshold, 
        posteriors$phi, 
        posteriors$delta
      ))
    )
}


summary_stats <- function(obs, post, state) {
  threshold_cis(
    obs, post,
    groups = c('legal', 'subject_race'),
    weights = obs %>% 
      group_by(county_name, legal) %>%
      mutate(w=sum(num_stops)) %>%
      with(w)
  ) %>% 
  mutate(state = state)
}


threshold_cis = function(
  obs,
  post,
  groups = 'subject_race',
  weights = NULL,
  probs = c(0.025, 0.5, 0.975)
) {
  if (is.null(weights)) {
    weights <-
      group_by(obs, county_name) %>%
      mutate(w = sum(num_stops)) %>%
      with(w)
  }
  
  t <- t(signal_to_percent(
    post$threshold,
    post$phi,
    post$delta
  ))
  
  mutate(obs, idx = row_number()) %>%
  group_by_(.dots = groups) %>%
  do(
    as.data.frame(t(quantile(
      colSums(weights[.$idx] * t[.$idx,]) / sum(weights[.$idx]), 
      probs = probs
    )))
  ) %>% 
  left_join(
    group_by_(obs, .dots = groups) %>% summarize(mean = mean(threshold)),
    by = groups
  )
}

# converts the threshold signal into a percent value (0, 1)
signal_to_percent <- function(x, phi, delta) {
  phi * dnorm(x, delta, 1) / 
    (phi * dnorm(x, delta, 1) + (1 - phi) * dnorm(x, 0, 1))
}


plot_threshold_changes <- function(tbl) {
  ungroup(tbl) %>% 
  mutate(
    legal = factor(
      if_else(legal, "Post", "Pre"), 
      levels = c("Pre", "Post")
    ),
    subject_race = factor(
      subject_race, 
      levels = c("white", "black", "hispanic")
    )
  ) %>%
  ggplot(aes(legal, `50%`, color = subject_race)) +
  geom_line(aes(group = subject_race)) +
  geom_segment(aes(xend = legal, y = `2.5%`, yend = `97.5%`)) +
  scale_colour_manual(
    values = c("blue", "black", "red"), 
    labels = c("White", "Black", "Hispanic")
  ) +
  scale_y_continuous(
    "Inferred Threshold", 
    limits = c(.25, .75), 
    labels = scales::percent, 
    expand = c(0,0)
  ) +
  theme_bw() +
  facet_grid(cols = vars(state)) +
  labs(
    color = "",
    x = "Legalization Period"
  )
}


if (!interactive()) {
  marijuana_legalization_analysis()
}
