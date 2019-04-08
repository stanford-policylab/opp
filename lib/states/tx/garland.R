source("common.R")

load_raw <- function(raw_data_dir, n_max) {
  d <- load_years(raw_data_dir, n_max)
  bundle_raw(d$data, d$loading_problems)
}


clean <- function(d, helpers) {

  tr_race <- c(
    tr_race,
    M = "other",
    P = "other",
    E = "other"
  )

  # TODO(phoebe): can we get reason_for_stop/search/contraband fields?
  # https://app.asana.com/0/456927885748233/1117283630988001
  d$data %>%
    merge_rows(
      sex,
      race,
      vehicle_year,
      vehicle_color,
      make,
      vehicle_state,
      incident_date,
      incident_time,
      officer_badge
    ) %>%
    rename(
      date = incident_date,
      time = incident_time,
      # TODO(phoebe): incident_address is 100% null, can we get locations?
      # https://app.asana.com/0/456927885748233/1117283630988002 
      location = incident_address,
      subject_sex = sex,
      officer_sex = officer_sex,
      raw_officer_race = officer_race,
      raw_subject_race = race,
      violation = offense_title,
      disposition = final_disposition,
      officer_id = officer_badge,
      vehicle_make = make,
      vehicle_registration_state = vehicle_state,
      speed = alleged_speed
    ) %>%
    separate_cols(
      officer_name = c("officer_last_name", "officer_first_name"),
      sep = ", "
    ) %>%
    mutate(
      # NOTE: the file has traffic stops in the title
      type = "vehicular",
      date = parse_date(date),
      time = parse_time_int(time),
      # NOTE: these are all tickets, so assuming they are citations
      # TODO(phoebe): can we get other outcomes (warnings/arrests)?
      # https://app.asana.com/0/456927885748233/1117283630988003 
      citation_issued = T,
      outcome = first_of(
        citation = citation_issued
      ),
      subject_sex = tr_sex[subject_sex],
      officer_sex = tr_sex[officer_sex],
      subject_race = tr_race[raw_subject_race],
      officer_race = tr_race[raw_officer_race]
    ) %>%
    filter(
      # NOTE: while only the last 2 months of data are in 2012, all data prior
      # to this looks like a recording error as it is extremely sparse
      year(date) >= 2012
    ) %>%
    # helpers$add_lat_lng(
    # ) %>%
    standardize(d$metadata)
}
