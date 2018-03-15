source("common.R")

load_raw <- function(raw_data_dir, n_max) {
  fname <- "stop_data.csv"
  data <- read_csv(file.path(raw_data_dir, fname), n_max = n_max)
  loading_problems <- list()
  loading_problems[[fname]] <- problems(data)
  bundle_raw(data, loading_problems)
}


clean <- function(d, calculated_features_path) {
  # TODO(phoebe): can we get reason_for_stop/search/contraband fields?
  # https://app.asana.com/0/456927885748233/594103520238657
  # TODO(phoebe): can we get race information?
  # https://app.asana.com/0/456927885748233/594103520238658 
  # TODO(phoebe): can we get outcomes (warning, citation, arrest)?
  # Perhaps this is in the Disposition column, in which case can we get a data
  # dictionary?
  # https://app.asana.com/0/456927885748233/594103520238659
  d$data %>%
    rename(
      incident_location = Address
    ) %>%
    mutate(
      incident_datetime = parse_datetime(CreateDatetime, "%Y/%m/%d %H:%M:%S"),
      incident_date = as.Date(incident_datetime),
      incident_time = format(incident_datetime, "%H:%M:%S"),
      # TODO(phoebe): CallType T = Traffic? CKS = ?
      # https://app.asana.com/0/456927885748233/594103520238660
      incident_type = ifelse(CallType == "T", "vehicular", "pedestrian"),
      citation_issued = ifelse(Disposition == "CIT", TRUE, FALSE),
      arrest_made = ifelse(Disposition == "ARR", TRUE, FALSE),
      incident_outcome = first_of(
        citation = citation_issued,
        arrest = arrest_made
      )
    ) %>%
    add_lat_lng(
      "incident_location",
      calculated_features_path
    ) %>%
    standardize(d$metadata)
}
