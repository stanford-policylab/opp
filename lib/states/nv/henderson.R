source("common.R")

# TODO(phoebe): the file 'Traffic Stops 01-01-11 to 05-30-18.xlsx'
# is corrupted, what does this contain and can they resend?
# https://app.asana.com/0/456927885748233/1117283630988015
load_raw <- function(raw_data_dir, n_max) {
  d <- load_years(raw_data_dir, n_max)
  d$data <- make_ergonomic_colnames(d$data) %>%
    mutate(race = coalesce(ra, rac)) %>%
    select(-ra, -rac)
  bundle_raw(d$data, d$loading_problems)
}


clean <- function(d, helpers) {

  # TODO(phoebe): can we get reason_for_stop/search/contraband fields?
  # https://app.asana.com/0/456927885748233/1117283630988016
  # TODO(pheobe): why does there appear to be a gap in 2012 for July, August,
  # and September?
  # https://app.asana.com/0/456927885748233/1117283630988017
  d$data %>%
    merge_rows(
      location,
      city,
      state,
      zip,
      off_dt,
      off_ti,
      dob,
      lname,
      ht,
      sex,
      wt,
      eye,
      hair,
      make,
      ofcr_id
    ) %>%
    rename(
      time = off_ti,
      vehicle_make = make,
      vehicle_registration_state = plate_state,
      vehicle_type = style,
      vehicle_color = color,
      officer_id = ofcr_id,
      subject_last_name = lname
    ) %>%
    mutate(
      # TODO(phoebe); are these all vehicular stops?
      # https://app.asana.com/0/456927885748233/1117283630988018
      type = "vehicular",
      # NOTE: the primary key appears to be `cite` for citation
      citation_issued = T,
      # TODO(phoebe): can we get other outcomes, i.e. warnings/arrests?
      # 
      outcome = first_of(
        citation = citation_issued
      ),
      date = parse_date(off_dt, "%Y/%m/%d"),
      city = if_else(is.na(city), "HENDERSON", city),
      state = if_else(is.na(state), "NV", state),
      location = str_c_na(location, city, state, zip),
      subject_dob = parse_date(dob, "%m/%d/%Y"),
      subject_race = tr_race[race],
      subject_sex = tr_sex[sex],
      violation = str_c_na(offense_1, offense_2, sep = "|")
    ) %>%
    # NOTE: 2010 data is extremely sparse and appears to be recording errors
    filter(year(date) > 2010) %>%
    rename(
      raw_race = race
    ) %>%
    helpers$add_lat_lng(
    ) %>%
    standardize(d$metadata)
}
