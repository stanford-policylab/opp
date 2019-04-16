source("common.R")


# VALIDATION: [YELLOW] 2013 has only the last 2 months and 2016 all but the
# last 3 months of data. While Hartford has weekly crime reports, it doesn't
# seem to produce any other report that could be used to validate these
# figures.
load_raw <- function(raw_data_dir, n_max) {
  d <- load_single_file(raw_data_dir, "hartford_data_13-16.csv", n_max)
  bundle_raw(d$data, d$loading_problems)
}


clean <- function(d, helpers) {

  tr_search_basis <- c(
    C = "consent",
    # NOTE: inventory
    I = "other",
    # NOTE: [O]ther includes: Probable Cause, Incident to Arrest,
    # Reasonable Suspicion, Plain View Contraband, Drug Dog Alert, and
    # Exigent Circumstances; since most of these are "probable cause" related
    # reasons, we have made it probable cause even though it's possible to have
    # other non-discretionary search bases here, i.e. incident to arrest
    O = "probable cause"
  )

  d$data %>%
    merge_rows(
      InterventionDateTime,
      ReportingOfficerIdentificationID,
      InterventionLocationDescriptionText,
      SubjectRaceCode,
      SubjectSexCode,
      SubjectAge
    ) %>%
    rename(
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
        if_else(SubjectEthnicityCode == "H", "H", SubjectRaceCode)
      ],
      subject_sex = tr_sex[SubjectSexCode],
      # TODO(phoebe): the search rate is ~30%, this seems extremely high, is
      # this true?
      # https://app.asana.com/0/456927885748233/946544362639776 
      search_conducted = as.logical(search_vehicle)
        | SearchAuthorizationCode != "N",
      search_basis = tr_search_basis[SearchAuthorizationCode],
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
    # NOTE: lat/lng provided in the data are 99.99% null
    helpers$add_lat_lng(
    ) %>%
    helpers$add_shapefiles_data(
    ) %>%
    rename(
      # NOTE: no data provided here, so calling the names 'district's
      district = `data[polygon_indices, ]`,
      raw_subject_ethnicity_code = SubjectEthnicityCode,
      raw_subject_race_code = SubjectRaceCode,
      raw_search_authorization_code = SearchAuthorizationCode,
      raw_intervention_disposition_code = InterventionDispositionCode
    ) %>%
    standardize(d$metadata)
}
