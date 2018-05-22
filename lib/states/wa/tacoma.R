source("common.R")

load_raw <- function(raw_data_dir, n_max) {
  fname <- "pdr100317tpdstops_sheet_1.csv"
  data <- read_csv(file.path(raw_data_dir, fname), n_max = n_max)
  loading_problems <- list()
  loading_problems[[fname]] <- problems(data)
  bundle_raw(data, loading_problems)
}


clean <- function(d, helpers) {
  # NOTE: reason for stop not recorded
  # NOTE: search/contraband not in database, only in written reports
  # NOTE: subject race is not recorded
  d$data %>%
    rename(
      incident_location = Location,
      officer_id = Unit
    ) %>%
    mutate(
      # NOTE: T = "Traffic Stop", SS = "Subject Stop"
      incident_type = ifelse(Type == "T", "vehicular", "pedestrian"),
      incident_date = parse_date(Date, "%Y/%m/%d"),
      incident_time = parse_time(Time, "%H:%M:%S"),
      warning_issued = str_detect(Disposition, "Warning"),
      citation_issued = str_detect(Disposition, "Citation"),
      arrest_made = str_detect(Disposition, "Arrest"),
      # TODO(ravi): do we want to filter out outcomes we don't care about?
      # https://app.asana.com/0/456927885748233/590576541432184
      incident_outcome = first_of(
        arrest = arrest_made,
        citation = citation_issued,
        warning = warning_issued
      )
    ) %>%
    helpers$add_lat_lng(
    ) %>%
    standardize(d$metadata)
}
