source(here::here("lib", "common.R"))
# TODO: old opp ran StopCity through google geocoder to get county;
# at some point we should do the same

load_raw <- function(raw_data_dir, n_max) {
  d <- load_single_file(
    raw_data_dir,
    "vsp_traffic_stops_20160218_public.csv",
    n_max = n_max,
    col_types = cols("Officer ID" = col_character())
  )
  colnames(d$data) <- make_ergonomic(colnames(d$data))
  bundle_raw(d$data, d$loading_problems)
}


clean <- function(d, helpers) {
  tr_search_basis <- c(
    "SPC" = "probable cause",
    "SRS" = "consent",
    "SW" = "other",
    # NOTE: Passenger searches conducted in Winooski don't specify a reason;
    # we assume they are based on probable cause.
    "_PSS" = "probable cause"
  )
  
  tr_race <- c(
    W = "white",
    B = "black",
    H = "hispanic",
    A = "asian/pacific islander",
    I = "other",
    N = "other",
    X = "unknown",
    U = "unknown"
  )

  tr_outcome <- c(
    W = "warning",
    V = "warning",
    T = "citation",
    A = "arrest",
    AW = "arrest"
  )

  d$data %>%
    rename(
      department_name = agency_name,
      subject_age = driver_age
    ) %>%
    add_raw_colname_prefix(
      driver_race,
      driver_gender,
      stop_city,
      stop_reason_description,
      stop_search_description,
      stop_outcome_description
    ) %>% 
    separate_cols(
      stop_date = c("date", "time")
    ) %>%
    mutate(
      date = parse_date(date, "%m/%d/%Y"),
      time = parse_time(time, "%I:%M:%S%p"),
      type = "vehicular",
      location = str_c_na(
        stop_address,
        raw_stop_city,
        stop_state,
        stop_zip,
        sep = ", "
      ),
      # casts NA to search conducted FALSE
      search_conducted = stop_search != "NS" & !is.na(stop_search) 
      # if contraband_description specifies no search, then search is FALSE
        & (stop_contraband != "X" & !is.na(stop_contraband)),
      contraband_found = case_when(
        !search_conducted ~ NA,
        search_conducted & stop_contraband == "C" ~ T,
        TRUE ~ F
      ),
      search_basis = tr_search_basis[stop_search],
      warning_issued = str_detect(stop_outcome, "W|V"),
      citation_issued = str_detect(stop_outcome, "T"),
      arrest_made = str_detect(stop_outcome, "A|AW"),
      outcome = first_of(
        arrest = arrest_made,
        citation = citation_issued,
        warning = warning_issued
      ),
      subject_race = tr_race[raw_driver_race],
      subject_sex = tr_sex[raw_driver_gender]
    ) %>%
    # TODO: There are highway milemarkers such as `I 89 N; MM 87` in the
    # `Stop Address` field that have no `Stop City` or `Stop Zip`. We need
    # some special handling to get useful location / geocodes for these.
    # https://app.asana.com/0/456927885748233/701245052974374
    helpers$add_lat_lng(
    ) %>%
    standardize(d$metadata)
}
