source("common.R")

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
    dept$data,
    by = 'AgencyID'
  ) %>%
  # NOTE: We drop values that are logically inconsistent. In particular, if
  # 1) the number of searches exceeds the number of stops, or 2) the number
  # of contraband discoveries exceeds the number of searches we will ignore
  # this row.
  filter(
    TotalStops >= TotalStops_Searches,
    TotalStops_Searches >= TotalStops_Discovery
  )

  disaggregate <- function(tbl, n) {
    # Ensure that `n` doesn't contain any NAs.
    n_clean <- coalesce(n, 0L)
    tibble(
      year = rep(tbl$Year, n_clean),
      department_name = rep(tbl$PoliceDepartment, n_clean),
      location = rep(tbl$WorkCity, n_clean),
      race = rep(tbl$Race, n_clean)
    )
  } 

  rbind(
    # Rows for stops where contraband was found
    disaggregate(
      agg,
      agg$TotalStops_Discovery
    ) %>%
    mutate(search_conducted = TRUE, contraband_found = TRUE),
    # Rows for searches without contraband
    disaggregate(
      agg,
      agg$TotalStops_Searches - agg$TotalStops_Discovery
    ) %>%
    mutate(search_conducted = TRUE, contraband_found = FALSE),
    # Rows for stops without searches
    disaggregate(
      agg,
      agg$TotalStops - agg$TotalStops_Searches
    ) %>%
    mutate(search_conducted = FALSE, contraband_found = FALSE)
  ) %>%
  bundle_raw(c(d$loading_problems, dept$loading_problems))
}


clean <- function(d, helpers) {
  d$metadata['comments'] <- list()
  d$metadata['comments']['aggregation'] <- paste0(
    "Source data are aggregated by year. Data for one year is given on the "
    "first day of that year. Source data contain more variables than race, "
    "search, and contraband_found, but since these other variables are not "
    "cross-tabulated we can't de-aggregate and include them in the cleaned "
    "data."
  )

  tr_race = c(
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
