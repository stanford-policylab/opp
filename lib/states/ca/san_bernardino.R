source("common.R")

load_raw <- function(raw_data_dir, n_max) {
  d <- load_single_file(raw_data_dir, "stop_data.csv", n_max)
  bundle_raw(d$data, d$loading_problems)
}


clean <- function(d, helpers) {
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
      location = Address,
      disposition = Disposition
    ) %>%
    mutate(
      datetime = parse_datetime(CreateDatetime, "%Y/%m/%d %H:%M:%S"),
      date = as.Date(datetime),
      time = format(datetime, "%H:%M:%S"),
      # TODO(phoebe): CallType T = Traffic? CKS = ?
      # https://app.asana.com/0/456927885748233/594103520238660
      type = ifelse(CallType == "T", "vehicular", "pedestrian"),
      citation_issued = ifelse(disposition == "CIT", TRUE, FALSE),
      arrest_made = ifelse(disposition == "ARR", TRUE, FALSE),
      outcome = first_of(
        citation = citation_issued,
        arrest = arrest_made
      )
    ) %>%
    helpers$add_lat_lng(
    ) %>%
    standardize(d$metadata)
}
