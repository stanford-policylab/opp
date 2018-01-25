source("common.R")

load_raw <- function(raw_data_dir, n_max) {

  loading_problems <- list()
  data <- tibble()
  for (yr in 2006:2016) {
    fname <- str_c(yr, ".csv")
    tbl <- read_csv(file.path(raw_data_dir, fname), n_max = n_max)
    loading_problems[[fname]] <- problems(tbl)
    data <- bind_rows(data, tbl)
    if (nrow(data) > n_max) {
      data <- data[1:n_max, ]
      break
    }
  }

  data <- mutate(data, incident_id = seq_len(n()))
	list(data = data, metadata = list(loading_problems = loading_problems))
}


# TODO(journalist): why do the numbers here decrease yoy?
# https://app.asana.com/0/456927885748233/519045240013551
clean <- function(d, calculated_features_path) {

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
  tr_sex = c(
    "Female" = "female",
    "Male" = "male"
  )

  d$data %>%
    add_lat_lng(
      "Address",
      calculated_features_path
    ) %>%
    add_contraband_types(
      "Contraband_Type",
      calculated_features_path
    ) %>%
    rename(
      incident_date = Stop_Date,
      incident_location = Address,
      contraband_found = Contraband_Found,
      arrest_made = Arrest,
      citation_issued = Citation,
      warning_issued = Verbal_Warning,  # no written_warning or other type
      subject_sex = Sex,
      reason_for_stop = Reason
    ) %>%
    mutate_each(
      funs(as.logical),
      contraband_found,
      arrest_made,
      citation_issued,
      warning_issued
    ) %>%
    mutate(
      # TODO(ravi): can we assume this
      # https://app.asana.com/0/456927885748233/519045240013554 
      incident_type = ifelse(
        matches(reason_for_stop, "Traffic Violation"),
        "vehicular",
        "pedestrian"
      ),
      incident_time = format(as.POSIXct(Stop_Date), "%H:%M:%S"),
      incident_outcome = first_of(
        arrest = arrest_made,
        citation = citation_issued,
        warning = warning_issued
      ),
      # NOTE: Hispanic ethnicity > race subdivision
      subject_race =
        tr_race[ifelse(Ethnicity == "Hispanic", "Hispanic", Race)],
      subject_sex = tr_sex[subject_sex],
      search_conducted = tr_search_conducted[Search_Conducted],
      tmp_sr = tolower(Search_reason),
      search_type = first_of(
        "plain view" = matches(tmp_sr, "plain sight|plain view"),
        "consent" = matches(tmp_sr, "consent"),
        "incident to arrest" = matches(tmp_sr, "arrest|warrant"),
        "probable cause" =  # default
          matches(tmp_sr, "probable|marijuana|furtive") | search_conducted
      ),
      notes = str_combine_cols(
        Search_reason, ArrestBasedOn,
        "Search Reason", "Arrest Reason"
      )
    ) %>%
    # extra_schema
    standardize(d$metadata)
}
