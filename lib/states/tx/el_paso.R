source("common.R")

load_raw <- function(raw_data_dir, n_max) {
	loading_problems <- list()
  fname <- "data_from_muni_clerk_sheet_1.csv"
  data <- read_csv(file.path(raw_data_dir, fname), n_max = n_max)
  loading_problems[[fname]] <- problems(data)
  bundle_raw(data, loading_problems)
}


clean <- function(d, calculated_features_path) {
# "Offense Date"
# Time
# Citationýnumber
# Offense
# Race
# Sex
# Location
# Intersection
# "Veh Make"
# "Veh Model"
# "Veh Color"
# "Veh Year"
# "Vehicle Vrn St"
# Search
# Consent
# Contraband
# Officer
  dui_450 = "450: DRIVING UNDER THE INFLUENCE"
  mov_460 = "460: MOVING VIOLATION"
  mis_465 = "465: MISCELLANEOUS"
  ped_465 = "465: PEDESTRIAN VIOLATION"
  mis_482 = "482: MISCELLANEOUS"
  ref_482 = "482: REFUSE TO STOP (PURSUIT)"
  tr_reason_for_stop <- c(
    "450: TRAFFIC - D.U.I." = dui_450,
    "450: DRIVING UNDER THE INFLUENCE" = dui_450,
    "460: TRAFFIC - MOVING VIOLATION" = mov_460,
    "460: MOVING VIOLATION" = mov_460,
    "465: TRAFFIC, MISCELLANEOUS" = mis_465,
    "465: TRAFFIC - PEDESTRIAN VIOLATION" = ped_465,
    "482: TRAFFIC, MISCELLANEOUS" = mis_482,
    "482: TRAFFIC - REFUSE TO STOP (PURSUIT)" = ref_482
  )
  vehicle <- fromJSON(file.path(calculated_features_path, "vehicle.json"))

  d$data %>%
    # NOTE: when rin is null, almost every column is null, so filter out
    filter(
      !is.na(rin)
    ) %>%
    add_lat_lng(
      "address",
      calculated_features_path
    ) %>%
    rename(
      incident_location = address
    ) %>%
    separate_cols(
      possible_race_and_sex = c("subject_race", "subject_sex"),
      sep = 1
    ) %>%
    separate_cols(
      datetime = c("incident_date", "incident_time"),
      officer_no_name_1 = c("officer_id", "officer_name")
    ) %>%
    mutate(
      # NOTE: vehicular because mir_and_description are all traffic
      incident_type = "vehicular",
      incident_date = parse_date(incident_date, "%Y/%m/%d"),
      reason_for_stop = tr_reason_for_stop[mir_and_description],
      subject_race = tr_race[subject_race],
      subject_sex = tr_sex[subject_sex],
      arrest_made = str_sub(disposition_description, 1, 1) == "A",
      # NOTE: includes criminal and non-criminal citations
      citation_issued = str_detect(disposition_description, "CITATION"),
      incident_outcome = first_of(
        arrest = arrest_made,
        citation = citation_issued
      ),
      subject_dob = ymd(subject_dob),
      vehicle_color = str_extract(veh, str_c(vehicle$colors, collapse = "|")),
      vehicle_make = str_extract(veh, str_c(vehicle$makes, collapse = "|")),
      vehicle_model = str_extract(veh, str_c(vehicle$models, collapse = "|")),
      vehicle_year = str_extract(veh, "\\d{4}"),
      vehicle_registration_state =
        str_extract(veh, str_c(valid_states, collapse = "|"))
    ) %>%
    standardize(d$metadata)
}
