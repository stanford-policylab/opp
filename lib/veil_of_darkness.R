source(here::here("lib", "opp.R"))
source(here::here("lib", "e.R"))
source(here::here("lib", "veil_of_darkness_test.R"))

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
  
  results <- list(coefficients = coefficients)
  
  write_rds(results, here::here("cache", "vod_dst_results.rds"))
  results
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
            ### TODO(amy): do we want year too?
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
  
  write_rds(results, here::here("cache", "vod_full_results.rds"))
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

select_data_with_dst_ranges <- function(d, plot_path = NULL) {
  d <- d %>% 
    mutate(
      yr = year(date),
      day = day(date), 
      month = month(date),
      spring_range = month %in% 2:4 & !(month == 2 & day < 15)
      & !(month == 4 & day > 15),
      fall_range = month %in% 10:11
    ) 
  stops_per_range <- d %>% 
    count(state, city, yr, month, date) %>% 
    group_by(state, city, yr, month) %>% 
    summarize(
      avg_stops_per_day = sum(n)/n(),
      avg_stops_per_dst_range = 60 * avg_stops_per_day
    ) %>% 
    group_by(state, city, yr) %>% 
    summarize(
      sd_per_dst_range = sd(avg_stops_per_dst_range),
      avg_stops_per_dst_range = mean(avg_stops_per_dst_range)
    )
  tbl <- d %>% 
    filter(spring_range | fall_range) 
  
  full_ranges <- tbl %>% 
    count(state, city, yr, spring_range, fall_range) %>% 
    left_join(stops_per_range) %>% 
    filter(
      n > avg_stops_per_dst_range - 3*sd_per_dst_range,
      n < avg_stops_per_dst_range + 3*sd_per_dst_range
    )
  if (not_null(plot_path)) {
    p <- tbl %>% 
      count(state, city, yr, spring_range, fall_range, date) %>% 
      ggplot(aes(date, n, fill = spring_range)) + 
      geom_col() + 
      facet_grid(rows = vars(city), cols = vars(yr), scales = "free")
    write_rds(tbl, here::here("cache", plot_path))
  }
  tbl %>%
    inner_join(full_ranges)
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
      dst_model(
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
    coefs <- broom::tidy(mod) %>% ### TODO: change to have the two estimates
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

