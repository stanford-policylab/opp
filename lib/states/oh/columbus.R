source("common.R")

load_raw <- function(raw_data_dir, n_max) {
  loading_problems <- list()
  fname <- "columbus_oh_data.csv"
  data <- read_csv(file.path(raw_data_dir, fname), n_max = n_max)
  loading_problems[[fname]] <- problems(data)
  bundle_raw(data, loading_problems)
}


clean <- function(d, helpers) {
  tr_race = c(
    Asian = "asian/pacific islander",
    Black = "black",
    Hispanic = "hispanic",
    Other = "other/unknown",
    White = "white"
  )
  tr_sex = c(
    MALE = "male",
    FEMALE = "female"
  )

  d$data %>%
    mutate(
      # NOTE: stop location is null about 2/3 of the time,
      # so using violation location
      incident_location = str_trim(
        str_c(
          ViolationStreet,
          ViolationCrossStreet,
          sep = " and "
        )
      )
    ) %>%
    helpers$add_lat_lng(
      "incident_location"
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
      `Stop Date` = c("incident_date", "incident_time")
    ) %>%
    mutate(
      # NOTE: all stop reasons are vehicle related
      incident_type = "vehicular",
      incident_date = parse_date(incident_date, "%Y/%m/%d"),
      subject_race = tr_race[Ethnicity],
      subject_sex = tr_sex[Gender],
      search_conducted = `Enforcement Taken` %in%
        c("Vehicle Search", "Driver Search"),
      search_type = ifelse(search_conducted, "probable cause", NA), 
      arrest_made = `Enforcement Taken` == "Arrest",
      citation_issued = `Enforcement Taken` %in%
        c("Traffic Citation", "Misd. Citation or Summons"),
      warning_issued = `Enforcement Taken` == "Verbal Warning",
      incident_outcome = first_of(
        arrest = arrest_made,
        citation = citation_issued,
        warning = warning_issued
      )
    ) %>%
    standardize(d$metadata)
}
