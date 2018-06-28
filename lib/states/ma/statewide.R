source("common.R")

load_raw <- function(raw_data_dir, n_max) {
  d <- load_single_file(raw_data_dir, "FOI_Req.csv", n_max)
  counties <- load_single_file(raw_data_dir, "counties.csv")
  d$data %>%
    left_join(
        mutate(
          counties$data,
          municipality_uppercased = toupper(Municipality)
        ),
      by = c("CITY_TOWN_NAME" = "municipality_uppercased")
    ) %>%
    bundle_raw(c(d$loading_problems, counties$loading_problems))
}


clean <- function(d, helpers) {
  tr_race <- c(
    "White" = "white",
    "Hispanic" = "hispanic",
    "Black" = "black",
    "Asian or Pacific Islander" = "asian/pacific islander",
    "Middle Eastern or East Indian (South Asian)" = "asian/pacific islander",
    "American Indian or Alaskan Native" = "other/unknown",
    "None - for no operator present citations only" = "other/unknown",
    "A" = "other/unknown"
  )

  tr_search_type <- c(
    A = "non-discretionary",
    C = "consent",
    P = "probable cause"
  )

  d$data %>%
    rename(
      county_name = County,
      vehicle_type = RegType,
      vehicle_registration_state = State,
      # TODO(jnu): there are route numbers that we might be able to turn into
      # more granular locations.
      # https://app.asana.com/0/456927885748233/714838053596540
      location = CITY_TOWN_NAME
    ) %>%
    separate_cols(
      DateIssue = c("date", "time")
    ) %>%
    mutate(
      date = parse_date(date, "%Y-%m-%d"),
      time = parse_time(time, "%H:%M:%S"),
      subject_age = year(date) - format_two_digit_year(DOBYr),
      subject_race = fast_tr(Race, tr_race),
      subject_sex = tolower(Sex),
      # NOTE: dataset does not include pedestrian stops
      type = "vehicular",
      arrest_made = str_detect("Arrest", ResultDescr),
      citation_issued = str_detect("Civil|Criminal", ResultDescr),
      warning_issued = str_detect("Warning", ResultDescr),
      outcome = first_of(
        arrest = arrest_made,
        citation = citation_issued,
        warning = warning_issued
      ),
      contraband_drugs = RsltSrchDrg == "1",
      contraband_weapons = RsltSrchWpn == "1",
      contraband_found = any_matches(
        "1",
        RsltSrchDrg,
        RsltSrchWpn
      ),
      search_conducted = SearchYN == "Yes" | !is.na(SearchDescr),
      frisk_performed = search_conducted & SearchDescr == "Terry Frisk",
      search_type = fast_tr(SearchType, tr_search_type),
      reason_for_stop = str_c_na(
        if_else(Speed == "1", "Speed", NA_character_),
        if_else(SeatBelt == "1", "SeatBelt", NA_character_),
        if_else(ChildRest == "1", "ChildRest", NA_character_)
      )
    ) %>%
    standardize(d$metadata)
}
