source(here::here("lib", "common.R"))

load_raw <- function(raw_data_dir, n_max) {
  dept <- load_regex(raw_data_dir, "*agencies*")
  d <- load_regex(
    raw_data_dir,
    "*race*",
    n_max = n_max,
    col_types = cols(
      .default = "c",
      TotalStops = "i",
      TotalStops_Searches = "i",
      TotalStops_Discovery = "i"
    )
  )

  # NOTE: Stops / searches are aggregated by year, agency, and race. Dis-
  # aggregate data so one row represents one stop. Note also that the source
  # files contain other aggregated statistics that we omit here because they
  # are not crosstabulated. 
  agg <- left_join(
    d$data,
    dept$data %>% 
      select(AgencyID, PoliceDepartment, WorkCity) %>% 
      # NOTE: to standardize city spellings; 
      # TODO(amyshoe) needs more standardization if it's to be trust
      mutate(WorkCity = str_to_title(str_replace_all(WorkCity, "'", ""))) %>%
      distinct(),
    by = 'AgencyID'
  ) %>%
  # NOTE: We drop values that are logically inconsistent. In particular, if
  # 1) the number of searches exceeds the number of stops, or 2) the number
  # of contraband discoveries exceeds the number of searches, we will ignore
  # this row.
  filter(
    TotalStops >= TotalStops_Searches,
    TotalStops_Searches >= TotalStops_Discovery
  )


  bind_rows(
    # Rows for stops where contraband was found
    disaggregate(
      agg,
      TotalStops_Discovery,
      year = Year,
      department_name = PoliceDepartment,
      # NOTE: Including city is iffy because depts have multiple cities per
      # agency (and multiple spellings of department, and multiple spellings of cities
      # within department) which causes duplicates in disaggregation.
      location = WorkCity,
      race = Race
    ) %>%
    mutate(search_conducted = TRUE, contraband_found = TRUE),
    # Rows for searches without contraband
    disaggregate(
      agg,
      TotalStops_Searches - TotalStops_Discovery,
      year = Year,
      department_name = PoliceDepartment,
      location = WorkCity,
      race = Race
    ) %>%
    mutate(search_conducted = TRUE, contraband_found = FALSE),
    # Rows for stops without searches
    disaggregate(
      agg,
      TotalStops - TotalStops_Searches,
      year = Year,
      department_name = PoliceDepartment,
      location = WorkCity,
      race = Race
    ) %>%
    mutate(search_conducted = FALSE, contraband_found = FALSE)
  ) %>%
  bundle_raw(c(d$loading_problems, dept$loading_problems))
}


clean <- function(d, helpers) {
  d$metadata["comments"]["aggregation"] <- str_c(
    "Source data are aggregated by year. Data for one year is given on the ",
    "first day of that year. Source data contain more variables than race, ",
    "search, and contraband_found, but since these other variables are not ",
    "cross-tabulated we can't de-aggregate and include them in the cleaned ",
    "data."
  )

  tr_race <- c(
    "Asian" = "asian/pacific islander",
    "Black" = "black",
    "Hispanic" = "hispanic",
    "Native American" = "other/unknown",
    "Other" = "other/unknown",
    "White" = "white"
  )

  # TODO(phoebe): can we get reason_for_stop/search fields and more info on
  # subject (gender, age, etc). Can we get all the raw data (not aggregated)?
  # https://app.asana.com/0/456927885748233/750432191393464 
  d$data %>%
    mutate(
      # NOTE: all source data are traffic stops.
      type = "vehicular",
      date = parse_date(str_c(year, "0101"), "%Y%m%d"),
      subject_race = tr_race[race]
    ) %>%
    standardize(d$metadata)
}
