source("common.R")

load_raw <- function(raw_data_dir, n_max) {
  d <- load_single_file(raw_data_dir, "pdr100317tpdstops_sheet_1.csv", n_max)
  bundle_raw(d$data, d$loading_problems)
}


clean <- function(d, helpers) {
  # NOTE: reason for stop not recorded
  # NOTE: search/contraband not in database, only in written reports
  # NOTE: subject race is not recorded
  d$data %>%
    rename(
      location = Location,
      officer_id = Unit
    ) %>%
    mutate(
      # NOTE: T = "Traffic Stop", SS = "Subject Stop"
      type = if_else(Type == "T", "vehicular", "pedestrian"),
      date = parse_date(Date, "%Y/%m/%d"),
      time = parse_time(Time, "%H:%M:%S"),
      warning_issued = str_detect(Disposition, "Warning"),
      citation_issued = str_detect(Disposition, "Citation"),
      arrest_made = str_detect(Disposition, "Arrest"),
      # TODO(ravi): do we want to filter out outcomes we don't care about?
      # https://app.asana.com/0/456927885748233/590576541432184
      outcome = first_of(
        arrest = arrest_made,
        citation = citation_issued,
        warning = warning_issued
      )
    ) %>%
    helpers$add_lat_lng(
    ) %>%
    helpers$add_shapefiles_data(
    ) %>%
    rename(
      sector = SECTOR,
      subsector = SUBSECTOR
    ) %>%
    standardize(d$metadata)
}
