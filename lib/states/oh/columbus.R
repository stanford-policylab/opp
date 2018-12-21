source("common.R")


# VALIDATION: [YELLOW] It appears as though the Annual Reports only include
# Violent and Property crime statistics (in addition to complaints). That said,
# the number of stops and consistency year over year appear reasonable. See
# TODOs for outstanding tasks.
load_raw <- function(raw_data_dir, n_max) {
  d <- load_single_file(raw_data_dir, "columbus_oh_data.csv")
  bundle_raw(d$data, d$loading_problems)
}


clean <- function(d, helpers) {

  d$data %>%
    mutate(
      # NOTE: stop location is null about 2/3 of the time,
      # so using violation location
      location = str_trim(
        str_c(
          ViolationStreet,
          ViolationCrossStreet,
          sep = " and "
        )
      )
    ) %>%
    helpers$add_lat_lng(
    ) %>%
    # TODO(phoebe): what is cruiser district?
    # https://app.asana.com/0/456927885748233/569484839430730<Paste>
    helpers$add_shapefiles_data(
    ) %>%
    rename(
      reason_for_stop = `Stop Reason`,
      zone = POL_ZONE,
      precinct = POL_PRECNT
    ) %>%
    separate_cols(
      `Stop Date` = c("date", "time")
    ) %>%
    mutate(
      # NOTE: all stop reasons are vehicle related
      type = "vehicular",
      date = parse_date(date, "%Y/%m/%d"),
      subject_race = tr_race[tolower(Ethnicity)],
      subject_sex = tr_sex[Gender],
      search_conducted = `Enforcement Taken` %in%
        c("Vehicle Search", "Driver Search"),
      arrest_made = `Enforcement Taken` == "Arrest",
      citation_issued = `Enforcement Taken` %in%
        c("Traffic Citation", "Misd. Citation or Summons"),
      warning_issued = `Enforcement Taken` == "Verbal Warning",
      outcome = first_of(
        arrest = arrest_made,
        citation = citation_issued,
        warning = warning_issued
      )
    ) %>%
    standardize(d$metadata)
}
