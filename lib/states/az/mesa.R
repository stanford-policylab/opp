source("common.R")

load_raw <- function(raw_data_dir, geocodes_path) {
	loading_problems <- list()
  fname <- "2014-03-17_citations_data_prr_sheet_1.csv"
  data <- read_csv_with_types(
    file.path(raw_data_dir, fname),
    c(
      incident_no       = "n",
      arrest_no         = "n",
      cite_no           = "n",
      sex               = "c",
      race              = "c",
      race_fixed        = "c",
      ehtnic            = "c",
      ethnicity_fixed   = "c",
      age               = "i",
      date              = "D",
      time              = "i",
      block             = "i",
      city              = "c",
      ofcr_lnme         = "c",
      ofcr_id           = "i",
      charge_seq        = "i",
      charge            = "c",
      charge_desc       = "c",
      warning           = "c"
    )
  )
  # TODO(danj): update
  # ) %>%
  # add_lat_lng(
  #   "block",
  #    geocodes_path
  # )

  loading_problems[[fname]] <- problems(data)
	list(data = data, metadata = list(loading_problems = loading_problems))
}


clean <- function(d) {
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

  d$data %>%
    select(
      -race,    # race_fixed replaces this
      -ehtnic   # ethnicity_fixed replaces this
    ) %>%
    rename(
      incident_id = incident_no,
      incident_date = date,
      incident_time = time,
      incident_location = block,
      citation_number = cite_no,
      subject_sex = sex,
      subject_race = race_fixed,
      subject_ethnicity = ethnicity_fixed,
      subject_age = age,
      officer_last_name = ofcr_lnme,
      officer_id = ofcr_id,
      charge_made = charge_seq,
      charge_code = charge,
      charge_description = charge_desc,
      warning_issued = warning
    ) %>%
    mutate(
      incident_time = parse_time_int(incident_time),
      arrest_made = !is.na(arrest_no),
      citation_issued = !is.na(cite_no),
      subject_sex = tr_sex[subject_sex],
      # TODO(ravi): H, N, U meaning?
      # https://app.asana.com/0/456927885748233/521735743717414 
      subject_race = tr_race[
        ifelse(subject_ethnicity == "H", "H", subject_race)
      ],
      reason_for_stop = charge_description,
      # TODO(ravi): how to classify vehicular vs pedestrian 
      # https://app.asana.com/0/456927885748233/521735743717414 
      warning_issued = yn_to_tf[warning_issued]
    ) %>%
    standardize(d$metadata)
}
