source("common.R")

load_raw <- function(raw_data_dir, n_max) {
  x <- load_regex(raw_data_dir, "201(3|4|5)", n_max)
  y <- load_regex(raw_data_dir, "201(6|7)", n_max)
  # NOTE: change names in earlier dates to match those in 2016-2017
  bundle_raw(
    bind_rows(
      rename(
        x$data,
        contactdate = ContactDate,
        contacttime = ContactTime,
        subject_reasonforencounter = ReasonForEncounter,
        subject_resultofencounter = ResultOfEncounter,
        subject_resultsofsearch = ResultOfSearch,
        streetname = StreetName,
        subject_typeofsearch = TypeOfSearch,
        subject_sdrace = SDRace,
        subject_searchconducted = SearchConducted,
        subject_sex = Sex,
        subject_typeofsearch = TypeOfSearch
      ),
      rename(
        y$data,
        subject_resultofsearch = subject_resultofsearchM
      )
    ),
    c(x$loading_problems, y$loading_problems)
  )
}


clean <- function(d, helpers) {

  tr_race <- c(tr_race, P = "other/unknown")

  filter_out_non_contraband <- function(v) {
    cbs <- str_split(str_to_lower(v), ",")
    simple_map(cbs, function(x) {
      y <- str_c(
        x[
          !is.na(x)
          & x != ""
          & !str_detect(x, "returned|none")
        ],
        collapse = ", "
      )
      if (identical(y, character(0))) NA_character_ else y
    })
  }

  v <- d$data %>%
    merge_rows(
      contactdate,
      contacttime,
      streetname,
      subject_sdrace,
      subject_sex,
      subject_age
    ) %>%
    rename(
      location = streetname,
      reason_for_stop = subject_reasonforencounter,
      officer_assignment = specialassignmenttype
    ) %>%
    mutate(
      type = case_when(
        str_detect(encountertype, "(V|v)ehicle")
        | str_detect(reason_for_stop, "Traffic") ~ "vehicular",
        str_detect(encountertype, "Pedestrian|Bicycle") ~ "pedestrian",
        T ~ NA_character_
      ),
      date = parse_date(contactdate),
      time = parse_time_int(contacttime),
      subject_race = tr_race[subject_sdrace],
      subject_sex = tr_sex[subject_sex],
      tmp_outcome = str_to_lower(subject_resultofencounter),
      warning_issued = str_detect(tmp_outcome, "warning"),
      citation_issued = str_detect(tmp_outcome, "citation"),
      arrest_made = str_detect(tmp_outcome, "arrest"),
      outcome = first_of(
        arrest = arrest_made,
        citation = citation_issued,
        warning = warning_issued
      ),
      search_conducted = tr_yn[subject_searchconducted],
      tmp_search = str_replace(str_to_lower(subject_typeofsearch), ",", ""),
      search_basis = case_when(
        str_detect(tmp_search, "p/c|probable|weapon") ~ "probable cause",
        str_detect(tmp_search, "consent") ~ "consent",
        str_detect(
          tmp_search,
          "incident|parole|prob.|cursory|inventory"
        ) ~ "other",
        T ~ NA_character_
      ),
      tmp_contraband = filter_out_non_contraband(subject_resultofsearch),
      contraband_found = !is.na(tmp_contraband),
      contraband_drugs = str_detect(tmp_contraband, "narcotic|marijuana"),
      contraband_weapons = str_detect(tmp_contraband, "weapon|firearm"),
      use_of_force_description = if_else(
        tr_yn[subject_handcuffed],
        "handcuffed",
        NA_character_
      ),
      lower_location = str_to_lower(location)
    ) %>%
    helpers$add_lat_lng(
      "lower_location"
    ) %>%
    standardize(d$metadata)
}
