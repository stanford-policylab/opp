source("common.R")

load_raw <- function(raw_data_dir, n_max) {
  wy2011 <- load_regex(raw_data_dir, ".*2011.csv", n_max = n_max)
  wy2012_1 <- load_single_file(raw_data_dir, "jan-june2012.csv", n_max = n_max)
  # NOTE: Second 2012 file is missing `trci_id` column but is otherwise the same.
  wy2012_2 <- load_single_file(raw_data_dir, "jul-dec2012.csv", n_max = n_max)
  bind_rows(
    wy2011$data,
    wy2012_1$data,
    wy2012_2$data
  ) %>%
  select(
    # NOTE: There are lots of empty columns from the spreadsheet conversion
    # that we drop here.
    -starts_with("X")
  ) %>%
  # NOTE: Each row represents an individual event in a stop. The following
  # grouping will get us to the stop level. Combine the events (statutes
  # and charges) as a string list to summarize the stop.
  group_by(
    tc_date,
    tc_time,
    offcr_id,
    emdivision,
    streetnbr,
    street,
    city,
    age,
    race,
    sex
  ) %>%
  summarize(
    statute = str_c(statute, collapse = '|'),
    charge = str_c(charge, collapse = '|')
  ) %>%
  ungroup(
  ) %>%
  bundle_raw(c(
    wy2011$loading_problems,
    wy2012_1$loading_problems,
    wy2012_2$loading_problems
  ))
}


clean <- function(d, helpers) {

  # TODO(phoebe): can we get reason_for_stop/search/contraband fields?
  # https://app.asana.com/0/456927885748233/731173686918279
  d$data %>%
    rename(
      officer_id = offcr_id,
      violation = statute,
      subject_age = age
    ) %>%
    mutate(
      date = parse_date(tc_date, "%Y/%m/%d"),
      time = parse_time(tc_time, "%H%M"),
      # NOTE: `city` column actually holds county
      location = str_c_na(street, streetnbr, city),
      county_name = city,
      precinct = emdivision,
      subject_race = tr_race[race],
      subject_sex = tr_sex[sex],
      # NOTE: All stops in data are vehicle stops.
      type = "vehicular"
    ) %>%
    standardize(d$metadata)
}
