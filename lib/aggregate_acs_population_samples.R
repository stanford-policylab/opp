#!/usr/bin/env Rscript

library(tidyverse)
library(here)

# NOTE: ACS data is downloaded from https://usa.ipums.org/usa/
# to_csv.py in py-utils uses the *.sas file to convert the fixed-width
# dat file to a csv; this script converts that file into aggregate data,
# which is faster to load and process for the city-level analyses

aggregate_acs_population_samples <- function(
    acs_csv = here::here("data", "acs.csv"),
    output_acs_agg_csv=here::here("data", "acs_agg.csv")
  ) {

    tr_race <- c(
      "White" = "white",
      "Black/African American/Negro" = "black",
      "American Indian or Alaska Native" = "other/unknown",
      "Chinese" = "asian/pacific islander",
      "Japanese" = "asian/pacific islander",
      "Other Asian or Pacific Islander" = "asian/pacific islander",
      "Other race, nec" = "other/unknown",
      "Two major races" = "other/unknown",
      "Three or more major races" = "other/unknown",
      "hispanic" = "hispanic"
    )
    
    is_hispanic <- function(hispanic_origin) {
      hispanic_origin %in% c("Mexican", "Puerto Rican", "Cuban", "Other")
    }

    read_csv(
      acs_csv,
      col_types = cols(.default = "c")
    ) %>%
    rename(
      city = City,
      year = `Census year`,
      race = `Race [general version]`,
      hispanic_origin = `Hispanic origin [general version]`,
      weight = `Person weight`
    ) %>%
    mutate(
      # NOTE: each "person" in the sample represents a count ("weight") of
      # persons in the population; this figure is in hundredths of a person, so
      # we divide by 100 to get "whole people"
      race = tr_race[ifelse(is_hispanic(hispanic_origin), "hispanic", race)],
      count = as.integer(as.integer(weight) / 100)
    ) %>%
    group_by(
      city,
      year,
      race
    ) %>%
    summarize(
      total = sum(count)
    ) %>%
    select(
      city,
      year,
      race,
      total
    ) %>%
    arrange(
      city,
      year,
      race
    ) %>%
    write_csv(
      output_acs_agg_csv
    )
  }


if (!interactive()) {
  aggregate_acs_population_samples()
}
