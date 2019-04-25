source("common.R")

load_raw <- function(raw_data_dir, n_max) {
  d <- load_years(raw_data_dir, n_max)
  bundle_raw(d$data, d$loading_problems)
}


clean <- function(d, helpers) {
  # TODO(phoebe): can we get reason_for_stop/search/contraband fields?
  # https://app.asana.com/0/456927885748233/1117283630988001

  tr_race <- c(
    tr_race,
    M = "other",
    P = "other",
    E = "other"
  )

  # NOTE: sometimes the same stop has different speeds recorded; often a pair
  # of legitimate values, i.e. goign 55 in a 40, but the others will have 0 and
  # 0 or NA and NA, since possibly multiple tickets are issued for the same
  # stop; for each record, we take the max of each to represent the speeds
  speed_tbl <-
    d$data %>%
    group_by(
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
    summarize(
      max_speed = max(as.integer(alleged_speed), na.rm = T),
      max_posted_speed = max(as.integer(posted_speed), na.rm = T)
    )

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
  left_join(
    speed_tbl
  ) %>%
  rename(
    date = incident_date,
    time = incident_time,
    # TODO(phoebe): incident_address is 100% null, can we get locations?
    # https://app.asana.com/0/456927885748233/1117283630988002 
    location = incident_address,
    violation = offense_title,
    disposition = final_disposition,
    officer_id = officer_badge,
    vehicle_make = make,
    vehicle_registration_state = vehicle_state,
    raw_alleged_speed = alleged_speed,
    raw_posted_speed = posted_speed,
    speed = max_speed,
    posted_speed = max_posted_speed
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
    subject_sex = tr_sex[sex],
    officer_sex = tr_sex[officer_sex],
    subject_race = tr_race[race],
    officer_race = tr_race[officer_race]
  ) %>%
  filter(
    # NOTE: while only the last 2 months of data are in 2012, all data prior
    # to this looks like a recording error as it is extremely sparse
    year(date) >= 2012
  ) %>%
  # helpers$add_lat_lng(
  # ) %>%
  rename(
    raw_race = race
  ) %>%
  standardize(d$metadata)
}
