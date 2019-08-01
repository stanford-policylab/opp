library(here)
source(here::here("lib", "eligibility.R"))

veil_of_darkness_daylight_savings <- function(from_cache = F) {
  if (from_cache) 
    vod_dst <- read_rds(here::here("cache", "vod_dst.rds"))
  else {
    vod_dst <- load("vod_dst")
  }
  d <- prep_vod_data(vod_dst$data)
  
  print("Running model...")
  # Run actual test
  coefficients <- 
    par_pmap(
      mc.cores = 3,
      tibble(
        degree = rep(1:6, 4), 
        interact = c(rep(T, 12), rep(F, 12)),
        agency = rep(c(rep(T, 6), rep(F, 6)), 2)
      ),
      function(degree_var, interact_var, agency_var) {
        r <- vod_coef(dst = T, d, geography, degree_var, interact_var, agency_var) 
        r$coefficients %>% 
          mutate(
            data = "counties and cities",
            base_controls = "time, location, season, year",
            agency_control = agency_var,
            interact_time_loc = interact_var,
            spline_degree = degree_var
          )
      }
    ) %>% bind_rows()
  
  coefficients
}

veil_of_darkness_full <- function(from_cache = F) {
  if (from_cache) 
    vod_full <- read_rds(here::here("cache", "vod_full.rds"))
  else {
    vod_full <- load("vod_full")
  }
  
  d <- prep_vod_data(vod_full$data)
  
  coefficients <-
    par_pmap(
      mc.cores = 3,
      tibble(degree = 6, interact = T),
      function(degree, interact) {
        r1 <- vod_coef(dst = F, d, geography, degree, interact)
        r2 <- vod_coef(
          dst = F, 
          filter(d, is_state_patrol), 
          geography, 
          degree, interact
        )
        r3 <- vod_coef(
          dst = F, 
          filter(d, !is_state_patrol), 
          geography, 
          degree, interact
        )
        bind_rows(
          r1$coefficients, r2$coefficients, r3$coefficients
        ) %>%
          mutate(
            data = c(
              "counties and cities",
              "states",
              "cities"
            ),
            base_controls = "time, geography",
            spline_degree = degree,
            interact_time_loc = interact
          )
      }
    ) %>% bind_rows()
  
  results <- list(
    coefficients = coefficients, 
    plots = list(
      states = compose_vod_plots(
        filter(d, is_state_patrol), 
        state
      ),
      cities = compose_vod_plots(
        filter(d, !is_state_patrol), 
        geography
      )
    )
  )
  results
}

prep_vod_data <- function(tbl, minority_demographic = "black") {
  tbl %<>%
    mutate(
      is_state_patrol = city == "Statewide",
      is_dark = minute >= dusk_minute,
      is_minority_demographic = subject_race == minority_demographic,
      rounded_minute = plyr::round_any(minute, 5)
    )
}

vod_coef <- function(
  dst = F, 
  tbl, 
  control_col, 
  degree, 
  interact_time_location,
  interact_dark_agency = F,
  store_model = F
) {
  control_colq <- enquo(control_col)
  if(dst) {
    mod <-
      train_dst_model(
        tbl, 
        degree = degree, 
        interact_dark_agency = interact_dark_agency,
        interact_time_location = interact_time_location
      ) 
  } else {
    mod <- 
      train_vod_model(
        tbl,
        !!control_colq,
        spline_degree = degree,
        interact_time_location = interact_time_location
      )
  }
  if(interact_dark_agency) {
    coefs <- broom::tidy(mod) %>% 
      filter(str_detect(term, "is_dark")) %>% 
      mutate(agency = if_else(
        str_detect(term, "municipal"), 
        "municipal_pd", "state_patrol")
      ) %>%  
      select(is_dark = estimate, agency, std_error = std.error) 
  } else {
    coefs <- broom::tidy(mod) %>% 
      filter(term == "is_darkTRUE") %>% 
      select(is_dark = estimate, std_error = std.error)
  }
  if(store_model) {
    results <- list(model = mod, coefficients = coefs)
  } else {
    results <- list(coefficients = coefs)
  }
  results
}

