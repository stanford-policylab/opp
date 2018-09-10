source('opp.R')


calculate_stats <- function(state, city) {
  list(
    stop = stop_rate(state, city),
    frisk = frisk_rate(state, city),
    search = search_rate(state, city)
  )
}

stop_rate <- function(state, city) {
  rate(state, city)
}

frisk_rate <- function(state, city) {
  rate(state, city, fltr("frisk_performed"))
}

search_rate <- function(state, city) {
  rate(state, city, fltr("search_conducted"))
}


fltr <- function(colname) {
  function(d) {
    if (colname %in% colnames(d)) {
      filter_(d, colname)
    } else {
      NA
    }
  }
}


rate <- function(
  state,
  city,
  data_pre_func = function(x) { x },
  demographics_pre_func = function(x) { x }
) {
  d <- data_pre_func(opp_load_data(state, city))
  if (!is.na(d) && nrow(d) != 0) {
    dem <- demographics_pre_func(opp_demographics(state, city))
    mutate(
      d,
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
      dem
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
    )
  } else {
    NA
  }
}
