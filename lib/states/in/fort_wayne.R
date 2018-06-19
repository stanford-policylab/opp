source("common.R")

load_raw <- function(raw_data_dir, n_max) {
  # NOTE: Roster.csv (police officer info) is available in raw data, but
  # doesn't join cleanly to stops data; first names are often truncated and
  # nicknames are used, i.e.  Manny vs Manuel; it can be loaded and reviewed
  # manually if desired.
  stops <- load_single_file(raw_data_dir, "Traffic stops.csv", n_max)
  disps <- load_single_file(raw_data_dir, "Dispositions.csv", n_max)
  left_join(
    stops$data,
    disps$data,
    by = c("Disposition" = "Abbreviation")
  ) %>%
  bundle_raw(c(stops$loading_problems, disps$loading_problems))
}


clean <- function(d, helpers) {

  # TODO(phoebe): can we get search/contraband information?
  # https://app.asana.com/0/456927885748233/585201226756920
  # TODO(phoebe): can we get reason for stop?
  # https://app.asana.com/0/456927885748233/585201226756921
  # TODO(phoebe): can we get subject race?
  # https://app.asana.com/0/456927885748233/585201226756922
  d$data %>%
    rename(
      location = `Incident address`
    ) %>%
    separate_cols(
      `Responsible Officer` = c("officer_last_name", "officer_first_name")
    ) %>%
    mutate(
      # NOTE: `Incident nature` is all "30 TRAFFIC STOP" so vehicular stops
      type = "vehicular",
      datetime = parse_datetime(`When reported`, "%m/%d/%Y %H:%M"),
      date = as.Date(datetime),
      time = format(datetime, "%H:%M"),
      citation_issued = str_detect(Description, "CITATION"),
      warning_issued = str_detect(Description, "WARNING"),
      arrest_made = str_detect(Description, "ARREST") &
        !str_detect(Description, "NO ARREST"),
      # TODO(ravi): do we want to filter out the other types of dispositions?
      # https://app.asana.com/0/456927885748233/585201226756923
      outcome = first_of(
        arrest = arrest_made,
        citation = citation_issued,
        warning = warning_issued
      )
    ) %>%
    helpers$add_lat_lng(
    ) %>%
    standardize(d$metadata)
}
