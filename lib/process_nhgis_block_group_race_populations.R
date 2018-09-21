#!/usr/bin/env Rscript

library(tidyverse)
library(here)


d <-
  read_csv(
    here::here("data", "nhgis_acs_2012_to_2016.csv"),
    skip=1
  )

dd <-
  select(
    d, 
    `State Name`,
    `GIS Join Match Code`,
    starts_with("Estimates"),
    -`Estimates: Area Name`,
    -`Estimates: Total`,
    # remove aggregate not-hispanic group
    -`Estimates: Not Hispanic or Latino`,
    # remove hispanic subdivisions
    -matches('Estimates: Hispanic or Latino:')
  ) %>%
  rename(
    state = `State Name`,
    gis_block_group_id = `GIS Join Match Code`,
    hispanic = `Estimates: Hispanic or Latino`,
    white = `Estimates: Not Hispanic or Latino: White alone`,
    black = `Estimates: Not Hispanic or Latino: Black or African American alone`
  ) %>%
  mutate(
    `asian/pacific islander` = rowSums(select(
      .,
      matches("Asian|Pacific Islander")
    )),
    other = rowSums(select(
      .,
      matches("Some other|Two or more|American Indian")
    ))
  ) %>%
  select(
    -matches(
      "Asian|Pacific Islander|Some other|Two or more|American Indian",
      ignore.case=F,
    )
  )

write_csv(
  dd, 
  here::here("data", "population_by_block_group_by_race_2012_to_2016.csv")
)

print('Population totals by state (2012-2016): ')
total_population_by_state <-
  mutate(
    dd,
    total_block_group = rowSums(select(
      dd,
      matches('white|black|asian|hispanic|other')
    ))
  ) %>%
  group_by(
    state
  ) %>%
  summarize(
    total = sum(total_block_group)
  ) %>%
  print(n = 100)

print('Population total margins of error by state (2012-2016): ')
total_margin_of_error_by_state <-
  group_by(
    d,
    `State Name`
  ) %>%
  summarize(
    total = sum(`Margins of error: Total`)
  ) %>%
  print(n = 100)
