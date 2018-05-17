source("common.R")

load_raw <- function(raw_data_dir, n_max) {
  fname <- "hartford_data_13-16_sheet_1.csv" 
  data <- read_csv(file.path(raw_data_dir, fname), n_max = n_max)
  loading_problems <- list()
  loading_problems[[fname]] <- problems(data)
  bundle_raw(data, loading_problems)
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
    I = "non-discrentionary",
    # NOTE: Other includes: Probable Cause, Incident to Arrest,
    # Reasonable Suspicion, Plain View Contraband, Drug Dog Alert, and
    # Exigent Circumstances; since most of these are "probable cause" related
    # reasons, we have made it probable cause even though it's possible to have
    # a non-discretionary search here (like incident to arrest)
    O = "probable cause"
  )

  tr_reason_for_stop <- c(
    I = "Investigation, Criminal",
    V = "Violation, Motor Vehicle",
    E = "Equipment, Motor Vehicle"
  )

  d$data %>%
    rename(
    # NOTE: lat/lng provided in the data are 99.99% null
      incident_location = InterventionLocationDescriptionText,
      search_vehicle = VehicleSearchedIndicator,
      contraband_found = ContrabandIndicator,
      subject_age = SubjectAge
    ) %>%
    mutate(
      incident_datetime = parse_datetime(
        InterventionDateTime,
        "%Y/%m/%d %H:%M:%S"
      ),
      # NOTE: all InterventionReasonCodes are vehicle related
      incident_type = "vehicular",
      incident_date = as.Date(incident_datetime),
      incident_time = format(incident_datetime, "%H:%M:%S"),
      subject_race = tr_race[
        ifelse(SubjectEthnicityCode == "H", "H", SubjectRaceCode)
      ],
      search_type = tr_search_type[SearchAuthorizationCode],
      subject_sex = tr_sex[SubjectSexCode],
      search_conducted = search_vehicle | SearchAuthorizationCode != "N",
      reason_for_stop = tr_reason_for_stop[InterventionReasonCode],
      # NOTE: U = "Uniform Arrest Report"
      arrest_made = CustodialArrestIndicator
        | InterventionDispositionCode == "U",
      # NOTE: I = "Infraction"
      citation_issued = InterventionDispositionCode == "I",
      # NOTE: W = "Written Warning", V = "Verbal Warning"
      warning_issued = InterventionDispositionCode == "W"
        | InterventionDispositionCode == "V",
      incident_outcome = first_of(
        arrest = arrest_made,
        citation = citation_issued,
        warning = warning_issued
      ),
      officer_id = ReportingOfficerIdentificationID
    ) %>%
    helpers$add_lat_lng(
    ) %>%
    standardize(d$metadata)
}
