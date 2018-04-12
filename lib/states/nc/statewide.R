source("common.R")

load_raw <- function(raw_data_dir, n_max) {
  loading_problems <- list()
  r <- function(fname, n_max = Inf) {
    tbl <- read_csv(file.path(raw_data_dir, fname), n_max = n_max)
    loading_problems[[fname]] <<- problems(tbl)
    tbl
  }
  stop <- r("stop.csv", n_max)
  search <- r("search.csv")
  search_basis <- r("searchbasis.csv")
  # NOTE: D is Driver and P is Passenger, see refcommoncode.csv;
  # drop Type as well, since it's now useless and Type in search.csv
  # corresponds to search type, which we want to keep
  person <- r("person.csv") %>% filter(Type == "D") %>% select(-Type)
  contraband <- r("contraband.csv")
  common_codes <- r("refcommoncode.csv")
  stop_codes <- r("refstopscodenumber.csv")

  common_codes_translator <- function(col) {
    translator_from_tbl(
      common_codes %>% filter(CodeType == col),
      "CommonCode",
      "Description"
    )
  }
  stop_codes_translator <- function(col) {
    translator_from_tbl(
      stop_codes %>% filter(CodeType == col),
      "CommonCodeNumber",
      "Description"
    )
  }
  tr_race <- common_codes_translator("Race")
  tr_search_basis <- common_codes_translator("SearchBasis")
  tr_action <- stop_codes_translator("Action")
  tr_search_type <- stop_codes_translator("SearchType")
  tr_stop_purpose <- stop_codes_translator("StopPurpose")
  tr_county <- translator_from_tbl(
    r("county_codes.csv"),
    "county_id",
    "county_name"
  )

  print(nrow(stop))

  left_join(
    stop,
    search
  ) %>%
  left_join(
    person
  ) %>%
  left_join(
    group_by(
      search_basis,
      StopID,
      SearchID,
      PersonID
    ) %>%
    mutate(
      Basis = tr_search_basis[Basis]
    ) %>%
    summarize(
      Basis = str_c(Basis, collapse = ', ')
    )
  ) %>%
  left_join(
    contraband,
    by = c("StopID", "SearchID")
  ) %>%
  mutate(
    race_description = tr_race[Race],
    action_description = tr_action[Action],
    search_type_description = tr_search_type[Type], 
    stop_purpose_description = tr_stop_purpose[Purpose],
    county = tr_county[StopLocation]
  ) %>%
  bundle_raw(loading_problems)
}


clean <- function(d, calculated_features_path) {

  # TODO(phoebe): can we get reason_for_stop/search/contraband fields?
  #
  d$data %>%
    rename(
    ) %>%
    mutate(
    ) %>%
    # add_lat_lng(
    #   "incident_location",
    #   calculated_features_path
    # ) %>%
    standardize(d$metadata)
}
