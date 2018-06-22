source("common.R")

load_raw <- function(raw_data_dir, n_max) {
  d <- load_single_file(
    raw_data_dir,
    "vsp_traffic_stops_20160218_public.csv",
    n_max = n_max,
    col_types = cols("Officer ID" = col_character())
  )
  bundle_raw(d$data, d$loading_problems)
}


clean <- function(d, helpers) {
  tr_search_type <- c(
    "SPC" = "probable cause",
    "SRS" = "consent",
    "SW" = "non-discretionary",
    # NOTE: Passenger searches conducted in Winooski don't specify a reason;
    # we assume they are based on probable cause.
    "_PSS" = "probable cause"
  )

  tr_race <- c(
    W = "white",
    B = "black",
    H = "hispanic",
    A = "asian/pacific islander",
    I = "other/unknown",
    X = "other/unknown",
    U = "other/unknown",
    N = "other/unknown"
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
      officer_id = `Officer ID`,
      department_name = `Agency Name`,
      reason_for_search = `Stop Search Description`,
      reason_for_stop = `Stop Reason Description`,
      subject_age = `Driver Age`
    ) %>%
    separate_cols(
      `Stop Date` = c("date", "time")
    ) %>%
    mutate(
      date = parse_date(date, "%m/%d/%Y"),
      time = parse_time(time, "%I:%M:%S%p"),
      type = "vehicular",
      location = str_c_na(
        `Stop Address`,
        `Stop City`,
        `Stop State`,
        `Stop Zip`,
        sep = ", "
      ),
      search_conducted = `Stop Search` != "NS",
      contraband_found = `Stop Contraband` == "C",
      search_type = tr_search_type[`Stop Search`],
      warning_issued = str_detect(`Stop Outcome`, "W|V"),
      citation_issued = str_detect(`Stop Outcome`, "T"),
      arrest_made = str_detect(`Stop Outcome`, "A|AW"),
      outcome = first_of(
        arrest = arrest_made,
        citation = citation_issued,
        warning = warning_issued
      ),
      subject_race = tr_race[`Driver Race`],
      subject_sex = tr_sex[`Driver Gender`]
    ) %>%
    # TODO(jnu): There are highway milemarkers such as `I 89 N; MM 87` in the
    # `Stop Address` field that have no `Stop City` or `Stop Zip`. We need
    # some special handling to get useful location / geocodes for these.
    # https://app.asana.com/0/456927885748233/701245052974374
    helpers$add_lat_lng(
    ) %>%
    standardize(d$metadata)
}
