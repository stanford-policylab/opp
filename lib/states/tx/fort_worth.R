source("common.R")

load_raw <- function(raw_data_dir, n_max) {

  data <- tibble()
  loading_problems <- list()
  for (yr in 2006:2016) {
    fname <- str_c(yr, ".csv")
    tbl <- read_csv(file.path(raw_data_dir, fname), n_max = n_max)
    loading_problems[[fname]] <- problems(tbl)
    data <- bind_rows(data, tbl)
    if (nrow(data) > n_max) {
      data <- data[1:n_max, ]
      break
    }
  }

  arrest_codes_fname <- "02022018_fortworth_charge_codes.csv"
  arrest_codes <- read_csv_with_types(
    file.path(raw_data_dir, arrest_codes_fname),
    c(
      arrest_code_description = "c",
      arrest_code = "c"
    )
  )
  loading_problems[[arrest_codes_fname]] <- problems(arrest_codes)
  
  left_join(
            data,
            arrest_codes,
    by = c("OffenseCharged" = "arrest_code")
  ) %>%
  bundle_raw(loading_problems)
}


# TODO(journalist): why do the numbers here decrease yoy?
# https://app.asana.com/0/456927885748233/519045240013551
clean <- function(d, calculated_features_path) {

  tr_race <- c(
    "Asian" = "asian/pacific islander",
    "Black" = "black",
    "Hispanic" = "hispanic",
    "Middle Eastern" = "other/unknown",
    "Native American/Eskimo" = "other/unknown",
    "Other" = "other/unknown",
    "Unknown" = "other/unknown",
    "White" = "white"
  )
  tr_search_conducted = c(
    Yes = TRUE,
    No = FALSE,
    Unknown = NA
  )
  tr_sex = c(
    "Female" = "female",
    "Male" = "male"
  )

  d$data %>%
    rename(
      incident_date = Stop_Date,
      incident_location = Address,
      contraband_found = Contraband_Found,
      arrest_made = Arrest,
      citation_issued = Citation,
      warning_issued = Verbal_Warning,  # no written_warning or other type
      subject_sex = Sex,
      reason_for_stop = Reason,
      reason_for_arrest = ArrestBasedOn
    ) %>%
    mutate_each(
      funs(as.logical),
      contraband_found,
      arrest_made,
      citation_issued,
      warning_issued
    ) %>%
    mutate(
      # NOTE: we don't have most of these, and it's dicey to reverse engineer
      # from arrest_code_description
      incident_type = ifelse(
        matches(reason_for_stop, "Traffic Violation"),
        "vehicular",
        "pedestrian"
      ),
      incident_time = format(as.POSIXct(incident_date), "%H:%M:%S"),
      incident_outcome = first_of(
        arrest = arrest_made,
        citation = citation_issued,
        warning = warning_issued
      ),
      # NOTE: Hispanic ethnicity > race subdivision
      subject_race =
        tr_race[ifelse(Ethnicity == "Hispanic", "Hispanic", Race)],
      subject_sex = tr_sex[subject_sex],
      search_conducted = tr_search_conducted[Search_Conducted],
      reason_for_search =
        str_combine_cols(Search_reason, Facts_Supporting_Search)
    ) %>%
    add_lat_lng(
      "incident_location",
      calculated_features_path
    ) %>%
    add_contraband_types(
      "Contraband_Type",
      calculated_features_path
    ) %>%
    add_search_types(
      "reason_for_search",
      calculated_features_path
    ) %>%
    standardize(d$metadata)
}