train_dst_model <- function(
  tbl,
  state_patrol_indicator_col = is_state_patrol,
  demographic_indicator_col = is_minority_demographic,
  darkness_indicator_col = is_dark,
  time_col = rounded_minute,
  degree = 6,
  interact_dark_agency = F,
  interact_time_location = F
) {
  state_patrol_indicator_colq <- enquo(state_patrol_indicator_col)
  darkness_indicator_colq <- enquo(darkness_indicator_col)
  demographic_indicator_colq <- enquo(demographic_indicator_col)
  time_colq <- enquo(time_col)
  
  agg <-
    tbl %>%
    mutate(
      agency_type = factor(
        if_else(!!state_patrol_indicator_colq, "state_patrol", "municipal_pd"),
        levels = c("state_patrol", "municipal_pd")
      ),
      year = factor(year)
    ) %>% 
    group_by(
      !!darkness_indicator_colq,
      !!time_colq,
      agency_type,
      geography,
      season,
      year
    ) %>%
    summarize(
      n = n(),
      n_minority = sum(!!demographic_indicator_colq),
      n_majority = n - n_minority
    ) %>% 
    ungroup()
  
  fmla <- as.formula(
    str_c(
      "cbind(n_minority, n_majority) ~ ",
      if (interact_dark_agency) {
        str_c(
          "I(", quo_name(darkness_indicator_colq), 
          "*(agency_type == 'municipal_pd'))",
          " + I(", quo_name(darkness_indicator_colq), 
          "*(agency_type == 'state_patrol'))"
        )
      } else {
        quo_name(darkness_indicator_colq)
      },
      str_c(
        str_c(" + ns(", quo_name(time_colq), ", df = ", degree, ")"),
        "geography + ",
        sep = if (interact_time_location) "*" else " + "
      ),
      "season*year"
    )
  )
  print("Fitting model...")
  glm(fmla, data = agg, family = binomial)
}

train_vod_model <- function(
  tbl,
  ...,
  demographic_indicator_col = is_minority_demographic,
  darkness_indicator_col = is_dark,
  time_col = rounded_minute,
  degree = 6,
  interact_dark_time = F,
  interact_time_location = T
) {
  control_colqs <- enquos(...)
  darkness_indicator_colq <- enquo(darkness_indicator_col)
  demographic_indicator_colq <- enquo(demographic_indicator_col)
  time_colq <- enquo(time_col)
  
  agg <-
    tbl %>%
    group_by(
      !!darkness_indicator_colq,
      !!time_colq,
      !!!control_colqs
    ) %>%
    summarize(
      n = n(),
      n_minority = sum(!!demographic_indicator_colq),
      n_majority = n - n_minority
    )
  
  fmla <- as.formula(
    str_c(
      "cbind(n_minority, n_majority) ~ ",
      quo_name(darkness_indicator_colq),
      if (interact_dark_time) "*" else " + ",
      str_c(
        str_c("ns(", quo_name(time_colq), ", df = ", degree, ")"),
        quos_names(control_colqs),
        sep = if (interact_time_location) "*" else " + "
      )
    )
  )
  glm(fmla, data = agg, family = binomial, control = list(maxit = 100))
}

