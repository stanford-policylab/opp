source("common.R")

load_raw <- function(raw_data_dir, n_max) {
  data <- tibble()
  loading_problems <- list()
  for (year in 2008:2017) {
    fname <- str_c(year, ".csv")
    tbl <- read_csv(file.path(raw_data_dir, fname))
    loading_problems[[fname]] <- problems(tbl)
    data <- bind_rows(data, tbl)
    if (nrow(data) > n_max) {
      data <- data[1:n_max,]
    }
  }
  dd_fname <- "data_dictionary.csv"
  dd <- read_csv(file.path(raw_data_dir, dd_fname))
  loading_problems[[dd_fname]] <- problems(dd)

  left_join(data, dd, by = c("Violation 1" = "CODE")) %>%
    rename(violation_1_description = TRANSLATION) %>%
  left_join(dd, by = c("Violation 2" = "CODE")) %>%
    rename(violation_2_description = TRANSLATION) %>%
  left_join(dd, by = c("Violation 3" = "CODE")) %>%
    rename(violation_3_description = TRANSLATION) %>%
  left_join(dd, by = c("Violation 4" = "CODE")) %>%
    rename(violation_4_description = TRANSLATION) %>%
  bundle_raw(loading_problems)
}


clean <- function(d, helpers) {
  tr_race <- c(
    "Amer Indian" = "other/unknown",
    "Asian" = "asian/pacific islander",
    "Asian Indian" = "asian/pacific islander",
    "Black" = "black",
    "Cambodian" = "asian/pacific islander",
    "Chinese" = "asian/pacific islander",
    "Filipino" = "asian/pacific islander",
    "Guamanian" = "asian/pacific islander",
    "Hawiian" = "other/unknown",
    "Japanese" = "asian/pacific islander",
    "Korean" = "asian/pacific islander",
    "Laotian" = "asian/pacific islander",
    "Mex/Lat/Hisp" = "hispanic",
    "Other" = "other/unknown",
    "Pacific Isl" = "asian/pacific islander",
    "Samoan" = "asian/pacific islander",
    "Unknown" = "other/unknown",
    "Vietnamese" = "other/unknown",
    "White" = "white"
  )
  tr_sex <- c(
    "Female" = "female",
    "Male" = "male"
  )

  # TODO(phoebe): can we get reason_for_stop/search/contraband fields?
  # for reason_for_stop, maybe we need the data dictionary for Violation codes?
  # https://app.asana.com/0/456927885748233/596075286170964
  d$data %>%
    helpers$add_incident_type(
      "violation_1_description"
    ) %>%
    filter(
      Sex != "Business",
      incident_type != "other"
    ) %>%
    rename(
      incident_location = Location,
      subject_age = Age,
      # NOTE: this is vehicle year, confirmed with department
      vehicle_year = Year,
      officer_id = `Officer DID`
    ) %>%
    mutate(
      incident_date = parse_date(Date, "%m/%d/%Y"),
      # TODO(phoebe): can we get outcomes (warnings, arrests)?
      # https://app.asana.com/0/456927885748233/596075286170967
      citation_issued = TRUE,
      incident_outcome = "citation",
      subject_race = tr_race[Race],
      subject_sex = tr_sex[Sex]
    ) %>%
    helpers$add_lat_lng(
    ) %>%
    standardize(d$metadata)
}
