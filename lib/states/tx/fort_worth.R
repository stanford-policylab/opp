source("common.R")

load_raw <- function(raw_data_dir, n_max) {
  d <- load_regex(raw_data_dir, "^\\d{4}.csv", n_max = n_max)
  codes <- load_single_file(
    raw_data_dir,
    "02022018_fortworth_charge_codes.csv",
    n_max = n_max
  )
  colnames(codes$data) <- make_ergonomic(colnames(codes$data))
  left_join(
    d$data,
    codes$data,
    by = c("OffenseCharged" = "arrest_offense_charge_code")
  ) %>%
  bundle_raw(c(d$loading_problems, codes$loading_problems))
}


# TODO(journalist): why do the numbers here decrease yoy?
# https://app.asana.com/0/456927885748233/519045240013551
clean <- function(d, helpers) {

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
      location = Address,
      contraband_found = Contraband_Found,
      arrest_made = Arrest,
      citation_issued = Citation,
      warning_issued = Verbal_Warning,  # no written_warning or other type
      subject_sex = Sex,
      reason_for_stop = Reason,
      reason_for_arrest = ArrestBasedOn,
      violation = Violation_Offense
    ) %>%
    mutate_at(
      vars(
        contraband_found,
        arrest_made,
        citation_issued,
        warning_issued
      ),
      funs(as.logical)
    ) %>%
    mutate(
      # NOTE: we don't have most of these, and it's dicey to reverse engineer
      # from arrest_offense_charged_desc
      type = if_else(
        str_detect(reason_for_stop, "Traffic Violation"),
        "vehicular",
        "pedestrian"
      ),
      datetime = parse_datetime(Stop_Date),
      date = as.Date(datetime),
      time = format(datetime, "%H:%M:%S"),
      outcome = first_of(
        arrest = arrest_made,
        citation = citation_issued,
        warning = warning_issued
      ),
      # NOTE: Hispanic ethnicity > race subdivision
      subject_race =
        tr_race[ifelse(Ethnicity == "Hispanic", "Hispanic", Race)],
      subject_sex = tr_sex[subject_sex],
      search_conducted = tr_search_conducted[Search_Conducted],
      reason_for_search = str_c_na(
        Search_reason,
        Facts_Supporting_Search,
        sep = "; "
      )
    ) %>%
    helpers$add_lat_lng(
    ) %>%
    helpers$add_contraband_type(
      "Contraband_Type"
    ) %>%
    helpers$add_search_basis(
      "reason_for_search"
    ) %>%
    standardize(d$metadata)
}
