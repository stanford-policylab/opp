source("common.R")

load_raw <- function(raw_data_dir, n_max) {
  data <- tibble()
  loading_problems <- list()
  # NOTE: the first sheet of each contains the schema
  load <- function(fname_prefix, n_sheets) {
    for (i in 2:n_sheets) {
      fname <- str_c(fname_prefix, "_sheet_", i, ".csv")
      tbl <- read_csv(file.path(raw_data_dir, fname))
      loading_problems[[fname]] <<- problems(tbl)
      data <<- bind_rows(data, tbl)
      if (nrow(data) > n_max) {
        data <- data[1:n_max, ]
        break
      }
    }
  }
  load("detentions_oct_14_to_aug_17", 36)
  load("detentions_sept_13_to_sept_14", 15)
  load("detentions_sept_17_to_march_18", 8)
  bundle_raw(data, loading_problems)
}


clean <- function(d, calculated_features_path) {

  tr_race <- c(
    "H" = "hispanic",
    "W" = "white",
    "A" = "asian/pacific islander",
    "B" = "black",
    "O" = "other/unknown",
    "V" = "other/unknown",
    "S" = "other/unknown",
    "P" = "other/unknown",
    "N" = "other/unknown",
    "I" = "other/unknown",
    "C" = "other/unknown",
    "F" = "other/unknown",
    "Z" = "other/unknown",
    "M" = "other/unknown",
    "1" = "other/unknown",
    "2" = "other/unknown",
    "D" = "other/unknown",
    "U" = "other/unknown",
    "E" = "other/unknown",
    "X" = "other/unknown",
    "J" = "other/unknown",
    "G" = "other/unknown",
    "Q" = "other/unknown",
    "0" = "other/unknown",
    "3" = "other/unknown",
    "5" = "other/unknown",
    "L" = "other/unknown",
    "4" = "other/unknown",
    "K" = "other/unknown",
    "." = "other/unknown",
    "6" = "other/unknown",
    "a" = "other/unknown",
    "R" = "other/unknown",
    "w" = "white",
    "Y" = "other/unknown"
  )

  tr_search <- c(
    "N" = FALSE, # no search
    "S" = TRUE,  # search, contraband_found
    "Z" = TRUE   # search, no contraband found 
  )

  tr_contraband <- c(
    "S" = TRUE, # search, contraband_found
    "Z" = FALSE   # search, no contraband found 
  )

  tr_reason <- c(
    "B" = "BOL/APB/Watch Bulletin",
    "C" = "Consensual ",
    "M" = "Muni Code Violation",
    "P" = "Penal code, H&S, B&P violations, etc.",
    "V" = "Vehicle Code Violation"
  )

  tr_event <- c(
    "A" = "ARREST MADE",
    "B" = "ARREST BY WARRANT",
    "C" = "CRIMINAL CITATION",
    "D" = "TRAFFIC CITATION ISSUED; HAZARDOUS VIOLATION",
    "E" = "TRAFFIC CITATION ISSUED; NON-HAZARDOUS VIOLATION",
    "F" = "FIELD INTERVIEW COMPLETED",
    "G" = "GONE ON ARRIVAL/UNABLE TO LOCATE (N/A FOR CAR STOPS)",
    "H" = "COURTESY SERVICE/CITIZEN OR AGENCY ASSIST",
    "M" = "STRANDED MOTORIST ASSIST",
    "N" = "NO REPORT REQUIRED; DISPATCH RECORD ONLY",
    "O" = "REPORT, OTHER THAN PRIMARY REPORT, IS FILED",
    "P" = "PRIOR CASE, FOLLOW-UP ACTIVITY ONLY",
    "R" = "PRIMARY REPORT TAKEN (FILED)",
    "T" = "TURNED OVER TO",
    "U" = "UNFOUNDED EVENT"
  )

  vehicle_keywords <- str_c(
    "CAR STOP",
    "DRIV",
    "DUI",
    "HIT AND RUN",
    "REGISTRATION",
    "SPEED",
    "VEHICLE",
    sep = "|"
  )

  pedestrian_keywords <- str_c(
    "DRUNK",
    "FOOT PATROL",
    "NARCOTICS",
    "PEDESTRIAN",
    "POSSESSION",
    "PROSTITUTION",
    "SUSPICIOUS PERSON",
    "USE OF CONTROLLED SUBSTANCE",
    sep = "|"
  )

  tr_force <- c(
    "H" = "handcuffed",
    "N" = "no curb, no handcuff, no police vehicle",
    "V" = "sat in police vehicle"
  )

  tr_force_reason <- c(
    "M" = "medical condition",
    "N" = "no curb, no handcuff, no police vehicle",
    "O" = "other",
    "P" = "safety concern during prior contact(s)",
    "S" = "officer safety concerns",
    "W" = "weapons / violence related event"
  )

  # TODO(ravi): this has interesting variables -- handcuffed as part of
  # DETENTION TYPE / DETENTION REASON -- can we do anything with this?
  # https://app.asana.com/0/456927885748233/649920459235534

  # TODO(phoebe): can we get search_type?
  # https://app.asana.com/0/456927885748233/649920459235535
  d$data %>%
    rename(
      call_desc = `TYCOD DESCRIPTION`
    ) %>%
    filter(
      str_detect(
        call_desc,
        str_c(vehicle_keywords, pedestrian_keywords, sep = "|")
      ),
      !str_detect(
        call_desc,
        str_c(
          "STOLEN",
          "ABANDONED",
          "BURGLARY",
          sep = "|"
        )
      )
    ) %>%
    mutate(
      incident_type = ifelse(
        str_detect(call_desc, vehicle_keywords),
        "vehicular",
        "pedestrian"
      ),
      incident_date = parse_date(`REPORT DATE`, "%Y%m%d"),
      incident_time_period = seconds_to_period(`REPORT TIME (HMS)`),
      incident_time = seconds_to_hms(`REPORT TIME (HMS)`),
      # NOTE: COMMONPLACE seems to be a name for places with addresses,
      # i.e. OVERFELT GARDENS, SAFEWAY, WALMART, etc...
      incident_location = coalesce(
        ADDRESS,
        str_c(XSTREET1, XSTREET2, sep = " AND ")
      ),
      event_desc = tr_event[`EVENT DISPO`],
      # TODO(ravi): should we filter out the other outcomes?
      # https://app.asana.com/0/456927885748233/649920459235533
      incident_outcome = first_of(
        "arrest" = str_detect(event_desc, "ARREST"),
        "citation" = str_detect(event_desc, "CITATION")
      ),
      reason_for_stop = tr_reason[`REASON FOR STOP`],
      subject_race = tr_race[RACE],
      search_conducted = tr_search[SEARCH],
      contraband_found = tr_contraband[SEARCH],
      use_of_force_description = tr_force[`DETENTION TYPE`],
      use_of_force_reason = tr_force_reason[`DETENTION REASON`]
    ) %>%
    add_lat_lng(
      "incident_location",
      calculated_features_path
    ) %>%
    standardize(d$metadata)
}
