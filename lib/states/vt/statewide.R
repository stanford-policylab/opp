source("common.R")

load_raw <- function(raw_data_dir, n_max) {
  loading_problems <- list()
  fname <- "vsp_traffic_stops_20160218_public"
  data <- read_csv(
    file.path(raw_data_dir, str_c(fname, "_sheet1.csv")),
    n_max = n_max,
    col_types = cols("Officer ID" = col_character())
  )
  loading_problems[[fname]] <- problems(data)
  bundle_raw(data, loading_problems)
}


clean <- function(d, helpers) {
  # Normalization for search types
  tr_search_type <- c(
    SPC = "probable cause",
    # "reasonable suspicion" consent search.
    SRS = "consent",
    # Search based on warrant
    SW = "non-discretionary",
    # NOTE: Passenger searches conducted in Winooski don't specify a reason;
    # we assume they are based on probable cause.
    `_PSS` = "probable cause"
  )

  # Normalization for race
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

  # Normalization for stop outcome
  tr_outcome <- c(
    # Written warning
    W = "warning",
    # Verbal warning
    V = "warning",
    # Ticket / VCVC
    T = "citation",
    # Arrest for violation
    A = "arrest",
    # Arrest on warrant
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
    separate_cols(`Stop Date` = c("incident_date", "incident_time")) %>%
    mutate(
      incident_date = parse_date(incident_date, "%m/%d/%Y"),
      incident_time = parse_time(incident_time, "%I:%M:%S%p"),
      incident_type = "vehicular",
      incident_location = str_c_na(
        `Stop Address`,
        `Stop City`,
        `Stop State`,
        `Stop Zip`,
        sep = ", "
      ),
      search_conducted = `Stop Search` != "NS",
      contraband_found = `Stop Contraband` == "C",
      search_type = tr_search_type[`Stop Search`],
      warning_issued = str_detect("W|V", `Stop Outcome`),
      citation_issued = str_detect("T", `Stop Outcome`),
      arrest_made = str_detect("A|AW", `Stop Outcome`),
      incident_outcome = first_of(
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
