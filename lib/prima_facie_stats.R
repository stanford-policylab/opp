library(here)
source(here::here("lib", "opp.R"))


# TODO(danj): get IPUMS updated 2017 population data
prima_facie_stats_aggregated <- function() {
  prima_facie_stats() %>%
    group_by(state, city, subject_race) %>%
    summarize(
    )
}


prima_facie_stats_cities <- function() {
  f <- function(state, city) {
    prima_facie_stats(state, city) %>% mutate(state = state, city = city)
  }
  opp_available() %>%
    filter(city != "Statewide") %>%
    par_pmap(f) %>%
    bind_rows() %>%
    select(state, city, everything()) %>%
    arrange(state, city, year, subject_race)
}


prima_facie_stats <- function(state, city) {
  opp_load_clean_data(state, city) %>%
    add_columns_if_not_present(
      "subject_race",
      "search_conducted",
      "frisk_performed",
      "outcome"
    ) %>%
    mutate(
      year = year(date),
      # NOTE: outcome encodes harshest action taken during a stop, so
      # this may undercount warnings and citations
      is_warning = outcome == "warning",
      is_citation = outcome == "citation",
      is_arrest = outcome == "arrest"
    ) %>%
    group_by(year, subject_race) %>%
    summarize(
      stop_count = n(),
      search_count = sum_if_not_all_na(search_conducted),
      frisk_count = sum_if_not_all_na(frisk_performed),
      warning_count = sum_if_not_all_na(is_warning),
      citation_count = sum_if_not_all_na(is_citation),
      arrest_count = sum_if_not_all_na(is_arrest)
    ) %>%
    left_join(opp_demographics(state, city)) %>%
    rename(population = total) %>%
    mutate(
      stop_rate = stop_count / population,
      search_rate = search_count / stop_count,
      frisk_rate = frisk_count / stop_count,
      # NOTE: warnings, citations, and arrests can be used to infer whether
      # the data has the 'universe' of stops; if one or several of these are
      # missing, it's unclear whether the stop count truly reflects all police
      # stops, i.e. a department only records a stop when it results in a
      # citation
      warning_rate = warning_count / stop_count,
      citation_rate = citation_count / stop_count,
      arrest_rate = arrest_count / stop_count
    ) %>%
    select(
      year,
      subject_race,
      population,
      stop_count,
      stop_rate,
      search_count,
      search_rate,
      frisk_count,
      frisk_rate,
      warning_count,
      warning_rate,
      citation_count,
      citation_rate,
      arrest_count,
      arrest_rate
    ) %>%
    arrange(
      year,
      subject_race
    )
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
