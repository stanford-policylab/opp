source("common.R")

load_raw <- function(raw_data_dir, n_max) {
  d1 <- load_single_file(
    raw_data_dir,
    "copy_of_citationwoarrestfirsthalf.csv",
    n_max = n_max
  )
  d2 <- load_single_file(
    raw_data_dir,
    "copy_of_citationswoarrestsecondhalf.csv",
    n_max = n_max
  )
  d3 <- load_single_file(
    raw_data_dir,
    "copy_of_citationswitharrest_part3.csv",
    n_max = n_max
  )
  bind_rows(
    d1$data %>% rename(Offense = `Offense Description`),
    d2$data %>% rename(Offense = `Offense Description`),
    # NOTE: Add a Result field for consistency with other sources; we will
    # normalize this later.
    d3$data %>%
      rename(
        Code = `Offense Code`
      ) %>%
      mutate(
        Result = 'ARREST'
      ) %>%
      select(-Arrest)
  ) %>%
  bundle_raw(c(d1$loading_problems, d2$loading_problems, d3$loading_problems))
}


clean <- function(d, helpers) {
  # NOTE: The data do not seem to mark hispanics.
  tr_race <- c(
    W = "white",
    B = "black",
    A = "asian/pacific islander",
    I = "other/unknown",
    M = "other/unknown",
    U = "other/unknown"
  )

  # TODO(phoebe): can we get reason_for_stop/search/contraband fields?
  # https://app.asana.com/0/456927885748233/749213148338105
  d$data %>%
    rename(
      violation = Code
    ) %>%
    mutate(
      date = parse_date(Date, "%Y/%m/%d"),
      # NOTE: Source data are all state police traffic stops.
      type = "vehicular",
      location = NA,
      subject_race = tr_race[Race],
      # NOTE: Age column contains a lot of negative values. Remove those as
      # they are obviously wrong; there is likely still some garbage with the
      # child ages.
      subject_age = if_else(as.integer(Age) < 1, NA_integer_, as.integer(Age)),
      warning_issued = Result == "WARNING",
      citation_issued = Result == "CITATION",
      arrest_made = Result == "ARREST",
      outcome = first_of(
        arrest = arrest_made,
        citation = citation_issued,
        warning = warning_issued
      )
    ) %>%
    filter(
      # NOTE: A couple of stops recorded in 2009; these look like mistakes.
      year(date) >= 2012
    ) %>%
    standardize(d$metadata)
}
