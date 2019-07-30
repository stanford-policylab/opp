source("common.R")

# VALIDATION: [YELLOW] According to the 2014 Annual Report, there were 130k
# traffic citations, 94.18% of which were vehicular, so roughly 122k.
# our data shows 65k citations in 2014, although we do have a small gap in
# reporting in 2014
# TODO(phoebe): Why are they showing nearly double the citations for 2014 in
# their report ~122k vs 65k?
# https://app.asana.com/0/456927885748233/945224207067251
# NOTE: we only have partial data for 2016
load_raw <- function(raw_data_dir, n_max) {
  # TODO(phoebe): what are the crossroads files, and are filenames significant?
  # https://app.asana.com/0/456927885748233/755505222650828
  col_names = c(
    "date",
    "time",
    "race",
    "sex",
    "age",
    "reason_for_stop",
    "search_vehicle",
    "result_of_contact",
    "location",
    "district"
  )
  d <- load_regex(
    raw_data_dir,
    "cau_\\d{4}|may_2014|citywide_2016",
    n_max,
    col_names = col_names,
    skip = 1
  )
  d_2015 <- load_regex(
    raw_data_dir,
    "citywide_2015",
    n_max,
    col_names = c(col_names, "blank"),
    skip = 1
  )
  d_2014_h2 <- load_single_file(
    raw_data_dir,
    # NOTE: this file is missing age
    "e585_cau_citywide_e585_june_-_december_2014.csv",
    n_max,
    col_names = col_names[!str_detect(col_names, "age")],
    skip = 1
  )
  # NOTE: maps are from key_to_e585_data.csv
  tr_race <- c(
    W = "white",
    H = "hispanic",
    A = "asian",
    B = "black",
    O = "other"
  )
  tr_reason_for_stop <- c(
    "1" = "Moving Violation",
    "2" = "Mechanical or Non-Moving Violation (V.C.)",
    "3" = "DUI Check",
    "4 "= "Penal Code Violation",
    "5" = "MPC Violation",
    "6" = "BOLO/APB/Warrant",
    "7" = "Traffic Collision",
    "8" = "Assistance to Motorist"
  )
  tr_vehicle_searched <- c(
    "0" = "Searched as a result of Probation or Parole Condition",
    "1" = "No Search",
    "2" = "Search without Consent, Positive Result",
    "3" = "Search without Consent, Negative Result",
    "4" = "Search with Consent, Positive Result",
    "5" = "Search with Consent, Negative Result",
    "6" = "Search Incident to Arrest, Positive Result",
    "7" = "Search Incident to Arrest, Negative Result",
    "8" = "Vehicle Inventory, Positive Result",
    "9" = "Vehicle Inventory, Negative Result"
  )
  tr_result_of_contact <- c(
    "1" = "In Custody Arrest",
    "2" = "Citation",
    "3" = "Warning",
    "4" = "Incident Report",
    "5" = "No Further Action"
  )
  bind_rows(
    d$data,
    select(d_2015$data, -blank),
    d_2014_h2$data
  ) %>%
  mutate(
    race_description = tr_race[race],
    reason_for_stop_description = tr_reason_for_stop[reason_for_stop],
    search_vehicle_description = tr_vehicle_searched[search_vehicle],
    result_of_contact_description = tr_result_of_contact[result_of_contact]
  ) %>%
  bundle_raw(c(
    d$loading_problems,
    d_2014_h2$loading_problems,
    d_2015$loading_problems
  ))
}


clean <- function(d, helpers) {

  d$data %>%
    merge_rows(
      date,
      time,
      race_description,
      sex,
      age,
      location,
      district
    ) %>%
    select(
      -reason_for_stop
    ) %>%
    rename(
      subject_age = age,
      reason_for_stop = reason_for_stop_description
    ) %>%
    mutate(
      # NOTE: all the reasons for the stop are vehicle related
      type = "vehicular",
      date = coalesce(
        parse_date(date),
        parse_date(date, "%d-%b-%y")
      ),
      time = parse_time_int(time),
      subject_race = tr_race[race],
      subject_sex = tr_sex[sex],
      search_vehicle = !str_detect(search_vehicle_description, "No Search"),
      search_conducted = search_vehicle,
      search_basis = first_of(
        consent = str_detect(search_vehicle_description, "with Consent"),
        # NOTE: other than consent, there are only inventory, incident
        # to arrest, and parole searches
        other = TRUE
      ),
      # NOTE: unfortunately, we don't get any greater resolution than
      # "Positive Result" for the searches
      contraband_found = str_detect(search_vehicle_description, "Positive"),
      arrest_made = str_detect(result_of_contact_description, "Arrest"),
      citation_issued = str_detect(result_of_contact_description, "Citation"),
      warning_issued = str_detect(result_of_contact_description, "Warning"),
      outcome = first_of(
        arrest = arrest_made,
        citation = citation_issued,
        warning = warning_issued
      )
    ) %>%
    helpers$add_lat_lng(
    ) %>%
    rename(
      raw_search_vehicle_description = search_vehicle_description,
      raw_result_of_contact_description = result_of_contact_description
    ) %>%
    standardize(d$metadata)
}
