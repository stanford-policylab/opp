source('opp.R')


calculate_rates <- function(state, city) {
  tbl <- opp_load_data(state, city)
  dem_tbl <- opp_demographics(state, city)
  list(
    stop_rate = rate(tbl, dem_tbl),
    frisk_rate = rate(tbl, dem_tbl, fltr("frisk_performed")),
    search_rate = rate(tbl, dem_tbl, fltr("search_conducted"))
  )
}


fltr <- function(colname) {
  function(tbl) {
    if (colname %in% colnames(d)) {
      filter_(tbl, colname)
    } else {
      NA
    }
  }
}


rate <- function(
  tbl,
  # contains populations by race
  demographics_tbl,
  data_pre_func = function(x) { x },
  demographics_pre_func = function(x) { x }
) {
  tbl <- data_pre_func(tbl)
  if (!is.na(tbl) && nrow(tbl) != 0) {
    demographics_tbl <- demographics_pre_func(demographics_tbl)
    mutate(
      tbl,
      year = year(date)
    ) %>%
    rename(
      race = subject_race
    ) %>%
    group_by(
      year,
      race
    ) %>%
    summarize(
      count = n()
    ) %>%
    full_join(
      demographics_tbl
    ) %>%
    mutate(
      rate = count / total
    ) %>%
    select(
      year,
      race,
      rate
    ) %>%
    arrange(
      year,
      race,
      rate
    ) %>%
    na.omit()
  } else {
    NA
  }
}
