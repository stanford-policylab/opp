source("common.R")

load_raw <- function(raw_data_dir, n_max) {
  cit <- load_regex(
    raw_data_dir,
    'Citations',
    n_max = n_max,
    col_names = c(
      "agency",
      "citation_number",
      "date",
      "time",
      "sex",
      "race",
      "age",
      "viol_code",
      "desc",
      "house",
      "street",
      "ht_ft",
      "ht_in",
      "weight"
    ),
    skip = 1
  )
  warn <- load_regex(
    raw_data_dir,
    'Warnings',
    n_max = n_max,
    col_names = c(
      "contact",
      "date",
      "time",
      "house",
      "street",
      "sex",
      "race",
      "desc"
    ),
    skip = 1
  )
  bundle_raw(
    bind_rows(cit$data, warn$data),
    c(cit$loading_problems, warn$loading_problems)
  )
}


clean <- function(d, helpers) {

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
    helpers$add_type(
      "desc"
    ) %>%
    filter(
      type != "other"
    ) %>%
    rename(
      reason_for_stop = desc
    ) %>%
    mutate(
      date = parse_date(date, "%Y%m%d"),
      time = coalesce(
        parse_time_int(time),
        parse_time_int(time, fmt = "%H%M%S")
      ),
      location = str_c_na(house, street, sep = " "),
      warning_issued = !is.na(contact),
      citation_issued = !is.na(citation_number),
      # TODO(phoebe): can we get arrests?
      # https://app.asana.com/0/456927885748233/579650153274287
      outcome = first_of(
        warning = warning_issued,
        citation = citation_issued
      ),
      subject_race = tr_race[race],
      subject_sex = tr_sex[sex]
    ) %>%
    helpers$add_lat_lng(
    ) %>%
    standardize(d$metadata)
}
