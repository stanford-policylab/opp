source("common.R")

load_raw <- function(raw_data_dir, n_max) {
  load_single_file(
    raw_data_dir,
    "2014-03-17_citations_data_prr.csv",
    n_max
  )
}


clean <- function(d, helpers) {

  tr_race <- c(
    A = "asian/pacific islander",
    B = "black",
    H = "hispanic",
    I = "other/unknown",
    U = "other/unknown",
    W = "white"
  )

  tr_yn = c(
    YES = TRUE,
    NO = FALSE
  )

  colnames(d$data) <- tolower(colnames(d$data))

  d$data %>%
    mutate(
      location = str_trim(
        str_c(
          block,
          city,
          sep = ", "
        )
      )
    ) %>%
    helpers$add_lat_lng(
    ) %>%
    rename(
      subject_age = age,
      officer_id = ofcr_id,
      officer_last_name = ofcr_lnme,
      violation = charge_desc
    ) %>%
    mutate(
      time = parse_time_int(time),
      charge_prefix = str_extract(charge, "[0-9]+"),
      # TODO(ravi): ped vs veh, and what should we filter out?
      # https://app.asana.com/0/456927885748233/521735743717414 
      type = ifelse(
        charge_prefix == "28" & !str_detect(violation, "BICYC"),
        "vehicular",
        NA
      ),
      arrest_made = !is.na(arrest_no),
      citation_issued = !is.na(cite_no),
      warning_issued = tr_yn[warning],
      outcome = first_of(
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
