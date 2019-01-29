source(here::here("lib", "common.R"))
# NOTE: there still appear to be slight count differences between old opp and our 
# cleaned data. However, it appears that our data formats have changed since the last
# pull/process (of old opp), which may account for some of the differences. Furthermore,
# the data has no race or outcome information, so it was not used in the old analysis and
# will not be used in our analysis.
load_raw <- function(raw_data_dir, n_max) {
  # NOTE: For 2012 we only have the last quarter or so of stops. For 2016 we
  # only have the first quarter. The years in between are complete, except for
  # maybe April 2013, where there is a dip, and Sept 2015 (see note below).
  # NOTE: in Sept of 2015, the format changes a bit, where superfluous
  # asterisk rows and which column contains true county name is not a problem
  # anymore and leads to improper filterings. We import months thereafter separately to 
  # deal with them accordingly.
  # TODO(amy): The format changes within the month of Sept 2015, so at some point we should
  # address that month in a more nuanced way (right now it's being processed in the format
  # that corresponds to the majority of rows, but in doing so we lose some data)
  warnings <- load_regex(raw_data_dir, "warnings.csv", n_max = n_max)
  citations <- load_regex(raw_data_dir, "citations.csv", n_max = n_max)
  warnings_new <- load_regex(raw_data_dir, "warnings_new_format.csv", n_max = n_max)
  citations_new <- load_regex(raw_data_dir, "citations_new_format.csv", n_max = n_max)
  old_format <-
    bind_rows(
      warnings$data %>% mutate(warning_issued = TRUE, citation_issued = FALSE),
      citations$data %>% mutate(warning_issued = FALSE, citation_issued = TRUE)
    ) %>%
    # NOTE: when first column (X1) is not NA, it's a summation description and all 
    # other columns are NA, so we drop these summation rows
    # NOTE: when County is given, all other rows are NA or string of asterisks,
    # so we filter to only cases when County is NA, and then remove that column.
    # (County Freeform contains actual county information for rows with data, so we
    # rename it to county_name)
    filter(is.na(X1), is.na(County)) %>%
    select(-X1, county_name = `County Freeform`, everything())
  new_format <- 
    bind_rows(
      warnings_new$data %>% mutate(warning_issued = TRUE, citation_issued = FALSE),
      citations_new$data %>% mutate(warning_issued = FALSE, citation_issued = TRUE)
    ) %>%
    # NOTE: when first column (X1) is not NA, it's a summation description and all 
    # other columns are NA, so we drop these summation rows
    filter(is.na(X1)) %>%
    select(-X1, county_name = `County`, everything())
  bind_rows(old_format, new_format) %>% 
    filter(!str_detect(`Issued Date/Time`, "\\*")) %>% 
    bundle_raw(c(
      warnings$loading_problems, citations$loading_problems,
      warnings_new$loading_problems, citations_new$loading_problems
    ))
}


clean <- function(d, helpers) {

  # TODO(phoebe): can we get reason_for_stop/search/contraband/race/etc fields?
  # https://app.asana.com/0/456927885748233/733449078894622
  d$data %>%
    rename(
      location = Address,
      vehicle_color = `Color 1`,
      vehicle_make = Make,
      vehicle_model = Model,
      vehicle_year = Year,
      vehicle_registration_state = `Plate State`
    ) %>%
    separate_cols(
      `Issued Date/Time` = c("date", "time")
    ) %>%
    mutate(
      date = parse_date(date, "%Y/%m/%d"),
      time = parse_time(time, "%H:%M:%S"),
      county_name = str_to_title(county_name),
      subject_sex = tr_sex[Sex],
      # NOTE: only have vehicular data for SD
      type = "vehicular",
      violation = str_replace_all(`Statutes/Charges`, "; ", "|"),
      outcome = first_of(
        citation = citation_issued,
        warning = warning_issued
      )
    ) %>%
    standardize(d$metadata)
}
