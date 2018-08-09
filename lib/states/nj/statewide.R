source("common.R")

load_raw <- function(raw_data_dir, n_max) {
  d_cad <- load_regex(raw_data_dir, "cad20\\d{2}.csv", n_max = n_max)
  d_rms <- load_regex(raw_data_dir, "rms20\\d{2}.csv", n_max = n_max)
  
  # Translator for joining on INVOLVEMENT.
  tr_involve <- c(
    D = "DRIVER",
    P = "OCCUPANT"
  )

  d_cad$data %>%
    # CAD files contain witness, victim, etc. info; ignore that.
    filter(
      INVOLVEMENT %in% c("DRIVER", "OCCUPANT")
    ) %>%
    distinct(
    ) %>%
    # Formulate a `Case Number` to join with RMS data.
    mutate(
      `Case Number` = str_c(
        UNIT,
        str_replace(
          CAD_INCIDENT,
          "^[A-Z]\\d{3}/(\\d{4})-(\\d{8})",
          "\\1\\2"
        )
      )
    ) %>%
    left_join(
      distinct(d_rms$data) %>%
        mutate(INVOLVEMENT = tr_involve[`Driver Passenger`])
    ) %>%
    bundle_raw(c(d_cad$loading_problems, d_rms$loading_problems))
}


clean <- function(d, helpers) {
  
  tr_race <- c(
    "W - WHITE" = "white",
    "B - BLACK" = "black",
    "H - HISPANIC" = "hispanic",
    "AS - ASIAN INDIAN" = "asian/pacfic islander",
    "OA - OTHER ASIAN" = "asian/pacific islander",
    "AI - AMERICAN INDIAN" = "other/unknown",
    "UO - UNABLE TO OBSERVE" = "other/unknown",
    "NP - NOT PROVIDED" = "other/unknown",
    "UA - UNATTENDED" = "other/unknown" 
  )

  tr_sex <- c(
    "M - MALE" = "male",
    "F - FEMALE" = "female"
  )

  # TODO(phoebe): can we get reason_for_stop/search/contraband fields?
  # https://app.asana.com/0/456927885748233/722133259228547
  d$data %>%
    separate_cols(
      DATE_TIME = c("date", "time")
    ) %>%
    rename(
      officer_id = BADGE,
      department_id = UNIT,
      vehicle_color = VEH_COLOR,
      vehicle_make = VEH_MAKE,
      vehicle_model = VEH_MODEL,
      vehicle_registration_state = VEH_STATE
    ) %>%
    mutate(
      date = parse_date(date, "%m/%d/%Y"),
      time = parse_time(time, "%I:%M:%S%p"),
      # TODO(jnu): Geocode locations.
      # https://app.asana.com/0/456927885748233/722133259228546
      location = str_c_na(LOCATION, TOWNSHIP, sep = ", "),
      subject_race = tr_race[RACE],
      subject_sex = tr_sex[GENDER],
      type = "vehicular"
    ) %>%
    group_by(
      `Case Number`
    ) %>%
    mutate(
      arrest_made = any(Arrested == "Y"),
      citation_issued = any(ACTION == "SUMMONS"),
      warning_issued = any(ACTION == "WARNING"),
      frisk_performed = any(Frisk == "Y"),
      search_conducted = any(Searched == "Y"),
      has_driver = any(INVOLVEMENT == "DRIVER")
    ) %>%
    # NOTE: Data are grouped by stop ID; rows represent individuals. We need
    # to reduce the group to a single row representing the stop. Choose a
    # driver row for this if there is one; otherwise any row will do.
    filter(
      !has_driver | INVOLVEMENT == "DRIVER"
    ) %>%
    slice(
      1
    )
    ungroup(
    ) %>%
    mutate(
      outcome = first_of(
        arrest = arrest_made,
        citation = citation_issued,
        warning = warning_issued
      )
    ) %>%
    standardize(d$metadata)
}
