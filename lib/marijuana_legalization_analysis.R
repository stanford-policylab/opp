library(here)
source(here::here("lib", "opp.R"))
source(here::here("lib", "eligibility.R"))

marijuana_legalization_analysis <- function(use_cache=FALSE) {
  
  mj <- load("mj", use_cache)$data
  mjt <- load("mjt", use_cache)$data

  list(
    tables = list(
      search_rate_difference_in_difference_coefficients =
        calculate_search_rate_difference_in_difference_coefficients(mj)
    ),
		treatment_discretionary_searches_with_no_contraband =
      treatment_discretionary_searches_with_no_contraband(mj),
    plots = list(
      search_rates = group_by(mj, state) %>%
        group_map(
          ~ rate_time_series(
            .x,
            .y$state[1],
            "is_discretionary_search",
            "search_conducted"
          )
        ) %>%
        unlist(recursive=FALSE),
      misdemeanor_rates = filter(mj, state %in% c("CO", "WA")) %>%
        group_by(state) %>%
        group_map(
          ~ rate_time_series(
            .x,
            .y$state[1],
            "is_drug_infraction_or_misdemeanor",
            "violation"
          )
        ) %>%
        unlist(recursive=FALSE),
      inferred_threshold_changes = list(
        counts = list(
          co = nrow(filter(mjt, state == "CO")),
          wa = nrow(filter(mjt, state == "WA"))
        ),
        prior_scaling_factor_0.5 = compose_inferred_threshold_changes_plot(
          mjt,
          prior_scaling_factor = 0.5
        ),
        prior_scaling_factor_1 = compose_inferred_threshold_changes_plot(
          mjt,
          prior_scaling_factor = 1.0
        ),
        prior_scaling_factor_1.5 = compose_inferred_threshold_changes_plot(
          mjt,
          prior_scaling_factor = 1.5
        )
      )
    )
  )
}

treatment_discretionary_searches_with_no_contraband <- function(tbl) {
	tbl %>%
	filter(
		state %in% c("CO", "WA"),
		is_discretionary_search,
		!contraband_found
	) %>%
	mutate(days_since_legalization = date - legalization_date) %>%
	filter(
		days_since_legalization >= -days(365),
		days_since_legalization <= days(365)
	) %>%
	group_by(is_before_legalization) %>%
	count() %>%
	spread(is_before_legalization, n) %>%
	rename(before = `TRUE`, after = `FALSE`) %>%
	mutate(decrease_rate = (before - after) / before)
}


calculate_search_rate_difference_in_difference_coefficients <- function(tbl) {
  tbl %<>%
    filter(
      # NOTE: don't filter in global filter because violation and
      # search_conducted may be NA in different places, so filter locally
      !is.na(search_conducted)
    ) %>%
    group_by(
      state,
      date,
      subject_race,
      legalization_date,
      is_treatment
    ) %>%
    summarize(
      n_discretionary_searches = sum(is_discretionary_search),
      n_stops_with_search_data = n()
    ) %>%
    ungroup(
    ) %>%
    mutate(
      years_since_legalization = as.numeric(date - legalization_date) / 365
    )

  glm(
    cbind(
      n_discretionary_searches,
      n_stops_with_search_data - n_discretionary_searches
    ) ~
    state
    + years_since_legalization
    + subject_race
    + is_treatment:subject_race,
    binomial,
    tbl
  ) %>%
  tidy()
}


