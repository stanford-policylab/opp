source(here::here("lib", "common.R"))

load_raw <- function(raw_data_dir, n_max) {
  d <- load_regex(raw_data_dir, "citation", n_max = n_max)

  mutate(
    d$data,
    # NOTE: Fix some column name inconsistencies between files.
    Offense = coalesce(Offense, `Offense Description`),
    Code = coalesce(Code, `Offense Code`),
    # NOTE: The arrest file does not contain a Result column, so fill it in.
    Result = coalesce(Result, if_else(Arrest == 'YES', 'ARREST', NA_character_))
  ) %>%
  # NOTE: Drop partial columns.
  select(
    -Arrest,
    -`Offense Description`,
    -`Offense Code`
  ) %>%
  bundle_raw(d$loading_problems)
}


clean <- function(d, helpers) {
  # NOTE: The data do not mark hispanics.
  tr_race <- c(
    W = "white",
    B = "black",
    A = "asian/pacific islander",
    I = "other",
    M = "other",
    U = "unknown"
  )

  # TODO(phoebe): can we get search/contraband fields?
  # https://app.asana.com/0/456927885748233/749213148338105
  d$data %>%
    add_raw_colname_prefix(
      Race
    ) %>% 
    rename(
      subject_age = Age
    ) %>%
    mutate(
      date = parse_date(Date, "%Y/%m/%d"),
      # NOTE: Source data are all state police traffic stops.
      type = "vehicular",
      subject_race = tr_race[raw_Race],
      violation = str_c(Code, str_to_lower(Offense), sep = ": "),
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
