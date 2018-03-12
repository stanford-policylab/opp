source("common.R")

load_raw <- function(raw_data_dir, n_max) {
  fname <- "pdr100317tpdstops_sheet_1.csv"
  read_csv(
    file.path(raw_data_dir, fname),
    n_max = n_max
  ) %>%
  bundle_raw(
    list(fname <- problems(tbl))
  )
}


clean <- function(d, calculated_features_path) {

  # TODO(phoebe): can we get reason_for_stop/search/contraband information?
  # https://app.asana.com/0/456927885748233/590576541432180
  # TODO(phoebe): can we get race information?
  # https://app.asana.com/0/456927885748233/590576541432181
  d$data %>%
    rename(
      incident_location = Location
    ) %>%
    mutate(
      # TODO(phoebe): what does "SS" stop type mean?
      #
      incident_type = ifelse(Type == "T", "vehicular", "pedestrian"),
      incident_date = parse_date(Date, "%Y/%m/%d"),
      incident_time = parse_time(Time, "%H:%M:%S"),
      # TODO(phoebe): what is "Unit"? Police Unit?
      # https://app.asana.com/0/456927885748233/590576541432182
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
    # TODO(danj): add lat/lng data
    # add_lat_lng(
    #   "incident_location",
    #   calculated_features_path
    # ) %>%
    standardize(d$metadata)
}