rate_time_series <- function(
  tbl,
  state,
  numerator,
  denominator
) {

  # NOTE: this is a hack so we can get the state from group_map
  tbl$state <- state
	legalization_date <- tbl$legalization_date[[1]]

  daily <- tbl %>%
    filter(!is.na(get(denominator))) %>%
    group_by(state, subject_race, is_before_legalization, date) %>%
    summarize(
      n_numerator = sum(get(numerator)),
      n_denominator = n(),
      rate = n_numerator / n_denominator
    ) %>%
    ungroup()

  quarterly <- daily %>%
    mutate(
      quarter = as.Date(str_c(
        year(date),
        c("-02-", "-05-", "-08-", "-11-")[quarter(date)],
        "15"
      ))
    ) %>%
    group_by(state, subject_race, is_before_legalization, quarter) %>%
    summarize(rate = sum(n_numerator) / sum(n_denominator)) %>%
    ungroup() %>%
    # NOTE: remove data around legalization quarter since it will be mixed
    filter(quarter != as.Date("2012-11-15"))
  
  v <- list()
  v[[state]] <- list(
    plot = plot_rate_time_series(daily, quarterly, legalization_date),
    count = sum(daily$n_denominator),
    # for website
    quarterly = quarterly,
    trendlines = trendlines_for_website(state, daily)
  )
  v
}

plot_rate_time_series <- function(daily, quarterly, legalization_date) {
  ggplot() +
  geom_smooth(
    data=filter(daily, is_before_legalization),
    aes(x=date, y=rate, color=subject_race),
    formula=y ~ x,
    method="lm",
    linetype="dashed",
    size=0.5
  ) +
  geom_smooth(
    data=filter(daily, !is_before_legalization),
    aes(x=date, y=rate, color=subject_race),
    formula=y ~ x,
    method="lm",
    linetype="dashed",
    size=0.5
  ) +
  geom_line(
    data=quarterly,
    aes(
      x=quarter,
      y=rate,
      color=subject_race,
      group=interaction(subject_race, is_before_legalization)
    )
  ) +
  scale_color_manual(
    values=c("blue", "black", "red")
  ) +
  geom_vline(
    xintercept=legalization_date,
    linetype="longdash"
  ) +
  scale_y_continuous(
    labels=scales::percent_format(accuracy = 0.1),
  ) +
  expand_limits(
    x=c(as.Date('2011-01-01'), as.Date('2015-12-31')),
    y=0
  ) +
  theme_bw(
    base_size=15
  ) +
  theme(
    panel.background = element_rect(fill = "white", color = "white"),
    panel.grid.major=element_blank(),
    panel.grid.minor=element_blank(),
    axis.title.x=element_blank(),
    axis.title.y=element_blank(),
    legend.position="none"
  ) +
  # NOTE: hack to get facet_grid style title
  facet_grid(. ~ state)
}


trendlines_for_website <- function(state, daily) {
  before = filter(daily, is_before_legalization)
  after = filter(daily, !is_before_legalization)

  bmin = min(before$date)
  bmax = max(before$date)
  amin = min(after$date)
  amax = max(after$date)

  bw = lm(rate ~ date, data=filter(before, subject_race == 'white'))
  bb = lm(rate ~ date, data=filter(before, subject_race == 'black'))
  bh = lm(rate ~ date, data=filter(before, subject_race == 'hispanic'))
  aw = lm(rate ~ date, data=filter(after, subject_race == 'white'))
  ab = lm(rate ~ date, data=filter(after, subject_race == 'black'))
  ah = lm(rate ~ date, data=filter(after, subject_race == 'hispanic'))

  bw_min = predict(bw, data.frame(date = c(bmin)))
  bw_max = predict(bw, data.frame(date = c(bmax)))
  bb_min = predict(bb, data.frame(date = c(bmin)))
  bb_max = predict(bb, data.frame(date = c(bmax)))
  bh_min = predict(bh, data.frame(date = c(bmin)))
  bh_max = predict(bh, data.frame(date = c(bmax)))

  aw_min = predict(aw, data.frame(date = c(amin)))
  aw_max = predict(aw, data.frame(date = c(amax)))
  ab_min = predict(ab, data.frame(date = c(amin)))
  ab_max = predict(ab, data.frame(date = c(amax)))
  ah_min = predict(ah, data.frame(date = c(amin)))
  ah_max = predict(ah, data.frame(date = c(amax)))

  tribble(
      ~state,
      ~race,
      ~is_before_legalization,
      ~start_date,
      ~end_date,
      ~start_rate,
      ~end_rate,
      state, 'white', TRUE, bmin, bmax, bw_min, bw_max,
      state, 'black', TRUE, bmin, bmax, bb_min, bb_max,
      state, 'hispanic', TRUE, bmin, bmax, bh_min, bh_max,
      state, 'white', FALSE, amin, amax, aw_min, aw_max,
      state, 'black', FALSE, amin, amax, ab_min, ab_max,
      state, 'hispanic', FALSE, amin, amax, ah_min, ah_max
  )
}


