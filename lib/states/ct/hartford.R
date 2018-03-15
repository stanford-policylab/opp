source("common.R")

load_raw <- function(raw_data_dir, n_max) {
  fname <- "hartford_data_13-16_sheet_1.csv" 
  data <- read_csv(file.path(raw_data_dir, fname), n_max = n_max)
  loading_problems <- list()
  loading_problems[[fname]] <- problems(data)
  bundle_raw(data, loading_problems)
}


clean <- function(d, calculated_features_path) {

  tr_race <- c(
    A = "asian/pacific islander",
    B = "black",
    I = "other/unknown",
    W = "white",
    H = "hispanic"
  )

  # TODO(phoebe): what is Intervention{Reason,Technique,Duration}Code
  # https://app.asana.com/0/456927885748233/586847974785240 
  d$data %>%
    rename(
    # NOTE: lat/lng provided in the data are 99.99% null
      incident_location = InterventionLocationDescriptionText,
      reason_for_stop = StatutoryReasonForStop,
      search_vehicle = VehicleSearchedIndicator,
      contraband_found = ContrabandIndicator,
      subject_age = SubjectAge,
      arrest_made = CustodialArrestIndicator
    ) %>%
    mutate(
      incident_datetime = parse_datetime(
        InterventionDateTime,
        "%Y/%m/%d %H:%M:%S"
      ),
      # NOTE: all the StatutoryReasonForStop values appear vehicle-related
      incident_type = "vehicular",
      incident_date = as.Date(incident_datetime),
      incident_time = format(incident_datetime, "%H:%M:%S"),
      subject_race = tr_race[
        ifelse(SubjectEthnicityCode == "H", "H", SubjectRaceCode)
      ],
      subject_sex = tr_sex[SubjectSexCode],
      # TODO(phoebe): is vehicle search only type of search conducted?
      # https://app.asana.com/0/456927885748233/586847974785241 
      search_conducted = search_vehicle,
      # TODO(phoebe): C, I, N, O for SearchAuthorizationCode? (search_type)
      # https://app.asana.com/0/456927885748233/586847974785242
      reason_for_search = SearchAuthorizationCode,
      # TODO(phoebe): I, M, N, U, V, W for InterventionDispositionCode?
      # / are these all citations except where CustodialArrestIndicator is true?
      # https://app.asana.com/0/456927885748233/586847974785243
      incident_outcome = first_of(
        arrest = arrest_made,
        citation = TRUE
      ),
      officer_id = ReportingOfficerIdentificationID
    ) %>%
    add_lat_lng(
      "incident_location",
      calculated_features_path
    ) %>%
    standardize(d$metadata)
}
