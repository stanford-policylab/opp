source("common.R")

load_raw <- function(raw_data_dir, n_max) {
  data <- tibble()
	loading_problems <- list()
  for (year in 2006:2015) {
    fname <- str_c("trafs_evs_", year, "_sheet_1.csv")
    tbl <- read_csv_with_types(
      file.path(raw_data_dir, fname),
      c(
        rin                       = "c",
        datetime                  = "c",
        address                   = "c",
        type                      = "c",
        pri                       = "i",
        mir_and_description       = "c",
        disposition_description   = "c",
        veh                       = "c",
        possible_race_and_sex     = "c",
        subject_dob               = "c",
        officer_no_name_1         = "c",
        officer_no_name_2         = "c",
        empty                     = "c"
      )
    )
		data <- bind_rows(data, tbl)
		loading_problems[[fname]] <- problems(tbl)
    if (nrow(data) > n_max) {
      data <- data[1:n_max, ]
      break
    }
  }
  # TODO(danj): read and translate types.csv -> types col
  types_fname <- "types.csv"
  types <- read_csv(file.path(raw_data_dir, types_fname))
  loading_problems[[types_fname]] <- problems(types)

  tr_type <- translator_from_tbl(types, "type_code", "translation")
  mutate(
    data,
    type_description = tr_type[type]
  ) %>%
  bundle_raw(loading_problems)
}


clean <- function(d, calculated_features_path) {

  vehicle <- fromJSON(file.path(calculated_features_path, "vehicle.json"))
  ped_pattern <- paste(c(
    "DISTURBANCE",
    "FOOT",
    "HARAS",
    "MISCHIEF",
    "NARCOTIC",
    "NOISE",
    "PROPERTY",
    "PROSTITUT",
    "SEX",
    "SHOTS",
    "WELFARE"
  ), collapse = "|")

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
      incident_type = ifelse(
        str_detect(mir_and_description, "PEDESTRIAN")
        | (str_detect(mir_and_description, "PURSUIT")
           & !is.na(type_description)
           & str_detect(type_description, ped_pattern))
        | (str_detect(mir_and_description, "MISCELLANEOUS")
           & !is.na(type_description)
           & str_detect(type_description, ped_pattern)),
        "pedestrian",
        "vehicular"
      ),
      incident_date = parse_date(incident_date, "%Y/%m/%d"),
      subject_race = tr_race[subject_race],
      subject_sex = tr_sex[subject_sex],
      arrest_made = str_sub(disposition_description, 1, 1) == "A",
      # NOTE: includes criminal and non-criminal citations
      citation_issued = str_detect(disposition_description, "CITATION"),
      incident_outcome = first_of(
        arrest = arrest_made,
        citation = citation_issued
      ),
      reason_for_stop = coalesce(type_description, mir_and_description),
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
