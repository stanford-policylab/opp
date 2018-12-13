source("common.R")

# VALIDATION: [YELLOW] While the data seems reasonable -- there were ~51k
# traffic stop calls in 2017 according to the "2017 Annual Report Little Rock
# Police Department" and we have ~20k citations through November
# 2017 -- we appear to only have data on those stops that resulted in
# citations, which means we don't have stops that didn't result in an action
# taken and we don't have the other actions taken, namely warnings and arrests
load_raw <- function(raw_data_dir, n_max) {
  # TODO(phoebe): what is this file? it has similar fields but far fewer records
  # ytd_traffic_stops_from_rms_data_export_tool.csv  
  # https://app.asana.com/0/456927885748233/592025853254518
  d <- load_single_file(
    raw_data_dir,
    # NOTE: this only includes stops through the beginning of November
    "traffic_citation_stats_-_year-to-date_2017.csv",
    n_max
  )
  bundle_raw(d$data, d$metadata)
}


clean <- function(d, helpers) {
  tr_race <- c(
    "AFRICAN AMERICAN" = "black",
    "AMERICAN INDIAN" = "other/unknown",
    "ASIAN" = "asian/pacific islander",
    "CAUCASIAN" = "white",
    "UNKNOWN" = "other/unknown"
  )
  tr_sex <- c(
    "Female" = "female",
    "Male" = "male"
  )

  # TODO(phoebe): can we get reason_for_stop/search/contraband fields?
  # https://app.asana.com/0/456927885748233/592025853254519
  d$data %>%
    rename(
      subject_age = `Defendant Age`,
      lat = Latitude,
      lng = Longitude,
      vehicle_type = `Vehicle Body Type`
    ) %>%
    separate_cols(
      `Reporting Officer` = c("officer_last_name", "officer_first_name"),
      sep = " - "
    ) %>%
    mutate(
      datetime = parse_datetime(DateTime, "%m/%d/%Y %I:%M:%S %p"),
      date = as.Date(datetime),
      time = format(datetime, "%H:%M:%S"),
      # NOTE: all of the stops have an associated `Vehicle Type`
      type = "vehicular",
      # TODO(phoebe): can we get all stops, even those that didn't result
      # in an action taken? pg.8 of the reports looks like they have this:
      # https://www.littlerock.gov/media/3937/lrpd-annual-report-final-draft.pdf
      # TODO(phoebe): can we get other outcomes (warnings/arrests)?
      # https://app.asana.com/0/456927885748233/592025853254520
      citation_issued = TRUE,
      outcome = "citation",
      subject_race = tr_race[`Defendant Race`],
      subject_sex = tr_sex[`Defendant Gender`]
    ) %>%
    # NOTE: filter out rows where DateTime is null
    filter(
      !is.na(date)
    ) %>%
    standardize(d$metadata)
}
