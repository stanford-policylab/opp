#!/usr/bin/env Rscript
source("policy_change_test.R")


marijuana_legalization <- function() {
  policy_change_test(
    test_tbl = tribble(
      ~state, ~city, ~change_date, ~violation_regex,
      "CO", "Statewide", "2012-12-10", "marijuana",
      # TODO(danj): WA also has Drugs Paraphernalia - Misdemeanor
      "WA", "Statewide", "2012-12-09", "drugs - misdemeanor"
    ),
    # TODO(danj): ensure all of these have correctly classified search bases
    control_tbl = tribble(
      ~state, ~city,
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
    ),
    eligible_search_bases = c("k9", "plain view", "probable cause")
  )
}


mtest <- function() {
  policy_change_test(
    test_tbl = tribble(
      ~state, ~city, ~change_date, ~violation_regex,
      "CO", "Statewide", "2012-12-10", "marijuana",
      # TODO(danj): WA also has Drugs Paraphernalia - Misdemeanor
      "WA", "Statewide", "2012-12-09", "drugs - misdemeanor"
    ),
    # TODO(danj): ensure all of these have correctly classified search bases
    control_tbl = tribble(
      ~state, ~city,
      "AZ", "Statewide"
    ),
    eligible_search_bases = c("k9", "plain view", "probable cause")
  )
}


if (!interactive()) {
  marijuana_legalization()
}
