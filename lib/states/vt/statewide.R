source("common.R")

load_raw <- function(raw_data_dir, n_max) {
  loading_problems <- list()
  fname <- file.path(raw_data_dir, "vsp_traffic_stops_20160218_public_sheet1.csv")
  data <- read_csv(fname,
                   n_max = n_max,
                   col_types = cols("Officer ID" = col_character()))
  loading_problems[[fname]] <- problems(data)
  bundle_raw(data, loading_problems)
}


clean <- function(d, helpers) {
  # Normalization for search types
  tr_search_type <- c(
    NS = NA,
    SPC = "probable cause",
    # NOTE: SRS is a "reasonable suspicion" consent search.
    SRS = "consent",
    SW = "non-discretionary",
    # NOTE: Passenger search conducted in Winooski don't specify the specific
    # reason; we assume they are based on probable cause.
    `_PSS` = "probable cause"
  )

  # Normalization for race
  tr_vt_race <- c(
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
    `T` = "citation",
    # Arrest for violation
    A = "arrest",
    # Arrest on warrant
    AW = "arrest",
    # No action
    N = NA
  )

  d$data %>%
    rename(
      officer_id = `Officer ID`,
      department_name = `Agency Name`,
      reason_for_search = `Stop Search Description`,
      reason_for_stop = `Stop Reason Description`,
      subject_age = `Driver Age`
    ) %>%
    separate(`Stop Date`, c("incident_date", "incident_time"), "\\s+") %>%
    unite("incident_location_dirty", `Stop Address`, `Stop City`, `Stop State`, `Stop Zip`, sep = ", ") %>%
    mutate(
      incident_date = parse_date(incident_date, "%m/%d/%Y"),
      incident_time = parse_time(incident_time, "%I:%M:%S%p"),
      incident_type = "vehicular",
      # TODO(jnu): There are highway milemarkers such as `I 89 N; MM 87` in the
      # `Stop Address` field that have no `Stop City` or `Stop Zip`. We need
      # some special handling to get useful location / geocodes for these.
      # https://app.asana.com/0/456927885748233/701245052974374
      incident_location = gsub(", NA", "", incident_location_dirty),
      search_conducted = `Stop Search` != "NS",
      contraband_found = `Stop Contraband` == "C",
      search_type = tr_search_type[`Stop Search`],
      warning_issued = str_detect("(W|V)", `Stop Outcome`),
      citation_issued = str_detect("T", `Stop Outcome`),
      arrest_made = str_detect("(A|AW)", `Stop Outcome`),
      incident_outcome = first_of(
        arrest = arrest_made,
        citation = citation_issued,
        warning = warning_issued
      ),
      subject_race = tr_vt_race[`Driver Race`],
      subject_sex = tr_sex[`Driver Gender`]
    ) %>%
    helpers$add_lat_lng(
    ) %>%
    standardize(d$metadata)
}
