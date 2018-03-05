source("common.R")

load_raw <- function(raw_data_dir, n_max) {
  data <- tibble()
	loading_problems <- list()
  for (year in 2007:2016) {
    citations_fname <- str_c(year, " Citations.csv")
    warnings_fname <- str_c(year, " Warnings.csv")
    citations <- read_csv_with_types(
      file.path(raw_data_dir, citations_fname),
      c(
        agency              = "c",
        citation_number     = "c",
        date                = "c",
        time                = "c",
        sex                 = "c",
        race                = "c",
        age                 = "i",
        viol_code           = "c",
        desc                = "c",
        house               = "c",
        street              = "c",
        ht_ft               = "i",
        ht_in               = "i",
        weight              = "i"
      )
    )
    warnings <- read_csv_with_types(
      file.path(raw_data_dir, warnings_fname),
      c(
        contact             = "c",
        date                = "c",
        time                = "c",
        house               = "c",
        street              = "c",
        sex                 = "c",
        race                = "c",
        desc                = "c"
      )
    )
    data <- bind_rows(data, citations, warnings)
		loading_problems[[citations_fname]] <- problems(citations)
		loading_problems[[warnings_fname]] <- problems(warnings)
    if (nrow(data) > n_max) {
      data <- data[1:n_max, ]
      break
    }
  }
  bundle_raw(data, loading_problems)
}


clean <- function(d, calculated_features_path) {

  tr_race <- c(
    A = "asian/pacific islander",
    B = "black",
    I = "other/unknown",
    U = "other/unknown",
    W = "white"
  )
  
  # TODO(phoebe): can we get search fields?
  # https://app.asana.com/0/456927885748233/579650153274288
  # TODO(phoebe): can we get contraband fields?
  # https://app.asana.com/0/456927885748233/579650153274289
  d$data %>%
    add_incident_types(
      "desc",
      calculated_features_path
    ) %>%
    filter(
      incident_type != "other"
    ) %>%
    rename(
      reason_for_stop = desc
    ) %>%
    mutate(
      incident_date = parse_date(date, "%Y%m%d"),
      incident_time = coalesce(
        parse_time_int(time),
        parse_time_int(time, fmt = "%H%M%S")
      ),
      incident_location = str_combine_cols(house, street, sep = " "),
      warning_issued = !is.na(contact),
      citation_issued = !is.na(citation_number),
      # TODO(phoebe): can we get arrests?
      # https://app.asana.com/0/456927885748233/579650153274287
      incident_outcome = first_of(
        warning = warning_issued,
        citation = citation_issued
      ),
      subject_race = tr_race[race],
      subject_sex = tr_sex[sex]
    ) %>%
    add_lat_lng(
      "incident_location",
      calculated_features_path
    ) %>%
    standardize(d$metadata)
}
