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
  person <- r("person.csv")
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

  # NOTE: D is Driver and P is Passenger, see refcommoncode.csv;
  # drop Type as well, since it's now useless and Type in search.csv
  # corresponds to search type, which we want to keep
  only_drivers <- person %>% filter(Type == "D") %>% select(-Type)
  collapsed_search_basis <- group_by(
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
  
  # NOTE: the only major caveat with the following data is that the search,
  # search basis, and contraband associated with each stop could be from a
  # Driver or a Passenger (~3.6% of cases), even though we use the Driver for
  # demographic information like race, sex, age, etc

  # NOTE: there is a 1:N correspondence between StopID and PersonID,
  # so we filtered out passengers above to prevent duplicates
  left_join(
    stop,
    only_drivers
  ) %>%
  # NOTE: by not joining search also on PersonID, we are getting the search
  # associated with whomever was searched, Driver or Passenger; curiously,
  # with this data, there is a 1:1 correspondence between StopID and SearchID,
  # (as well as between SearchID and PersonID) meaning that only the Driver or
  # Passenger is associated with the SearchID, even though this has no bearing
  # on DriverSearched and PassengerSearched fields in the search table:
  #
  # SearchID:StopID is 1:1 -->
  # group_by(search, SearchID, StopID) %>% count %>% nrow == nrow(search)
  #
  # j <- group_by(left_join(select(search, -Type), person)
  #
  # SearchID:PersonID is 1:1 -->
  # group_by(j, SearchID, PersonID) %>% count %>% nrow == nrow(search)
  #
  # DriverSearched and PassengerSearched don't depend on whether the PersonID
  # associated with the SearchID was a Driver or Passenger -->
  # group_by(j, Type, DriverSearch, PersonSearch) %>% count
  left_join(
    search,
    by = c("StopID")
  ) %>%
  # NOTE: again, not joining also on PersonID here because the search basis is
  # associated with whomever was searched, Driver or Passenger, and here we are
  # focusing on only the Drivers to remove duplicates; so this will be the
  # search basis associated with the SearchID above:
  #
  # There are not multiple people associated with each <StopID,SearchID> -->
  # group_by(search_basis, StopID, SearchID, PersonID) %>% count %>% nrow
  # == group_by(search_basis, StopID, SearchID) %>% count %>% nrow
  #
  # There are, however, multiple SearchBasisIDs per <StopID,SearchID>, so
  # we collapsed those above
  left_join(
    collapsed_search_basis,
    by = c("StopID", "SearchID")
  ) %>%
  # NOTE: same reasoning as above, except there is only one ContrabandID per
  # <StopID, SearchID> -->
  # group_by(contraband, StopID, SearchID) %>% count %>% nrow
  # == group_by(contraband, StopID, SearchID, ContrabandID) %>% count %>% nrow
  left_join(
    contraband,
    by = c("StopID", "SearchID")
  ) %>%
  # mutate(
  #   race_description = tr_race[Race],
  #   action_description = tr_action[Action],
  #   search_type_description = tr_search_type[Type], 
  #   stop_purpose_description = tr_stop_purpose[Purpose],
  #   county = tr_county[StopLocation]
  # ) %>%
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
