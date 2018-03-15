source("common.R")

load_raw <- function(raw_data_dir, n_max) {
  loading_problems <- list()
  r <- function(fname) {
    tbl <- read_csv(
      file.path(raw_data_dir, fname),
      col_types = cols(.default = "c")
    )
    loading_problems[[fname]] <<- problems(tbl)
    tbl
  }
  citations <- r("mpd_traffic_stop_request_citations.csv")
  warnings <- r("mpd_traffic_stop_request_warnings.csv")
  data <- bind_rows(citations, warnings)
  if (nrow(data) > n_max) {
    data <- data[1:n_max,]
  }
  bundle_raw(data, loading_problems)
}


clean <- function(d, calculated_features_path) {
  tr_race <- c(
    "A" = "asian/pacific islander",
    "B" = "black",
    "H" = "hispanic",
    "I" = "other/unknown",
    "W" = "white"
  )

  # TODO(phoebe): can we get reason_for_stop/search/contraband data?
  #  https://app.asana.com/0/456927885748233/595493946182539
  d$data %>%
    rename(
      # TODO(ravi): is this misleading?
      # https://app.asana.com/0/456927885748233/595493946182540
      reason_for_stop = `Statute Description`,
      vehicle_make = Make,
      vehicle_model = Model,
      vehicle_year = Year,
      vehicle_color = Color,
      # TODO(phoebe): is state vehicle registration state?
      # https://app.asana.com/0/456927885748233/595493946182541
      vehicle_registration_state = State
    ) %>%
    mutate(
      # NOTE: Statute Descriptions all appear to be vehicle related
      incident_type = "vehicular",
      incident_date = parse_date(Date, "%Y/%m/%d"),
      incident_time = parse_time(Time, "%H:%M:%S"),
      # TODO(phoebe): what is IBM?
      # https://app.asana.com/0/456927885748233/595493946182542
      incident_location = coalesce(onStreet, onStreetName),
      warning_issued = is.na(`Ticket #`),
      citation_issued = !is.na(`Ticket #`),
      # TODO(phoebe): can we get arrests?
      # https://app.asana.com/0/456927885748233/595493946182543
      incident_outcome = first_of(
        citation = citation_issued,
        warning = warning_issued
      ),
      subject_race = tr_race[Race],
      subject_sex = tr_sex[Sex]
    ) %>%
    add_lat_lng(
      "incident_location",
      calculated_features_path
    ) %>%
    standardize(d$metadata)
}
