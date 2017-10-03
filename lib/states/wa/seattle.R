source("lib/schema.R")

opp_load <- function() {
  tbls <- list()
  # for (year in 2006:2015) {
  for (year in 2006:2006) {
    filename = str_c("data/states/wa/seattle/trafs_evs_", year, "_sheet_1.csv")
    tbls[[length(tbls) + 1]] <- read_csv(filename,
      col_names = c(
        "rin",
        "datetime",
        "address",
        "type",
        "pri",
        "mir_and_description",
        "disposition_description",
        "veh",
        "possible_race_and_sex",
        "subject_dob",
        "officer_no_name_1",
        "officer_no_name_2",
        "empty"
      ),
      col_types = cols(
        rin                         = col_character(),
        datetime                    = col_datetime("%Y/%m/%d %H:%M:%S"),
        address                     = col_character(),
        type                        = col_character(),
        pri                         = col_integer(),
        mir_and_description         = col_character(),
        disposition_description     = col_character(),
        veh                         = col_character(),
        possible_race_and_sex       = col_character(),
        subject_dob                 = col_character(),
        officer_no_name_1           = col_character(),
        officer_no_name_2           = col_character(),
        empty                       = col_character()
      ),
      skip = 1
    )
  }
  tbls[[1]]
  # bind_rows(tbls)
}

opp_clean <- function(tbl) {
  # yn_to_tf <- c(Y = TRUE, N = FALSE)
  # tbl %>%
  #   separate(stop_datetime, c("date", "time"), sep = " ", extra = "merge") %>%
  #   mutate(date = parse_date(date, "%m/%d/%Y"),
  #          time = parse_time(time, "%I:%M:%S %p"),
  #          county_resident = yn_to_tf[county_resident],
  #          verbal_warning_issued = yn_to_tf[verbal_warning_issued],
  #          written_warning_issued = yn_to_tf[written_warning_issued],
  #          traffic_citation_issued = yn_to_tf[traffic_citation_issued],
  #          misd_state_citation_issued = yn_to_tf[misd_state_citation_issued],
  #          custodial_arrest_issued = yn_to_tf[custodial_arrest_issued],
  #          action_against_driver = yn_to_tf[action_against_driver],
  #          search_occurred = yn_to_tf[search_occured],
  #          evidence_seized = yn_to_tf[evidence_seized],
  #          drugs_seized = yn_to_tf[drugs_seized],
  #          weapons_seized = yn_to_tf[weapons_seized],
  #          other_seized = yn_to_tf[other_seized],
  #          vehicle_searched = yn_to_tf[vehicle_searched],
  #          pat_down_search = yn_to_tf[pat_down_search],
  #          driver_searched = yn_to_tf[driver_searched],
  #          passenger_searched = yn_to_tf[passenger_searched],
  #          search_consent = yn_to_tf[search_consent],
  #          search_probable_cause = yn_to_tf[search_probable_cause],
  #          search_arrest = yn_to_tf[search_arrest],
  #          search_warrant = yn_to_tf[search_warrant],
  #          search_inventory = yn_to_tf[search_inventory],
  #          search_plain_view = yn_to_tf[search_plain_view])
  tbl
}


opp_save <- function(tbl) {
}
