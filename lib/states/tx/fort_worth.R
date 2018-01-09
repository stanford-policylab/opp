source("common.R")

load_raw <- function(raw_data_dir, geocodes_path) {
  data <- tibble()
	loading_problems <- list()
  r <- function(fname) {
    tbl <- read_csv(file.path(raw_data_dir, fname))
    loading_problems[[fname]] <<- problems(tbl)
    tbl
  }
  for (yr in 2006:2016) {
    data <- bind_rows(data, r(str_c(yr, '.csv')))
  }
  data <- add_lat_lng(data, "Address", geocodes_path)

	list(data = data, metadata = list(loading_problems = loading_problems))
}


# TODO(journalist): why do the numbers here decrease yoy?
# https://app.asana.com/0/456927885748233/519045240013551
clean <- function(d) {
  colnames(d$data) <- tolower(colnames(d$data))
  tr_race <- c(
    "Asian" = "asian/pacific islander",
    "Black" = "black",
    "Hispanic" = "hispanic",
    "Middle Eastern" = "other/unknown",
    "Native American/Eskimo" = "other/unknown",
    "Other" = "other/unknown",
    "Unknown" = "other/unknown",
    "White" = "white"
  )
  tr_knew_race = c(
    YES = TRUE,
    NO = FALSE,
    UNKNOWN = NA
  )
  tr_search_conducted = c(
    Yes = TRUE,
    No = FALSE,
    Unknown = NA
  )
  tr_search_consent = c(
    "Yes" = TRUE,
    "No" = FALSE,
    "N/A" = NA,
    "Unknown" = NA
  )
  tr_sex = c(
    "Female" = "female",
    "Male" = "male"
  )

  d$data %>%
    select(
      -x1  # dummy row index column
    ) %>%
    rename(
      incident_location = address,
      arrest_made = arrest,
      citation_issued = citation,
      subject_sex = sex,
      contraband_in_view = contraband_inview,
      reason_for_stop = reason,
      arrest_reason = arrestbasedon,
      street_type = streettype,
      offense_charged = offensecharged
    ) %>%
    mutate_each(
      funs(as.logical),
      arrest_made,
      citation_issued,
      city_resident,
      no_result,
      verbal_warning,
      city_ordinance,
      contraband_in_view,
      not_arrested,
      other_arrest_reason,
      penal_code,
      # TODO(journalist): what are these?
      # https://app.asana.com/0/456927885748233/519045240013551
      search_arrest,
      search_neither,
      search_towing,
      state_traffic_law,
      warrant
    ) %>%
    mutate(
      # TODO(ravi): can we assume this
      # https://app.asana.com/0/456927885748233/519045240013554 
      incident_type = ifelse(
        matches(reason_for_stop, "Traffic Violation"),
        "vehicular",
        "pedestrian"
      ),
      # NOTE: Hispanic ethnicity > race subdivision
      subject_race =
        tr_race[ifelse(ethnicity == "Hispanic", "Hispanic", race)],
      subject_sex = tr_sex[subject_sex],
      officer_knew_ethnicity_race_prior =
        tr_knew_race[officer_knew_ethnicity_race_prior],
      search_conducted = tr_search_conducted[search_conducted],
      search_consent = tr_search_consent[search_consent],
      incident_date = as.Date(stop_date),
      incident_time = format(as.POSIXct(stop_date), "%H:%M:%S"),
      warning_issued = verbal_warning,  # doesn't appear to be written_warning
      tmp_sr = tolower(search_reason),
      search_type = first_of(
        "plain view" = matches(tmp_sr, "plain sight|plain view"),
        "consent" = matches(tmp_sr, "consent"),
        "incident to arrest" = matches(tmp_sr, "arrest|warrant"),
        "probable cause" =  # default
          matches(tmp_sr, "probable|marijuana|furtive") | search_conducted
      ),
      incident_outcome = first_of(
        arrest = arrest_made,
        citation = citation_issued,
        warning = warning_issued
      )
    ) %>%
    select(
      -tmp_sr
    ) %>%
    standardize(d$metadata)
}
