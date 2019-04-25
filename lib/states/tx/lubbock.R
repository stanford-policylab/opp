source("common.R")

load_raw <- function(raw_data_dir, n_max) {
  d <- load_years(raw_data_dir, n_max)
  d$data <-
    d$data %>%
    mutate(officer_name = coalesce(`Officers -NAME`, `Officers - NAME`)) %>%
    select(-`Officers -NAME`, -`Officers - NAME`) %>%
    make_ergonomic_colnames()
  bundle_raw(d$data, d$loading_problems)
}


clean <- function(d, helpers) {
  # TODO(phoebe): can we get reason_for_stop/search/contraband fields?
  # https://app.asana.com/0/456927885748233/1117283630988007
  # TODO(phoebe): can we get demographic information, i.e. race/sex?
  # https://app.asana.com/0/456927885748233/1117283630988008
  d$data %>%
  rename(
    location = location_address
  ) %>%
  separate_cols(
    officer_name = c("officer_last_name", "officer_first_name"),
    sep = ", "
  ) %>%
  # TODO(phoebe): can we get a mapping for disposition?
  # https://app.asana.com/0/456927885748233/1117283630988009
  mutate(
    # NOTE: there are two call_type_orig values, T and SS, assumed to be
    # traffic and subject stop, as elsewhere
    type = if_else(call_type_orig == "T", "vehicular", "pedestrian"),
    date = parse_date(call_created_date, "%Y/%m/%d"),
    warning_issued = disposition == "WRN",
    citation_issued = disposition == "TKT",
    outcome = first_of(
      citation = citation_issued,
      warning = warning_issued
    )
  ) %>%
  helpers$add_lat_lng(
  ) %>%
  standardize(d$metadata)
}
