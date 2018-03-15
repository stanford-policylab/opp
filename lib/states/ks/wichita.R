source("common.R")

load_raw <- function(raw_data_dir, n_max) {
  data <- tibble()
  loading_problems <- list()
  for (year in 2006:2016) {
    fname <- str_c("citations_", year, "_sheet_1.csv")
    tbl <- read_csv(
      file.path(raw_data_dir, fname),
      col_types = cols(.default = "c")
    )
    loading_problems[[fname]] <- problems(tbl)
    data <- bind_rows(data, tbl)
    if (nrow(data) > n_max) {
      data <- data[1:n_max,]
      break
    }
  }
  bundle_raw(data, loading_problems)
}


clean <- function(d, calculated_features_path) {
  tr_race <- c(
    "A" = "asian/pacific islander",
    "B" = "black",
    "I" = "other/unknown",
    "U" = "other/unknown",
    "W" = "white"
  )

  # TODO(phoebe): can we get reason_for_stop/search/contraband fields?
  # https://app.asana.com/0/456927885748233/595493946182532
  colnames(d$data) <- tolower(colnames(d$data))
  d$data %>%
    filter(
      # NOTE: filter out PARKING related charges
      !str_detect(charge_description, "PARKING")
    ),
    rename(
      subject_age = defendant_age,
      # TODO(ravi): is this acceptable? should we filter out anything else?
      # https://app.asana.com/0/456927885748233/595493946182533
      reason_for_stop = charge_description
    ) %>%
    mutate(
      # NOTE: all charge descriptions appear to be vehicle related
      incident_type = "vehicular",
      incident_datetime = coalesce(
        parse_datetime(citation_date_time, "%Y/%m/%d %H:%M:%S"),
        parse_date(citation_date_time, "%Y/%m/%d")
      ),
      incident_date = as.Date(incident_datetime),
      incident_time = format(incident_datetime, "%H:%M:%S"),
      citation_issued = TRUE,
      # TODO(phoebe): can we get other outcomes (warnings, arrests)?
      # https://app.asana.com/0/456927885748233/595493946182534
      incident_location = str_c_na(
        citation_location,
        citation_city,
        citation_state,
        citation_zip,
        sep = ", "
      ),
      incident_outcome = "citation",
      subject_race = tr_race[
        ifelse(defendant_ethnicity == "H", "H", defendant_race)
      ],
      subject_sex = tr_sex[defendant_race]
    ) %>%
    add_lat_lng(
      "incident_location",
      calculated_features_path
    ) %>%
    standardize(d$metadata)
}
