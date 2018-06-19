source("common.R")

# NOTE: data sources:
# https://publicrec.hillsclerk.com/Traffic/Civil_Traffic_Name_Index_files/
# https://publicrec.hillsclerk.com/Traffic/Criminal_Traffic_Name_Index_files/
load_raw <- function(raw_data_dir, n_max) {
  d <- load_years(raw_data_dir, n_max)
  bundle_raw(d$data, d$loading_problems)
}


clean <- function(d, helpers) {

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

  # TODO(phoebe): can we get search/contraband information?
  # https://app.asana.com/0/456927885748233/583463577237760
  # TODO(phoebe): can we get other outcome data (warning, arrest)?
  # https://app.asana.com/0/456927885748233/583463577237761 
  d$data %>%
    rename(
      violation = `Statute Description`,
      vehicle_registration_state = `Tag State`
    ) %>%
    filter(
      `Law Enf Agency Name` == "Tampa Police Department"
    ) %>%
    separate_cols(
      `Law Enf Officer Name` = c("officer_last_name", "officer_first_name"),
      sep = " |, "
    ) %>%
    mutate(
      # TODO(phoebe): What is the difference between Criminal and Civil traffic
      # stops? More specifically, what are Statute Number prefixes 893 and
      # 999, everything else looks like traffic
      # https://app.asana.com/0/456927885748233/583463577237763
      type = "vehicular",
      date = parse_date(`Offense Date`, "%m/%d/%Y"),
      # TODO(phoebe): is address the person or offense location? Also, what is
      # address Line 2
      # https://app.asana.com/0/456927885748233/583463577237766
      # TODO(danj): add lat/lng if preceding task is offense location
      # https://app.asana.com/0/456927885748233/583463577237768
      location = str_c_na(
        `Address Line 1`,
        City,
        State,
        `Zip Code`,
        sep = ", "
      ),
      # NOTE: one of the primary keys is Citation Number, so presumably
      # they are all citations
      citation_issued = TRUE,
      outcome = "citation",
      subject_race = tr_race[Race],
      subject_sex = tr_sex[Gender],
      subject_dob = parse_date(`Date Of Birth`, "%m/%d/%Y")
    ) %>%
    standardize(d$metadata)
}
