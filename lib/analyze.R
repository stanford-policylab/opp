source("opp.R")
source("basic_statistics.R")
source("benchmark_test.R")
source("outcome_test.R")
source("threshold_test.R")
source("risk_adjusted_regression_test.R")

function analyze(state, city) {
  d <- opp_load_data(state, city)
  p <- opp_population(state, city)
  list(
    basic_statistics = basic_statistics(d, p),
    benchmark_test = benchmark_test(d),
    outcome_test = outcome_test(d),
    threshold_test = threshold_test(d),
    risk_adjusted_regression_test = risk_adjusted_regression_test(d)
  )
}
