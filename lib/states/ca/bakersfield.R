source("common.R")

# NOTE: we have data for 2007, but it doesn't have any useful information; it
# looks like the schema was updated in 2008 and for serveral years they
# recorded in both formats; here, we use the assumed new format, which has
# separate files for ticket and person data for each year
load_raw <- function(raw_data_dir, n_max) {
  data <- tibble()
  loading_problems <- list()
  for (year in 2008:2018) {
    t_fname <- str_c(year, "_traffic_citation_ticket_data_fields.csv")
    p_fname <- str_c(year, "_traffic_citation_person_details.csv")
    t_tbl <- read_csv(
      file.path(raw_data_dir, t_fname),
      col_types = cols(.default = "c")
    )
    p_tbl <- read_csv(
      file.path(raw_data_dir, p_fname),
      col_types = cols(.default = "c")
    ) %>%
    rename(subject_address = street_name)
    loading_problems[[t_fname]] <- problems(t_tbl)
    loading_problems[[p_fname]] <- problems(p_tbl)
    tbl <- left_join(t_tbl, p_tbl)
    data <- bind_rows(data, tbl)
    if (nrow(data) > n_max) {
      data <- data[1:n_max, ]
      break
    }
  }
  bundle_raw(data, loading_problems)
}


clean <- function(d, helpers) {

  tr_race <- c(
    "W" = "white",
    "B" = "black",
    "U" = "other/unknown",
    "A" = "other/unknown",
    "I" = "other/unknown",
    "O" = "other/unknown",
    "H" = "hispanic"
  )

  # TODO(phoebe): can we get reason_for_stop/search/contraband fields?
  # https://app.asana.com/0/456927885748233/645792862056543
  # TODO(phoebe): what are the following ticket classes: O, W, C, V, P?
  # https://app.asana.com/0/456927885748233/645792862056544
  # TODO(phoebe): what are the following ticket statuses: C, W, E, V?
  # https://app.asana.com/0/456927885748233/645792862056545
  # TODO(phoebe): can we get a data dictionary for statute_{name, section}
  # https://app.asana.com/0/456927885748233/645792862056546
  d$data %>%
    mutate(
      # TODO(danj): improve this once we figure out the statutes
      # https://app.asana.com/0/456927885748233/645792862056547
      incident_type = "vehicular",
      incident_date = parse_date(occ_date),
      incident_time = parse_time_int(occ_time),
      incident_location = str_replace(street_name, "/", "AND"),
      # TODO(phoebe): can we get other outcomes (warnings, arrests)?
      # https://app.asana.com/0/456927885748233/645792862056548
      citation_issued = TRUE,
      incident_outcome = "citation",
      subject_race = tr_race[ifelse(ethnicity == "H", "H", race)],
      subject_sex = tr_sex[gender_code],
      subject_dob = parse_date(date_of_birth)
    ) %>%
    helpers$add_lat_lng(
    ) %>%
    standardize(d$metadata)
}
