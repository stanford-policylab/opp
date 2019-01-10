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

  tr_search_basis <- c(
    A = "other",
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
    mutate(
      # NOTE: Time is always midnight UTC, so we drop it.
      date = parse_date(str_sub(DateIssue, 1, 10), "%Y-%m-%d"),
      subject_age = year(date) - format_two_digit_year(DOBYr),
      subject_race = fast_tr(Race, tr_race),
      subject_sex = tolower(Sex),
      # NOTE: dataset does not include pedestrian stops.
      type = "vehicular",
      arrest_made = str_detect("Arrest", ResultDescr),
      citation_issued = str_detect("Civil|Criminal", ResultDescr),
      warning_issued = str_detect("Warning", ResultDescr),
      outcome = first_of(
        arrest = arrest_made,
        citation = citation_issued,
        warning = warning_issued
      ),
      # NOTE: there are very few cases where "RsltSrchNo" and "RsltSrchXX" are both
      # true (< 1%). In these cases, we give RsltSrchNo precedence 
      contraband_drugs = RsltSrchDrg == "1" & RsltSrchNo == "0",
      contraband_weapons = RsltSrchWpn == "1" & RsltSrchNo == "0",
      contraband_alcohol = RsltSrchAlc == "1" & RsltSrchNo == "0",
      contraband_other = (RsltSrchMny == "1" | RsltSrchOth == "1") & RsltSrchNo == "0",
      contraband_found = contraband_drugs | contraband_weapons | 
        contraband_alcohol | contraband_other,
      search_conducted = SearchYN == "Yes" | !is.na(SearchDescr),
      frisk_performed = search_conducted & SearchDescr == "Terry Frisk",
      search_basis = fast_tr(SearchType, tr_search_basis),
      # NOTE: If a reason for stop is not given we record the value as NA.
      reason_for_stop_raw = str_c_na(
        if_else(Speed == "1", "Speed", NA_character_),
        if_else(SeatBelt == "1", "SeatBelt", NA_character_),
        if_else(ChildRest == "1", "ChildRest", NA_character_),
        sep = ","
      ),
      reason_for_stop = if_else(
        reason_for_stop_raw == "",
        NA_character_,
        reason_for_stop_raw
      )
    ) %>%
    filter(
      # NOTE: Drop incomplete years. There are only a handful of stops in the
      # data before 2007, so those years are clearly wrong. It appears that the
      # first few months (nearly half) of 2007 are also incomplete, but we have
      # not attempted to remove the incomplete months.
      year(date) >= 2007
    ) %>%
    standardize(d$metadata)
}
