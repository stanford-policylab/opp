source("common.R")

# VALIDATION: [YELLOW] Long Beach's Police Department's FY 2018 report is
# mostly budgeting and high level aggregate figures, but it does say there were
# 567k calls responded to in 2016, and we have 15k tickets issued, which seams
# reasonable; it appears as though this data is ticket/citation related, so we
# don't have other types of outcomes; see TODOs for outstanding issues
# TODO(phoebe): why are the stops going down so fast yoy from 2009 to 2016?
# https://app.asana.com/0/456927885748233/944841731070585
load_raw <- function(raw_data_dir, n_max) {
  d <- load_years(raw_data_dir, n_max)
  data <- d$data
  loading_problems <- d$loading_problems
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
    # NOTE: type classification is based on first [assumed primary] violation
    helpers$add_type(
      "violation_1_description"
    ) %>%
    filter(
      Sex != "Business",
      type != "other"
    ) %>%
    rename(
      location = Location,
      subject_age = Age,
      vehicle_make = Make,
      vehicle_registration_state = State,
      # NOTE: this is vehicle year, confirmed with department
      vehicle_year = Year,
      officer_age = `Officer Age`,
      officer_years_of_service = `Years of Service`,
      department_id = `Officer DID`
    ) %>%
    mutate(
      date = parse_date(Date, "%m/%d/%Y"),
      violation = str_c_na(
        violation_1_description,
        violation_2_description,
        violation_3_description,
        violation_4_description,
        sep = "; "
      ),
      # TODO(phoebe): can we get outcomes (warnings, arrests)?
      # https://app.asana.com/0/456927885748233/596075286170967
      citation_issued = TRUE,
      outcome = "citation",
      subject_race = tr_race[Race],
      subject_sex = tr_sex[Sex],
      officer_race = tr_race[`Officer Race`],
      officer_sex = tr_sex[`Officer Sex`]
    ) %>%
    helpers$add_lat_lng(
    ) %>%
    helpers$add_shapefiles_data(
    ) %>%
    rename(
      beat = PO_BEAT_NO,
      # NOTE: Police Reporting District Number
      # PO_DIST_NO is just the first 2 digits of this
      district = PO_RD_NO,
      subdistrict = PO_SUBDIST,
      division = PO_DIV
    ) %>%
    standardize(d$metadata)
}
