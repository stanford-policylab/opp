source("common.R")

load_raw <- function(raw_data_dir, n_max) {
  d <- load_single_file(raw_data_dir, "FOI_Req.csv", n_max)
  counties <- load_single_file(raw_data_dir, "counties.csv")
  joined <- d$data %>%
    left_join(
      counties$data %>%
        mutate(
          Municipality.upper = toupper(Municipality)
        ),
      by = c("CITY_TOWN_NAME" = "Municipality.upper")
    )
  bundle_raw(joined, c(d$loading_problems, counties$loading_problems))
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
      vehicle_registration_state = State
    ) %>%
    separate_cols(
      DateIssue = c("date", "time")
    ) %>%
    mutate(
      date = parse_date(date, "%Y-%m-%d"),
      time = parse_time(time, "%H:%M:%S"),
      # TODO(jnu): there are route numbers that we might be able to turn into
      # more granular locations.
      # https://app.asana.com/0/456927885748233/714838053596540
      location = str_c_na(
        CITY_TOWN_NAME,
        "MA"
      ),
      subject_age = year(date) - format_two_digit_year(DOBYr),
      subject_race = fast_tr(Race, tr_race),
      subject_sex = tolower(Sex),
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
      contraband_found = (
        RsltSrchDrg == "1" |
        RsltSrchWpn == "1" |
        RsltSrchAlc == "1" |
        RsltSrchMny == "1" |
        RsltSrchOth == "1"
      ),
      frisk_performed = !is.na(SearchDescr) & SearchDescr == "Terry Frisk",
      search_conducted = SearchYN == "Y" | !is.na(SearchType),
      search_type = fast_tr(SearchType, tr_search_type),
      reason_for_stop = str_c_na(
        ifelse(Speed == "1", "Speed", NA),
        ifelse(SeatBelt == "1", "SeatBelt", NA),
        ifelse(ChildRest == "1", "ChildRest", NA)
      )
    ) %>%
    standardize(d$metadata)
}
