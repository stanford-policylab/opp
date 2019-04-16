source("common.R")

# VALIDATION: [YELLOW] Bakersfield Police Department provides crime mapping
# here: https://www.crimemapping.com/map/ca/bakersfield, but doesn't appear to
# offer any annual report; however, the top figures look reasonable given a
# population of roughly 350k; 2008 and 2018 appear to only have partial data
# TODO(phoebe): why do we see a dip in stops in 2013? See report
# https://app.asana.com/0/456927885748233/944841731070584
load_raw <- function(raw_data_dir, n_max) {
  # NOTE: the files that are named with just years are the CAD Call
  # information, which are not loaded or processed here but available in the
  # raw data directory
  data <- tibble()
  loading_problems <- list()
  for (year in range_of_years_from_filenames(raw_data_dir, "_traffic_")) {
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
  # TODO(phoebe): can we get reason_for_stop/search/contraband fields?
  # https://app.asana.com/0/456927885748233/645792862056543
  # TODO(phoebe): what are the following ticket classes: O, W, C, V, P?
  # https://app.asana.com/0/456927885748233/645792862056544
  # TODO(phoebe): what are the following ticket statuses: C, W, E, V?
  # https://app.asana.com/0/456927885748233/645792862056545
  # TODO(phoebe): can we get a data dictionary for statute_{name, section}
  # https://app.asana.com/0/456927885748233/645792862056546
  d$data %>%
    merge_rows(
      date_of_birth,
      subject_address,
      ethnicity,
      gender_code,
      occ_date,
      occ_time
    ) %>%
    mutate(
      # TODO(danj): improve this once we get decodings for statute_section;
      # until then, going with vehicular stops since the file has
      # traffic_citations in the name
      # https://app.asana.com/0/456927885748233/645792862056547
      type = "vehicular",
      date = parse_date(occ_date),
      time = parse_time_int(occ_time),
      location = str_replace(street_name, "/", "AND"),
      # TODO(phoebe): can we get other outcomes (warnings, arrests)?
      # https://app.asana.com/0/456927885748233/645792862056548
      citation_issued = TRUE,
      outcome = "citation",
      subject_race = tr_race[if_else_na(ethnicity == "H", "H", race)],
      subject_sex = tr_sex[gender_code],
      subject_dob = parse_date(date_of_birth)
    ) %>%
    helpers$add_lat_lng(
    ) %>%
    helpers$add_shapefiles_data(
    ) %>%
    rename(
      # NOTE: BEAT_ID is the id, USER_FLAG is the human-readable beat name
      beat = USER_FLAG,
      raw_race = race,
      raw_ethnicity = ethnicity,
      raw_statute_section = statute_section,
      raw_statute_name = statute_name
    ) %>%
    standardize(d$metadata)
}
