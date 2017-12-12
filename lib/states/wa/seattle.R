source("common.R")

load_raw <- function(raw_data_dir, geocodes_path) {
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
  }
  data <- add_lat_lng(data, "address", geocodes_path)

	list(data = data, metadata = list(loading_problems = loading_problems))
}


clean <- function(d) {
  d$data %>%
    select(
      -empty
    ) %>%
    rename(
      incident_id = rin,
      incident_location = address,
      # TODO(journalist): clarify relationship between
      # mir_and_description, disposition_description, type
      # https://app.asana.com/0/456927885748233/462732257741348 
      reason_for_stop = mir_and_description
    ) %>%
    filter(
      !is.na(incident_id)
    ) %>%
    separate_cols(
      list(possible_race_and_sex = c("subject_race", "subject_sex")),
      sep = 1
    ) %>%
    separate_cols(
      list(
        datetime = c("incident_date", "incident_time"),
        officer_no_name_1 = c("officer_id_1", "officer_name_1"),
        officer_no_name_2 = c("officer_id_2", "officer_name_2")
      )
    ) %>%
    mutate(
      incident_type = "vehicular",
      # NOTE: vehicular because mir_and_description are all traffic
      incident_date = parse_date(incident_date, "%Y/%m/%d"),
      incident_time = parse_time(incident_time),
      subject_race = tr_race[subject_race],
      subject_sex = tr_sex[subject_sex],
      arrest_made = str_sub(disposition_description, 1, 1) == "A",
      # NOTE: includes criminal and non-criminal citations
      citation_issued = matches(disposition_description, "CITATION"),
      incident_outcome = ifelse(
        arrest_made,
        "arrest",
        ifelse(
          citation_issued,
          "citation",
          NA
        )
      ),
      subject_dob = ymd(subject_dob),
      officer_id_1 = parse_number(officer_id_1),
      officer_id_2 = parse_number(officer_id_2)
    ) %>%
    standardize(d$metadata)
}
