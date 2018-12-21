source("common.R")


# VALIDATION: [YELLOW] Neither the "Safer Neighborhoods through Precision
# Policing Initiative" nor the 2018 Prospectus seem to collect statistics on
# traffic stops, although the Prospectus has some figures on crime. That said,
# the counts seem reasonable for a city of its size, with the exception of a
# few days in 2015; see TODOs for outstanding tasks.

# TODO(phoebe): What happened on 2015-04-29, 2015-05-02, and 2015-05-23; there
# are massive spikes in stops
# https://app.asana.com/0/456927885748233/953848354811709 
load_raw <- function(raw_data_dir, n_max) {
  d <- load_single_file(raw_data_dir, "foil_w008944.csv", n_max)
  bundle_raw(d$data, d$loading_problems)
}


clean <- function(d, helpers) {

  tr_race <- c(tr_race,
    M = "other/unknown",
    "H:" = "hispanic",
    R = "other/unknown"
  )

  # TODO(phoebe): can we get reason_for_stop/search/contraband fields?
  # https://app.asana.com/0/456927885748233/758649899422594
  # TODO(phoebe) can we get outcomes (warning/citation/arrest)?
  # https://app.asana.com/0/456927885748233/758649899422595
  d$data %>%
    rename(
      violation = crime_code_A,
      vehicle_color = veh_color,
      vehicle_make = veh_make,
      vehicle_year = veh_year,
      vehicle_registration_state = veh_lic_st
    ) %>%
    mutate(
      # NOTE: all violations appear to be vehicle related
      type = "vehicular",
      # NOTE: cross streets are mashed together with &&, make this more readable
      location = str_replace(mapinfo_lo, "&&", " & "),
      date = parse_date(date),
      subject_dob = parse_date(dob),
      subject_age = age_at_date(subject_dob, date),
      subject_sex = tr_sex[sex],
      subject_race = tr_race[race],
    ) %>%
    helpers$add_lat_lng(
    ) %>%
    standardize(d$metadata)
}
