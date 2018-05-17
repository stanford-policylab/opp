source("common.R")

load_raw <- function(raw_data_dir, n_max) {
  data <- tibble()
  loading_problems <- list()
  for (year in 2014:2018) {
    fname <- str_c(year, ".csv")
    tbl <- read_csv(file.path(raw_data_dir, fname))
		data <- bind_rows(data, tbl)
		loading_problems[[fname]] <- problems(tbl)
    if (nrow(data) > n_max) {
      data <- data[1:n_max, ]
      break
    }
  }
  bundle_raw(data, loading_problems)
}


clean <- function(d, helpers) {

  tr_race <- c(
    "White" = "white",
    "Black" = "black",
    "Unknown" = "other/unknown",
    "Asian" = "asian/pacific islander",
    "American Indian" = "other/unknown",
    "Pacific Islander" = "asian/pacific islander"
  )

  # TODO(phoebe): can we get search/contraband fields?
  # https://app.asana.com/0/456927885748233/663043550621572
  d$data %>%
    rename(
      vehicle_color = `V Color`,
      vehicle_make = `V Make`,
      vehicle_model = `V Model`,
      reason_for_stop = `Violation Description`
    ) %>%
    mutate(
      # TODO(phoebe): can we confirm these are all vehicle related incidents?
      # https://app.asana.com/0/456927885748233/663043550621573
      incident_type = "vehicular",
      incident_date = parse_date(`Offense Date`),
      incident_location = coalesce(
        str_c(Block, Street, sep = " "),
        str_c(Street, "AND", `Scnd Street`, sep = " "),
        Street
      ),
      subject_race = tr_race[Race],
      subject_sex = tr_sex[Gender],
      citation_issued = !is.na(`Citataion Num`),
      # TODO(phoebe): can we get other outcomes? arrests/warnings?
      # https://app.asana.com/0/456927885748233/663043550621574
      incident_outcome = first_of(
        "citation" = citation_issued
      )
    ) %>%
    helpers$add_lat_lng(
    ) %>%
    standardize(d$metadata)
}
