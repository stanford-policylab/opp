source("common.R")

load_raw <- function(raw_data_dir, n_max) {
  d <- load_years(raw_data_dir, n_max)
  bundle_raw(d$data, d$loading_problems)
}


clean <- function(d, helpers) {

  tr_citation_arrest_violations <- c(
    "ER" = "expired registration",
    "NL" = "no license",
    "SP" = "speed",
    "UL" = "unsafe lane change",
    "FC" = "following too close",
    "IT" = "improper turning",
    "FS" = "failure to signal",
    "FT" = "failure to stop",
    "LR" = "lamps required",
    "EV" = "equipment violation",
    "OM" = "other moving violation",
    "ON" = "other non-moving violation",
    "DU" = "DUI",
    "NI" = "no insurance"
  )

  tr_race <- c(
    W = "white",
    H = "hispanic",
    B = "black",
    N = "other/unknown",
    A = "asian/pacific islander",
    M = "other/unknown",
    X = "other/unknown"
  )

  # TODO(danj): map highways to county
  #
  d$data %>%
    rename(
      date = DateOfStop,
      officer_id = BadgeNumber,
      location = OtherLocation
    ) %>%
    mutate(
      # NOTE: there doesn't seem to be any other way to suss out whether this
      # was a pedestrian stop; presumably this is quite low, since these are
      # state patrol stops; PE = Pedestrian, BI = Bicyclist
      type = ifelse(
        str_detect(TypeOfSearch, "PE|BI"),
        "pedestrian",
        "vehicular"
      ),
      subject_race = tr_race[Ethnicity],
      subject_sex = tr_sex[Gender],
      pre_stop_indicator = translate_by_char_group(
        PreStopIndicators,
        tr_pre_stop_indicator,
        ","
      ),
      violation = translate_by_char_group(
        CitationArrestViolations,
        tr_citation_arrest_violations,
        ","
      ),
      # NOTE: if the officer listed a pre-stop indicator, this is used,
      # otherwise, it defaults to the violation
      reason_for_stop = coalesce(pre_stop_indicator, violation),
      # NOTE: DR = Driver, PS = Passenger, PE = Pedestrian, BI = Bicyclist
      search_person = str_detect(TypeOfSearch, "DR|PS|PE|BI")
      search_vehicle = tr_yn[SearchOfVehicle],
      search_conducted = tr_yn[SearchPerformed],
      search_type = first_of(
        "consent" = tr_yn[ConsentSearchAccepted],
        "non-discretionary" = tr_yn[DUISearchWarrant],
        "probable cause" = search_conducted 
      ),
      contraband_drugs = !is.na(DrugSeizureType),
      contraband_found = contraband_drugs
    ) %>%
    standardize(d$metadata)
}
