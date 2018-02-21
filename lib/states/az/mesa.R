source("common.R")

load_raw <- function(raw_data_dir, n_max) {
  fname <- "2014-03-17_citations_data_prr_sheet_1.csv"
  data <- read_csv(
    file.path(raw_data_dir, fname),
    col_types = cols(CITE_NO = col_numeric()),
    n_max = n_max
  )
	loading_problems <- list()
  loading_problems[[fname]] <- problems(data)
  bundle_raw(data, loading_problems)
}


clean <- function(d, calculated_features_path) {
  tr_race <- c(
    A = "asian/pacific islander",
    B = "black",
    H = "hispanic",
    I = "other/unknown",
    U = "other/unknown",
    W = "white"
  )
  yn_to_tf = c(
    YES = TRUE,
    NO = FALSE
  )
  colnames(d$data) <- tolower(colnames(d$data))
  d$data %>%
    mutate(
      incident_location = str_trim(
        str_c(
          block,
          city,
          sep = ", "
        )
      )
    ) %>%
    add_lat_lng(
      "incident_location",
       calculated_features_path
    ) %>%
    rename(
      incident_date = date,
      subject_age = age,
      officer_id = ofcr_id,
      reason_for_stop = charge_desc
    ) %>%
    mutate(
      charge_prefix = str_extract(charge, "[0-9]+"),
      # TODO(ravi): ped vs veh, and what should we filter out?
      # https://app.asana.com/0/456927885748233/521735743717414 
      incident_type = ifelse(
        charge_prefix == "28" & !str_detect(reason_for_stop, "BICYC"),
        "vehicular",
        NA
      ),
      incident_time = parse_time_int(time),
      arrest_made = !is.na(arrest_no),
      citation_issued = !is.na(cite_no),
      warning_issued = yn_to_tf[warning],
      incident_outcome = first_of(
        arrest = arrest_made,
        citation = citation_issued,
        warning = warning_issued
      ),
      subject_sex = tr_sex[sex],
      subject_race = tr_race[
        ifelse(ethnicity_fixed == "H", "H", race_fixed)
      ]
    ) %>%
    standardize(d$metadata)
}
