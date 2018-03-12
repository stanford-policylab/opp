source("common.R")

# NOTE: data sources:
# https://publicrec.hillsclerk.com/Traffic/Civil_Traffic_Name_Index_files/
# https://publicrec.hillsclerk.com/Traffic/Criminal_Traffic_Name_Index_files/
load_raw <- function(raw_data_dir, n_max) {
  data <- tibble()
  loading_problems <- list()
  fname_prefixes = c("Civil", "Criminal")
  for (year in 2003:2017) {
    for (prefix in fname_prefixes) {
      fname <- str_c(prefix, "_Traffic_Name_Index_", year, ".csv")
      tbl <- read_csv(file.path(raw_data_dir, fname),
                      col_types = cols(.default = "c"))
      loading_problems[[fname]] <- problems(tbl)
      data <- bind_rows(data, tbl)
      if (nrow(data) > n_max) {
        data <- data[1:n_max,]
        break
      }
    }
  }
  bundle_raw(data, loading_problems)
}


clean <- function(d, calculated_features_path) {

    tr_race <- c(
      "Asian" = "asian/pacific islander",
      "Black" = "black",
      "Hispanic" = "hispanic",
      "Indian" = "other/unknown",
      "Multiracial" = "other/unknown",
      "Native Hawaiian or Other Pacific Islander" = "asian/pacific islander",
      "Other" = "other/unknown",
      "Unavailable" = NA,
      "White" = "white"
    )
    tr_sex <- c(
      "Female" = "female",
      "Male" = "male"
    )

  # TODO(phoebe): can we get search/contraband information?
  # https://app.asana.com/0/456927885748233/583463577237760
  # TODO(phoebe): can we get other outcome data (warning, arrest)?
  # https://app.asana.com/0/456927885748233/583463577237761 
  d$data %>%
    rename(
      reason_for_stop = `Statute Description`,
      vehicle_registration_state = `Tag State`
    ) %>%
    filter(
      `Law Enf Agency Name` == "Tampa Police Department",
    ) %>%
    mutate(
      # TODO(phoebe): What is the difference between Criminal and Civil traffic
      # stops? More specifically, what are Statute Number prefixes 893 and
      # 999, everything else looks like traffic
      # https://app.asana.com/0/456927885748233/583463577237763
      incident_type = "vehicular",
      incident_date = parse_date(`Offense Date`, "%m/%d/%Y"),
      # TODO(phoebe): is address the person or offense location? Also, what is
      # address Line 2
      # https://app.asana.com/0/456927885748233/583463577237766
      # TODO(danj): add lat/lng if preceding task is offense location
      # https://app.asana.com/0/456927885748233/583463577237768
      incident_location = str_c_na(
        `Address Line 1`,
        City,
        State,
        `Zip Code`,
        sep = ", "
      ),
      # NOTE: one of the primary keys is Citation Number, so presumably
      # they are all citations
      citation_issued = TRUE,
      incident_outcome = "citation",
      subject_race = tr_race[Race],
      subject_sex = tr_sex[Gender],
      subject_dob = parse_date(`Date Of Birth`, "%m/%d/%Y")
    ) %>%
    standardize(d$metadata)
}
