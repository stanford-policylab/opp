source("common.R")


# VALIDATION: [YELLOW] There is only partial data for 2017. The PD doesn't
# appear to produce annual reports with traffic figures, but the numbers seem
# reasonable given the population.
load_raw <- function(raw_data_dir, n_max) {

  # TODO(phoebe): There are 1,824 duplicated stop_ids representing ~4k rows;
  # curiously, they have different information, i.e. are at different dates,
  # times, and service areas; what is going on here?
  # https://app.asana.com/0/456927885748233/953928960154784
  stops <- load_regex(
    raw_data_dir,
    "vehicle_stops_\\d{4}_datasd.csv",
    n_max
  )

  searches <- load_regex(
    raw_data_dir,
    "vehicle_stops_search_details_\\d{4}_datasd.csv"
  )

  searches_data_merged <-
    searches$data %>%
    select(-search_details_id) %>%
    group_by(stop_id, search_details_type) %>%
    summarize(
      search_details_description = str_c(
        search_details_description,
        collapse = "|"
      )
    ) %>%
    spread(
      search_details_type,
      search_details_description
    )

  data <-
    left_join(
      stops$data,
      searches_data_merged
    ) %>%
    left_join(
      load_single_file(
        raw_data_dir,
        "vehicle_stops_race_codes.csv"
      )$data,
      by = c("subject_race" = "Race Code")
    ) %>%
    rename(subject_race_description = Description)

  bundle_raw(data, c(stops$loading_problems, searches$loading_problems))

  # NOTE: the updated data is loaded above; this will load the old data
  # d <- load_single_file(
  #   raw_data_dir,
  #   "pra_16-1288_vehiclestop2014-2015_sheet_1.csv",
  #   n_max
  # )
  # bundle_raw(d$data, d$loading_problems)
}


clean <- function(d, helpers) {

  tr_race <- c(
    tr_race,
    "other asian" = "asian/pacific islander",
    "filipino" = "asian/pacific islander",
    "vietnamese" = "asian/pacific islander",
    "chinese" = "asian/pacific islander",
    "indian" = "asian/pacific islander",
    "korean" = "asian/pacific islander",
    "japanese" = "asian/pacific islander",
    "pacific islander" = "asian/pacific islander",
    "asian indian" = "asian/pacific islander",
    "laotian" = "asian/pacific islander",
    "samoan" = "asian/pacific islander",
    "cambodian" = "asian/pacific islander",
    "guamanian" = "asian/pacific islander",
    "hawaiian" = "asian/pacific islander" 
  )

  d$data %>%
    merge_rows(
      timestamp,
      subject_race,
      subject_sex,
      subject_age,
      service_area
    ) %>%
    rename(
      reason_for_stop = stop_cause,
      time = stop_time,
      search_conducted = searched,
      search_consent = obtained_consent,
      reason_for_search = SearchBasis,
      arrest_made = arrested
    ) %>%
    apply_translator_to(
      tr_yn,
      "arrest_made",
      "search_conducted",
      "search_consent",
      "contraband_found"
    ) %>%
    mutate(
      # NOTE: all of the files are prefixed with vehicle_stops_*
      type = "vehicular",
      date = coalesce(
        parse_date(stop_date),
        parse_date(stop_date, "%m/%d/%y")
      ),
      citation_issued = str_detect(ActionTaken, "Citation"),
      warning_issued = str_detect(ActionTaken, "Warning"),
      outcome = first_of(
        arrest = arrest_made,
        citation = citation_issued,
        warning = warning_issued
      ),
      subject_race = tr_race[tolower(subject_race_description)],
      subject_sex = tr_sex[subject_sex],
      search_person = str_detect(SearchType, "Driver|Passenger"),
      search_vehicle = str_detect(SearchType, "Vehicle"),
      sr = tolower(reason_for_search),
      search_basis = first_of(
        "k9" = str_detect(sr, "k9"),
        "plain view" = str_detect(sr, "visible"),
        "consent" = search_consent | str_detect(sr, "consent"),
        # NOTE: 4th Waiver Search applies to those on parole/probation who have
        # waived their right to consent searches
        "other" = str_detect(sr, "4th|other|incident|waiver|inventory|warrant"),
        "probable cause" = search_conducted  # default
      ),
      contraband_found = if_else(
        search_conducted & is.na(contraband_found),
        F,
        contraband_found
      )
    ) %>%
    # NOTE: there are shapefiles but no location data; fortunately, there is
    # service area
    rename(
      raw_action_taken = ActionTaken,
      raw_subject_race_description = subject_race_description
    ) %>%
    standardize(d$metadata)
}
