source("common.R")

load_raw <- function(raw_data_dir, n_max) {
  d <- load_regex(raw_data_dir, "Traffic", n_max)
  colnames(d$data) <- make_ergonomic(colnames(d$data))
  bundle_raw(d$data, d$loading_problems)
}


clean <- function(d, helpers) {

  tr_sex <- c(tr_sex, "M - MALE" = "male")
  tr_race <- c(
    "BLACK" = "black",
    "WHITE" = "white",
    "UNKNOWN" = "other/unknown",
    "ASIAN/PACIFIC ISLANDER" = "asian/pacific islander",
    "ASIAN OR PACIFIC ISLANDER" = "asian/pacific islander",
    "HISPANIC" = "hispanic",
    "AMERICAN INDIAN/ALASKAN NATIVE" = "other/unknown",
    "AMERICAN IINDIAN/ALASKAN NATIVE" = "other/unknown",
    "F" = "other/unknown"
  )

  # TODO(phoebe): can we get search/contraband fields?
  # https://app.asana.com/0/456927885748233/757611127540100
  d$data %>%
    rename(
      location = address_x,
      disposition = disposition_text,
      reason_for_stop = incident_type_desc,
    ) %>%
    mutate(
      tmp_location = location
    ) %>%
    # NOTE: addresses are "sanitized", i.e. 1823 Field St. -> 18XX Field St.
    # since 83% of given geocodes are null, we replace X with 0 and get
    # approximate geocoding locations
    separate_cols(
      tmp_location = c("number", "street")
    ) %>%
    mutate(
      geocoded_location = str_c_na(
        str_replace_all(number, "X", "0"),
        street,
        sep = " "
      )
    ) %>%
    helpers$add_lat_lng(
      "geocoded_location"
    ) %>%
    filter(
      !is.na(date),
      # NOTE: filtering out passengers, since we are concerned about drivers
      !str_detect(field_subject_cid, "PASS")
    ) %>%
    mutate(
      datetime = parse_datetime(interview_date, "%m/%d/%Y %H:%M:%S %p %Z"),
      date = as.Date(datetime),
      time = format(datetime, "%H:%M:%S"),
      type = if_else(
        str_detect(field_subject_cid, "DRIV"),
        "vehicular",
        "pedestrian"
      ),
      lat = coalesce(as.numeric(latitude_x), lat),
      lng = coalesce(as.numeric(longitude_x), lng),
      subject_sex = tr_sex[sex],
      subject_race = tr_race[race],
      arrest_made = str_detect(actiontakencid, "ARREST"),
      citation_issued = str_detect(actiontakencid, "CITATION"),
      warning_issued = actiontakencid == "WARNING",
      outcome = first_of(
        arrest = arrest_made,
        citation = citation_issued,
        warning = warning_issued
      ),
      vehicle_registration_state =
        tr_state_to_abbreviation[tolower(license_plate_state)]
    ) %>%
    filter(
      # NOTE: looks like there are only random stops recorded prior to 2009
      year(date) > 2008,
    ) %>%
    merge_rows(
      instance_id
    ) %>%
    standardize(d$metadata)
}
