source("common.R")

load_raw <- function(raw_data_dir, n_max) {
  d <- load_years(raw_data_dir, n_max)
  bundle_raw(d$data, d$loading_problems)
}


clean <- function(d, helpers) {

  tr_violations <- c(
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

  # TODO(phoebe): what are kots_* and dots_* files vs the yearly data?
  #
  # TODO(phoebe): can we get a data dictionary for ReasonForStop?
  # TODO(danj): map highways to county
  #
  d$data %>%
    rename(
      date = DateOfStop,
      time = TimeOfStop,
      officer_id = BadgeNumber,
      location = OtherLocation,
      county = County,
      vehicle_year = VehicleYear,
      vehicle_type = VehicleStyle
    ) %>%
    mutate(
      # NOTE: there doesn't seem to be any other way to suss out whether this
      # was a pedestrian stop; presumably this is quite low, since these are
      # state patrol stops; PE = Pedestrian, BI = Bicyclist
      type = if_else(
        str_detect(TypeOfSearch, "PE|BI"),
        "pedestrian",
        "vehicular"
      ),
      subject_race = tr_race[Ethnicity],
      subject_sex = tr_sex[Gender],
      reason_for_stop = translate_by_char_group(
        PreStopIndicators,
        tr_pre_stop_indicator,
        sep = ","
      ),
      violation = translate_by_char_group(
        ViolationsObserved,
        tr_violations,
        sep = ","
      ),
      # NOTE: DR = Driver, PS = Passenger, PE = Pedestrian, BI = Bicyclist
      search_person = str_detect(TypeOfSearch, "DR|PS|PE|BI")
        | tr_yn[SearchOfDriver],
      search_vehicle = tr_yn[SearchOfVehicle],
      search_conducted = tr_yn[SearchPerformed],
      search_basis = first_of(
        "consent" = tr_yn[ConsentSearchAccepted],
        "other" = tr_yn[DUISearchWarrant],
        "probable cause" = search_conducted 
      ),
      contraband_drugs = !is.na(DrugSeizureType),
      contraband_found = contraband_drugs,
      warning_issued = str_detect(OutcomeOfStop, "WA"),
      citation_issued = str_detect(OutcomeOfStop, "CI|DV|TC"),
      arrest_made = str_detect(OutcomeOfStop, "AR|WR"),
      outcome = first_of(
        arrest = arrest_made,
        citation = citation_issued,
        warning = warning_issued
      )
    ) %>%
    standardize(d$metadata)
}
