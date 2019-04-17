source("common.R")

# VALIDATION: [GREEN] While the numbers seem to be on the right order of
# magnitude, they don't clearly line up with the city report put out by the San
# Jose government; however, the racial breakdown does closely match that in
# "San Jose Police Department Traffic and Pedestrian Stop Study"
# TODO(phoebe): arrests for years 2014-2016 in our data are between 1.5k and 4k,
# but the "City of San Jose -- Annual Report on City Services 2016-17" says
# there were around 17k arrests for each of those year; is this not the
# universe of stops? It not, what are we missing?
# https://app.asana.com/0/456927885748233/945228590949547 
# NOTE: We have incomplete data for 2013 and 2018 (missing months)
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


clean <- function(d, helpers) {

  tr_race <- c(
    "H" = "hispanic",
    "W" = "white",
    "A" = "asian/pacific islander",
    "B" = "black",
    "O" = "other",
    "V" = "other",
    "S" = "other",
    "P" = "other",
    "N" = "other",
    "I" = "other",
    "C" = "other",
    "F" = "other",
    "Z" = "other",
    "M" = "other",
    "1" = "other",
    "2" = "other",
    "D" = "other",
    "U" = "other",
    "E" = "other",
    "X" = "other",
    "J" = "asian/pacific islander",
    "G" = "other",
    "Q" = "other",
    "0" = "other",
    "3" = "other",
    "5" = "other",
    "L" = "other",
    "4" = "other",
    "K" = "asian/pacific islander",
    "." = "other",
    "6" = "other",
    "a" = "other",
    "R" = "other",
    "w" = "white",
    "Y" = "other"
  )

  # NOTE: translations are found in raw_csv directory; for example:
  # detentions_oct_14_to_aug_17_sheet_1.csv
  tr_search <- c(
    "N" = FALSE, # no search
    "S" = TRUE,  # search, contraband_found
    "Z" = TRUE   # search, no contraband found 
  )

  tr_contraband <- c(
    "S" = TRUE,  # search, contraband_found
    "Z" = FALSE  # search, no contraband found 
  )

  tr_reason <- c(
    "B" = "BOL/APB/Watch Bulletin",
    "C" = "Consensual",
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

  # TODO(phoebe): what is `NUMBER OF STOPS`? and `DETENTION DISPO`?
  # https://app.asana.com/0/504031459709086/713013387495383
  # NOTE: search type may be included in the narrative, but this is
  # not a separate or searchable field in their database
  d$data %>%
    rename(
      time = `REPORT TIME (HMS)`,
      call_desc = `TYCOD DESCRIPTION`
    ) %>%
    mutate(
      type = if_else(
        str_detect(call_desc, vehicle_keywords),
        "vehicular",
        if_else(
          str_detect(call_desc, pedestrian_keywords),
          "pedestrian",
          NA_character_
        )
      ),
      date = parse_date(`REPORT DATE`, "%Y%m%d"),
      # NOTE: COMMONPLACE seems to be a name for places with addresses,
      # i.e. OVERFELT GARDENS, SAFEWAY, WALMART, etc...
      location = coalesce(
        ADDRESS,
        str_c(XSTREET1, XSTREET2, sep = " AND ")
      ),
      event_desc = tr_event[`EVENT DISPO`],
      arrest_made = str_detect(event_desc, "ARREST"),
      citation_issued = str_detect(event_desc, "CITATION"),
      # NOTE: there are other outcomes that don't fall into our schema of
      # warning, citation, and arrest, but aren't put into this factor
      outcome = first_of(
        "arrest" = arrest_made,
        "citation" = citation_issued
      ),
      reason_for_stop = tr_reason[`REASON FOR STOP`],
      subject_race = tr_race[RACE],
      # NOTE: assume NAs are "N" - No search
      search_conducted = tr_search[replace_na(SEARCH, "N")],
      contraband_found = tr_contraband[SEARCH],
      use_of_force_description = tr_force[`DETENTION TYPE`],
      use_of_force_reason = tr_force_reason[`DETENTION REASON`]
    ) %>%
    helpers$add_lat_lng(
    ) %>%
    merge_rows(
      date,
      time,
      location,
      subject_race,
      SEARCH
    ) %>%
    rename(
      raw_call_desc = call_desc,
      raw_event_desc = event_desc,
      raw_race = RACE,
      raw_search = SEARCH
    ) %>%
    standardize(d$metadata)
}
