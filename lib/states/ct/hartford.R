source("common.R")

load_raw <- function(raw_data_dir, n_max) {
  d <- load_single_file(raw_data_dir, "hartford_data_13-16.csv", n_max)
  bundle_raw(d$data, d$loading_problems)
}


clean <- function(d, helpers) {

  tr_race <- c(
    A = "asian/pacific islander",
    B = "black",
    I = "other/unknown",
    W = "white",
    H = "hispanic"
  )

  tr_search_type <- c(
    C = "consent",
    # NOTE: inventory
    I = "non-discretionary",
    # NOTE: Other includes: Probable Cause, Incident to Arrest,
    # Reasonable Suspicion, Plain View Contraband, Drug Dog Alert, and
    # Exigent Circumstances; since most of these are "probable cause" related
    # reasons, we have made it probable cause even though it's possible to have
    # a non-discretionary search here (like incident to arrest)
    O = "probable cause"
  )

  d$data %>%
    rename(
    # NOTE: lat/lng provided in the data are 99.99% null
      contraband_found = ContrabandIndicator,
      department_name = `Department Name`,
      location = InterventionLocationDescriptionText,
      officer_id = ReportingOfficerIdentificationID,
      reason_for_stop = StatutoryReasonForStop,
      search_vehicle = VehicleSearchedIndicator,
      subject_age = SubjectAge
    ) %>%
    mutate(
      datetime = parse_datetime(
        InterventionDateTime,
        "%Y/%m/%d %H:%M:%S"
      ),
      date = as.Date(datetime),
      time = format(datetime, "%H:%M:%S"),
      # NOTE: all InterventionReasonCodes are vehicle related
      type = "vehicular",
      subject_race = tr_race[
        ifelse(SubjectEthnicityCode == "H", "H", SubjectRaceCode)
      ],
      subject_sex = tr_sex[SubjectSexCode],
      search_conducted = as.logical(search_vehicle)
        | SearchAuthorizationCode != "N",
      search_type = tr_search_type[SearchAuthorizationCode],
      # NOTE: U = "Uniform Arrest Report"
      arrest_made = as.logical(CustodialArrestIndicator)
        | InterventionDispositionCode == "U",
      # NOTE: I = "Infraction"
      citation_issued = InterventionDispositionCode == "I",
      # NOTE: W = "Written Warning", V = "Verbal Warning"
      warning_issued = InterventionDispositionCode == "W"
        | InterventionDispositionCode == "V",
      outcome = first_of(
        arrest = arrest_made,
        citation = citation_issued,
        warning = warning_issued
      )
    ) %>%
    helpers$add_lat_lng(
    ) %>%
    standardize(d$metadata)
}
