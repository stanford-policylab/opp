source("common.R")


# VALIDATION: [YELLOW] Data prior to 2009 looks like it could be incomplete,
# and 2017 only has part of the year. The Madison PD's Annual Report doesn't
# seem to contain traffic figures, but it does contain calls for service, which
# are around 200k each year. Given there are around 30k warnings and citations
# each year, this seems reasonable.
load_raw <- function(raw_data_dir, n_max) {
  
  # Old data:
  # Date range: 09/28/2007 - 09/28/2017
  # NOTE: "IBM" is the officers department ID
  cit_old <- load_single_file(
    raw_data_dir,
    "mpd_traffic_stop_request_citations.csv",
    n_max
  )
  warn_old <- load_single_file(
    raw_data_dir,
    "mpd_traffic_stop_request_warnings.csv",
    n_max
  )
  
  # New data:
  # Date range: 01/01/2018 - 06/16/2020
  # Variables: missing IBM, added Age
  cit_new <- load_single_file(
    raw_data_dir,
    "elcis_with_demographics.csv",
    n_max
  )
  
  warn_new <- load_single_file(
    raw_data_dir,
    "warnings_with_demographics.csv",
    n_max
  )
  
  ## NOTE: The new data starts in Jan. 2018 
  ## and the old data covers through Sept. 2017, 
  ## so we're still missing Oct.-Dec. 2017
  bundle_raw(
    bind_rows(cit_old$data, warn_old$data,
              cit_new$data, warn_new$data),
    c(
      cit_old$loading_problems,
      warn_old$loading_problems,
      cit_new$loading_problems,
      warn_new$loading_problems
    )
  )
}


clean <- function(d, helpers) {
  
  # TODO(phoebe): can we get reason_for_stop/search/contraband data?
  # https://app.asana.com/0/456927885748233/595493946182539
  d$data %>%
    mutate(
      vehicle_registration_state = coalesce(`Reg State`, State),
      vehicle_year = coalesce(`Model Year`, Year),
    ) %>%
    merge_rows(
      Date,
      Time,
      onStreet,
      onStreetName,
      OfficerName,
      Race,
      Sex,
      Make,
      Model,
      vehicle_year,
      vehicle_registration_state,
      Limit,
      OverLimit,
      Type
    ) %>%
    rename(
      ticketed = Type, 
      violation = `Statute Description`,
      vehicle_make = Make,
      vehicle_model = Model,
      vehicle_color = Color,
      posted_speed = Limit,
      subject_age = Age, 
      time = Time
    ) %>%
    separate_cols(
      OfficerName = c("officer_last_name", "officer_first_name")
    ) %>%
    mutate(
      # OLD NOTE: Statute Descriptions are almost all vehicular, there are a few
      # pedestrian related Statute Descriptions, but it's unclear whether
      # the pedestrian or vehicle is failing to yield, but this represents a
      # quarter of a percent maximum
      # UPDATED NOTE: Similarly, there are a few pedestrian related Statute
      # Descriptions, but they are extremely infrequent (~ < a quarter of a percent)
      type = "vehicular",
      speed = as.integer(posted_speed) + as.integer(OverLimit),
      date = parse_date(Date, "%Y/%m/%d"),
      location = coalesce(onStreet, onStreetName),
      # logic: for old data, if ticket # is NA, it's a warning
      # for new data, if ticketed == "Warning", it's a warning
      # new data doesn't have ticket # var; old data doesn't have ticketed var
      # so if ticketed is NA and Ticket # is NA (i.e., from the old data), it's a warning
      # if ticketed == "Warning", it's a warning
      # if ticketed == "ELCI", its a ticket
      # if Ticket # is not NA, (i.e., from the new data and not a warning) it's a ticket
      # warning formula: ticketed == "Warning" OR (ticketed is NA & Ticket # is NA)
      warning_issued = case_when(
        ticketed == "Warning" ~ TRUE,
        is.na(ticketed) & is.na(`Ticket #`) ~ TRUE,
        # if anything else is the case, then its a ticket
        TRUE ~ FALSE
      ),
      citation_issued = !warning_issued,
      # TODO(phoebe): can we get arrests?
      # https://app.asana.com/0/456927885748233/595493946182543
      outcome = first_of(
        citation = citation_issued,
        warning = warning_issued
      ),
      # there are several thousand rows in the 
      # new data where race and sex are switched
      fixed_race = if_else(Race %in% c("M","F"), Sex, Race), 
      fixed_sex = if_else(Race %in% c("M","F"), Race, Sex), 
      subject_race = tr_race[fixed_race],
      subject_sex = tr_sex[fixed_sex],
    ) %>%
    helpers$add_lat_lng(
    ) %>%
    helpers$add_shapefiles_data(
    ) %>%
    # NOTE: shapefiles don't appear to include district 2 and accompanying
    # sectors
    rename(
      sector = Sector,
      district = District,
      raw_race = fixed_race
    ) %>%
    standardize(d$metadata)
}
