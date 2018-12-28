source("common.R")


# VALIDATION: [GREEN] There is only 2016 data and there are a lot of missing
# data dictionary mappings from features to descriptions, but the 2016 Annual
# Report's total number of traffic stops very closely matches this data. See
# TODOs for outstanding tasks

# TODO(phoebe): can we get more than just 2016?
# https://app.asana.com/0/456927885748233/661685466505378 
load_raw <- function(raw_data_dir, n_max) {
  subject <- load_single_file(
    raw_data_dir,
    "orr_53698_2016_subject_stops.csv",
    n_max = n_max / 2
  )
  traffic <- load_single_file(
    raw_data_dir,
    "orr_53698_2016_traffic_stops.csv",
    n_max = n_max / 2
  )
  subject$data["type"] = "pedestrian"
  traffic$data["type"] = "vehicular"
  bundle_raw(
    bind_rows(subject$data, traffic$data),
    c(subject$loading_problems, traffic$loading_problems)
  )
}


clean <- function(d, helpers) {

  tr_race <- c(
    "W" = "white",
    "B" = "black",
    "H" = "hispanic",
    "A" = "asian/pacific islander",
    "O" = "other/unknown",
    "D" = "other/unknown",
    "C" = "other/unknown",
    "X" = "other/unknown",
    "I" = "other/unknown",
    "K" = "other/unknown",
    "L" = "other/unknown",
    "E" = "other/unknown",
    "P" = "other/unknown",
    "F" = "other/unknown"
  )

  # TODO(phoebe): what are PRA, xCoordinate, yCoordinate?
  # https://app.asana.com/0/456927885748233/653410849000224
  d$data %>%
    rename(
      officer_id = `PrimaryID (Officer ID)`,
      district = District,
      beat = Beat
    ) %>%
    mutate(
      subject_race = tr_race[`1st digit (Race)`],
      subject_sex = tr_sex[`2nd digit (Gender)`],
      # TODO(phoebe): can we get a data dictionary for this? X, N, I?
      # https://app.asana.com/0/456927885748233/653410849000225
      reason_for_stop = `3rd digit (Reason for Stop)`,
      # TODO(phoebe): can we get a data dictionary for this? R, C, K, L?
      # https://app.asana.com/0/456927885748233/653410849000225
      outcome = `4th digit (Final Outcome)`,
      # TODO(phoebe): can we get a data dictionary for `6th digit (Search
      # Outcome)`?
      # https://app.asana.com/0/456927885748233/653410849000225
      search_conducted = !is.na(`6th digit (Search Outcome)`),
      date = parse_date(InitiateDate),
      time = parse_time(InitiateTime),
      location = coalesce(Address1, Address2)
    ) %>%
    helpers$add_lat_lng(
    ) %>%
    standardize(d$metadata)
}