compose_vod_plots <- function(
  data, 
  geography_col = city_state,
  demographic_col = subject_race,
  minority_demographic = "black",
  time_range_start = hms("16:45:00"), 
  time_range_end = hms("21:30:00"),
  window_size = 15,
  path = NULL
) {
  geography_colq <- enquo(geography_col)
  demographic_colq <- enquo(demographic_col)

  data %>%
    filter(
      minute >= time_to_minute(time_range_start),
      minute <= time_to_minute(time_range_end) 
    ) %>% 
    mutate(
      rounded_minute = plyr::round_any(minute, 15, floor),
      time_str = minute_to_time(rounded_minute),
      minutes_since_dark = minute - dusk_minute,
      binned_minutes_since_dark = cut(
        minutes_since_dark,
        breaks = seq(-95, 65, 10),
        labels = seq(-90, 60, 10)
      )
    ) %>%
    filter(!is.na(binned_minutes_since_dark)) %>%
    group_by(binned_minutes_since_dark, minute, !!geography_colq) %>%
    mutate(
      n = n(),
      n_minority = sum(!!demographic_colq == minority_demographic),
      minutes_since_dark = as.integer(as.character(binned_minutes_since_dark))
    ) %>%
    ungroup() %>% 
    # NOTE: Remove ambiguously lit period between sunset and dusk
    # NOTE: We do this in pre-processing too, but after rounding
    #       some points get thrust into this range
    filter(!(minutes_since_dark > -30 & minutes_since_dark < 0)) %>% 
    select(
      !!geography_colq, 
      time_str, rounded_minute, minutes_since_dark, minute, 
      n, n_minority
    ) %>% 
    mutate(geography = !!geography_colq) %>% 
    group_by(!!geography_colq) %>% 
    do(
      plot = generate_time_sliced_vod_plots(., 
        minority_demographic, 
        window_size
      )
    ) %>%
    translator_from_tbl(
      quo_name(geography_colq),
      "plot"
    )
}

generate_time_sliced_vod_plots <- function(
  d, 
  minority_demographic = "black", 
  window_size = 15, eps = 0.05
) {
  loc_name <- unique(d$geography)
  prepare_data_for_timesliced_plot(
    d, minority_demographic, window_size, eps
  ) %>% 
    group_by(time_str) %>% 
    do(
      plot = ggplot(data = ., aes(
        minutes_since_dark,
        proportion_minority)
      ) +
        geom_point(aes(size = n)) +
        geom_smooth(
          aes(y = avg_p_minority, color = is_dark),
          method = "lm", se = F, linetype = "dashed"
        ) +
        geom_vline(xintercept = -25, linetype = "dotted") +
        geom_vline(xintercept = 0, linetype = "dotted") +
        geom_ribbon(
          data = filter(., is_dark),
          aes(ymin = avg_p_minority - 1.96*se, ymax = avg_p_minority + 1.96*se),
          alpha=0.3
        ) +
        geom_ribbon(
          data = filter(., !is_dark),
          aes(ymin = avg_p_minority - 1.96*se, ymax = avg_p_minority + 1.96*se),
          alpha=0.3
        ) +
        scale_x_continuous(
          "Minutes since dark",
          limits = c(-90, 60),
          breaks = seq(-90, 60, 15)
        ) +
        scale_y_continuous(
          str_c("Percent ", minority_demographic),
          limits = c(
            max(0, unique(.$y_min) - eps),
            min(1, unique(.$y_max) + eps)
          ),
          breaks = seq(0.0, 1.0, 0.02), 
          labels = scales::percent
        ) +
        scale_color_manual(values = c("blue", "blue")) +
        labs(
          title = str_c(
            loc_name, ", ",
            minute_to_time(unique(.$rounded_minute)), " to ",
            minute_to_time(unique(.$rounded_minute) + window_size)
          )
        )
    ) %>% 
    translator_from_tbl(
      "time_str",
      "plot"
    )
}

prepare_data_for_timesliced_plot <- function(
  data,
  minority_demographic = "black", 
  window_size = 15, eps = 0.05
) {
  data %>%
    group_by(minutes_since_dark, time_str, rounded_minute, geography) %>%
    summarise(
      proportion_minority = sum(n_minority) / sum(n),
      n = sum(n)
    ) %>%
    mutate(is_dark = minutes_since_dark >= 0) %>%
    group_by(is_dark, time_str) %>%
    mutate(
      avg_p_minority = weighted.mean(proportion_minority, w = n),
      se = sqrt(avg_p_minority * (1 - avg_p_minority) / sum(n))
    ) %>% 
    group_by(time_str) %>% 
    mutate(
      y_max = max(proportion_minority),
      y_min = min(proportion_minority)
    )
}

to_quarter_hour <- function(date, time) {
  format(
    round_date(ymd_hms(str_c(date, time, sep = " ")), "15 min"),
    "%H:%M:%S"
  )
}

minute_to_time <- function(minute) {
  str_c(
    as.character(minute %/% 60 - 12),
    ":",
    str_pad(as.character(minute %% 60), 2, pad = "0"),
    "pm"
  )
}