compose_inferred_threshold_changes_plot <- function(tbl, prior_scaling_factor = 1) {
  co <- collect_aggregate_thresholds_for_state(tbl, "CO", prior_scaling_factor)
  wa <- collect_aggregate_thresholds_for_state(tbl, "WA", prior_scaling_factor)
  list(
    plot = bind_rows(
      co$summary_stats,
      wa$summary_stats
    ) %>% 
    plot_threshold_changes(),
    metadata = list(
      co_rhat = co$rhat,
      co_n_eff = co$n_eff,
      wa_rhat = wa$rhat,
      wa_n_eff = wa$n_eff
    )
  )
}


collect_aggregate_thresholds_for_state <- function(tbl, s, prior_scaling_factor = 1) {
  data_summary <- summarise_for_stan(filter(tbl, state == s)) 
  stan_data <- format_data_summary_for_stan(data_summary, prior_scaling_factor)
  fit <- stan_marijuana_threshold_test(stan_data)
  fit_summary <- summary(fit)$summary
  rhat <- fit_summary[,'Rhat'] %>% max(na.rm = T)
  n_eff <- fit_summary[,'n_eff'] %>% min(na.rm = T)
  posteriors <- rstan::extract(fit)
  data_with_thresholds <- add_thresholds(data_summary, posteriors)
  list(
    summary_stats = summary_stats(data_with_thresholds, posteriors, s),
    rhat = rhat,
    n_eff = n_eff
  )
}


summarise_for_stan <- function(tbl) {
  tbl %>%
  # NOTE: Needed for threshold test; no included in global filter, because
  # it's not needed for statewide search rates and some control states dont
  # have county
  filter(!is.na(county_name)) %>%
  mutate(
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
    num_searches = sum(is_discretionary_search, na.rm = T), 
    num_hits = sum(is_discretionary_search & contraband_found, na.rm = T)
  ) %>% 
  ungroup()
}


format_data_summary_for_stan <- function(d, prior_scaling_factor = 1) {
  list(
    n_groups = nrow(d),
    n_subgeographies = n_distinct(pull(d, county_name)),
    n_races = n_distinct(pull(d, subject_race)),
    subgeography = pull(d, county_cd),
    legal = pull(d, as.integer(legal)),
    race = pull(d, race_cd),
    stop_count = pull(d, num_stops),
    search_count = pull(d, num_searches),
    hit_count = pull(d, num_hits),
    prior_scaling_factor = prior_scaling_factor
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
  path_to_stan_model <- here::here("stan", "threshold_test_marijuana_identified.stan")
  
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

signal_to_percent <- function(x, phi, delta) {
  # converts the threshold signal into a percent value (0, 1)
  phi * dnorm(x, delta, 1) / 
    (phi * dnorm(x, delta, 1) + (1 - phi) * dnorm(x, 0, 1))
}


plot_threshold_changes <- function(tbl) {
  ungroup(tbl) %>% 
  mutate(
    legal = factor(
      if_else(legal, "Post", "Pre"), 
      levels = c("Pre", "Post")
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
    labels = scales::percent_format(accuracy = 1), 
    expand = c(0,0)
  ) +
  theme_bw() +
  theme(
    panel.background = element_rect(fill = "white", color = "white")
  ) +
  facet_grid(cols = vars(state)) +
  labs(
    color = "",
    x = "Legalization Period"
  )
}
