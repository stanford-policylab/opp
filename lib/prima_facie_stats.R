library(here)
source(here::here("lib", "opp.R"))


prima_facie_stats_cities <- function(only = NULL) {
  if (is.null(only)) {
    only <- opp_available()
  }
  f <- function(state, city) {
    prima_facie_stats(state, city) %>%
    mutate(state = state, city = city)
  }
  tbl <- only %>%
    filter(city != "Statewide") %>%
    par_pmap(f)
    # par_pmap(f) %>%
    # bind_rows() %>%
    # select(state, city, everything()) %>%
    # arrange(state, city, year, subject_race) %>%
    # aggregate_prima_facie_stats(2012, 2017) %>%
    # filter(subject_race %in% c("white", "black", "hispanic"))
  tbl
  # list(
  #   data = tbl,
  #   plot = compose_prima_facie_stats_plots(tbl)
  # )
}


prima_facie_stats <- function(state, city) {

  tbl <-
    opp_load_clean_data(state, city) %>%
    filter_to_complete_years() %>%
    add_columns_if_not_present(
      "subject_race",
      "search_conducted",
      "frisk_performed",
      "warning_issued",
      "citation_issued",
      "arrest_made"
    ) %>%
    ensure_present(date, subject_race, p = 0.9)

  # if (nrow(tbl) > 0) {
  #   tbl <-
  #     tbl %>%    
  #     mutate(
  #       year = year(date),
  #       subject_race = as.character(subject_race)
  #     ) %>%
  #     group_by(year, subject_race) %>%
  #     summarize(
  #       stop_count = n(),
  #       search_count = sum_if_not_all_na(search_conducted),
  #       frisk_count = sum_if_not_all_na(frisk_performed),
  #       warning_count = sum_if_not_all_na(warning_issued),
  #       citation_count = sum_if_not_all_na(citation_issued),
  #       arrest_count = sum_if_not_all_na(arrest_made)
  #     ) %>%
  #     inner_join(
  #       opp_demographics(state, city),
  #       by = c("subject_race" = "race", "year" = "year")
  #     ) %>%
  #     rename(population = total) %>%
  #     mutate(
  #       stop_rate = stop_count / population,
  #       search_rate = search_count / stop_count,
  #       frisk_rate = frisk_count / stop_count,
  #       # NOTE: warnings, citations, and arrests can be used to infer whether
  #       # the data has the 'universe' of stops; if one or several of these are
  #       # missing, it's unclear whether the stop count truly reflects all police
  #       # stops, i.e. a department only records a stop when it results in a
  #       # citation
  #       warning_rate = warning_count / stop_count,
  #       citation_rate = citation_count / stop_count,
  #       arrest_rate = arrest_count / stop_count
  #     ) %>%
  #     select(
  #       year,
  #       subject_race,
  #       population,
  #       stop_count,
  #       stop_rate,
  #       search_count,
  #       search_rate,
  #       frisk_count,
  #       frisk_rate,
  #       warning_count,
  #       warning_rate,
  #       citation_count,
  #       citation_rate,
  #       arrest_count,
  #       arrest_rate
  #     ) %>%
  #     arrange(
  #       year,
  #       subject_race
  #     )
  # }
  tbl
}


filter_to_complete_years <- function(tbl, min_monthly_stops = 100) {
  # NOTE: years where at least one month had fewer than 3 standard deviations
  # below the yearly mean stop count or fewer than min_monthly_stops are
  # removed

  year_month_counts <-
    tbl %>%
    mutate(year = year(date), year_month = format(date, "%Y-%m")) %>%
    group_by(year, year_month) %>%
    count()

  year_stats <-
    year_month_counts %>%
    group_by(year) %>%
    summarize(
      mu = mean(n),
      sd = sd(n),
      mu_less_3_sd = mu - 3 * sd
    )

  valid_years <-
    year_month_counts %>%
    left_join(year_stats) %>%
    mutate(is_valid = n > max(min_monthly_stops, mu_less_3_sd)) %>%
    group_by(year) %>%
    summarize(valid_total = sum(is_valid)) %>%
    ungroup() %>%
    filter(valid_total == 12)

  res <- tibble()
  if (nrow(valid_years) > 0)
    res <- filter(tbl, year(date) %in% pull(valid_years, year))
  res
}


ensure_present <- function(tbl, ..., p = 0.9) {
  if (nrow(tbl) > 0) {
    colqs <- enquos(...)
    before <- nrow(tbl)
    tbl <- drop_na(tbl, !!!colqs)
    after <- nrow(tbl)
    null_rate <- (before - after) / before
    if (null_rate > (1 - p))
      tbl <- tibble()
  }
  tbl
}


add_columns_if_not_present <- function(tbl, ...) {
  for (col in list(...)) {
    if (!(col %in% colnames(tbl))) {
      tbl <- mutate(tbl, !!col := NA)
    }
  }
  tbl
}


sum_if_not_all_na <- function(v) {
  if_else(all(is.na(v)), NA_integer_, sum(v, na.rm = T))
}


aggregate_prima_facie_stats <- function(
  stats,
  start_year = 2012,
  end_year = 2017
) {
  stats %>%
    filter(year >= start_year, year <= end_year) %>%
    group_by(state, city, subject_race) %>%
    summarize(
      population_total = sum(population),
      stop_total = sum(stop_count),
      search_total = sum(search_count),
      frisk_total = sum(frisk_count),
      warning_total = sum(warning_count),
      citation_total = sum(citation_count),
      arrest_total = sum(arrest_count)
    ) %>%
    mutate(
      stop_rate = stop_total / population_total,
      search_rate = search_total / stop_total,
      frisk_rate = frisk_total / stop_total,
      warning_rate = warning_total / stop_total,
      citation_rate = citation_total / stop_total,
      arrest_rate = arrest_total / stop_total
    ) %>%
    select(state, city, subject_race, matches("rate"), everything())
}


compose_prima_facie_stats_plots <- function(tbl) {
  tbl <-
    tbl %>%
    gather(metric, rate, -state, -city, -subject_race) %>%
    filter(str_detect(metric, "rate")) %>%
    mutate(
      metric = factor(
        metric,
        levels = c(
          "stop_rate",
          "search_rate",
          "frisk_rate",
          "warning_rate",
          "citation_rate",
          "arrest_rate"
        )
      )
    )

  ggplot(
    tbl,
    aes(
      x = subject_race,
      y = rate,
      fill = subject_race
    )
  ) +
  geom_bar(stat = "identity") +
  facet_grid(city ~ metric) +
  scale_fill_manual(values = c("black", "red", "blue"))
}
