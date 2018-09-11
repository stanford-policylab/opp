#' Threshold Test
#'
#' A test to determine and compare thresholds used by officers in decididng
#' whether to conduct a search or search of different groups (e.g., whites vs
#' minorities)
#'
#' @param stops must include a race var and smaller geographic unit var
#' @keywords threshold test
#' @export
#' @examples
#' threshold_test()

threshold_test <- function(
  stops,
  geographic_unit_col = district,
  race_col = race,
  searched_col = searched,
  contraband_found_col = contraband_found,
  n_iter = 5000,
  n_cores = 5 # change default to detect number of cores available
){

  geographic_unit_col <- enquo(geographic_unit_col)
  race_col <- enquo(race_col)
  searched_col <- enquo(searched_col)
  contraband_found_col <- enquo(contraband_found_col)

  init_method <- 'random'
  n_chains <- 5 # number of Markov chains to be run
  refresh_every <- 50 # number of iterations before progress is printed
  n_warmup <- min(2500, round(n_iter / 2))
  adapt_delta <- 0.95 # proportion of accepts
  max_tree_depth <- 12 # tree depth for NUTS
  adapt_engaged <- TRUE

  data <- format_for_stan(search_recovery_rates(
    stops,
    !!geographic_unit_col,
    !!race_col,
    !!searched_col,
    !!contraband_found_col
  ))

  # fit the threshold test stan model
  sampling(
    stan_model("threshold_test.stan"),
    data = data,
    iter = n_iter,
    init = init_method,
    chains = n_chains,
    cores = n_cores,
    refresh = refresh_every,
    warmup = n_warmup,
    control = list(
      adapt_delta = adapt_delta,
      max_treedepth = max_tree_depth,
      adapt_engaged = adapt_engaged
    )
  )
}

search_recovery_rates <- function(
  stops,
  geographic_unit_col = district,
  race_col = race,
  searched_col = frisked,
  contraband_found_col = frisk_contraband_found
) {

  geographic_unit_col <- enquo(geographic_unit_col)
  race_col <- enquo(race_col)
  searched_col <- enquo(searched_col)
  contraband_found_col <- enquo(contraband_found_col)

  left_join(
    count_stops_and_searches_by_geo_unit_and_race(
      stops,
      !!geographic_unit_col,
      !!race_col,
      !!searched_col
    ),
    count_contraband_recovered_by_geo_unit_and_race(
      stops,
      !!geographic_unit_col,
      !!race_col,
      !!searched_col,
      !!contraband_found_col
    ),
    by = c(quo_name(geographic_unit_col), quo_name(race_col))
  ) %>%
  # NAs emerge in geographic units where zero contraband was recovered
  mutate(num_hits = replace_na(num_hits, 0))
}

count_stops_and_searches_by_geo_unit_and_race <- function(
  stops,
  geographic_unit_col = district,
  race_col = race,
  searched_col = searched
) {

  geographic_unit_col <- enquo(geographic_unit_col)
  race_col <- enquo(race_col)
  searched_col <- enquo(searched_col)

  count(
    stops,
    !!geographic_unit_col,
    !!race_col,
    !!searched_col
  ) %>%
  mutate(
    !!quo_name(searched_col) := if_else((!!searched_col), "num_searched", "num_not")
  ) %>%
  spread(
    !!searched_col,
    n,
    fill = 0
  ) %>%
  transmute(
    !!quo_name(geographic_unit_col) := as.factor(!!geographic_unit_col),
    !!quo_name(race_col) := !!race_col,
    num_stops = num_searched + num_not,
    num_searches = num_searched
  )
}

count_contraband_recovered_by_geo_unit_and_race <- function(
  stops,
  geographic_unit_col = district,
  race_col = race,
  searched_col = searched,
  contraband_found_col = contraband_found
) {

  geographic_unit_col <- enquo(geographic_unit_col)
  race_col <- enquo(race_col)
  searched_col <- enquo(searched_col)
  contraband_found_col <- enquo(contraband_found_col)

  filter(
    stops,
    !!searched_col,
    !!contraband_found_col
  ) %>%
  count(
    !!geographic_unit_col,
    !!race_col
  ) %>%
  mutate(
    !!quo_name(geographic_unit_col) := as.factor(!!geographic_unit_col)
  ) %>%
  rename(num_hits = n)
}

format_for_stan <- function(
  stop_aggregates,
  geographic_unit_col = district,
  race_col = race
) {

  geographic_unit_col <- enquo(geographic_unit_col)
  race_col <- enquo(race_col)

  list(
    N_OBSERVATIONS = nrow(stop_aggregates),
    N_GEOGRAPHIC_UNITS = n_distinct(pull(stop_aggregates, !!geographic_unit)),
    N_SUSPECT_RACES = n_distinct(pull(stop_aggregates, !!race_col)),
    geographic_unit = as.integer(pull(stop_aggregates, !!geographic_unit)),
    race = as.integer(pull(stop_aggregates, !!race_col)),
    stops = pull(stop_aggregates, num_stops),
    searches = pull(stop_aggregates, num_searches),
    hits = pull(stop_aggregates, num_hits)
  )
}
