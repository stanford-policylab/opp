source("common.R")

load_raw <- function(raw_data_dir, n_max) {
  d_cad <- load_regex(raw_data_dir, "cad20\\d{2}.csv", n_max = n_max)
  d_rms <- load_regex(raw_data_dir, "rms20\\d{2}.csv", n_max = n_max)
  
  # Translator for joining on INVOLVEMENT.
  tr_involve <- c(
    D = "DRIVER",
    P = "OCCUPANT"
  )

  joined <- d_cad$data %>%
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
      d_rms$data %>%
        distinct(
        ) %>%
        mutate(
          INVOLVEMENT = tr_involve[`Driver Passenger`]
        )
    )

  bundle_raw(joined, c(d_cad$loading_problems, d_rms$loading_problems))
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
    group_by(
      `Case Number`
    ) %>%
    rename(
      officer_id = BADGE,
      department_id = UNIT
    ) %>%
    separate_cols(
      `DATE_TIME` = c("date", "time")
    ) %>%
    mutate(
      date = mdy(date),
      time = parse_time(time, "%I:%M:%S%p"),
      # TODO(jnu): Geocode locations.
      # https://app.asana.com/0/456927885748233/722133259228546
      location = str_c_na(
        LOCATION,
        TOWNSHIP,
        "NJ",
        sep = ", "
      ),
      subject_race = tr_race[RACE],
      subject_sex = tr_sex[GENDER],
      type = "vehicular",
      arrest_made = any(Arrested == "Y"),
      citation_issued = any(ACTION == "SUMMONS"),
      warning_issued = any(ACTION == "WARNING"),
      outcome = first_of(
        arrest = arrest_made,
        citation = citation_issued,
        warning = warning_issued
      ),
      frisk_performed = any(Frisk == "Y"),
      search_conducted = any(Searched == "Y"),
      vehicle_color = VEH_COLOR,
      vehicle_make = VEH_MAKE,
      vehicle_model = VEH_MODEL,
      vehicle_registration_state = VEH_STATE,
      tmp.has_driver = any(INVOLVEMENT == "DRIVER")
    ) %>%
    # NOTE: Data are grouped by stop ID; rows represent individuals. Try to
    # take the first driver row for each stop. A few stops don't have a row
    # for the driver, in which case select arbitrarily the first row.
    filter(
      !tmp.has_driver | INVOLVEMENT == "DRIVER"
    ) %>%
    filter(
      row_number() == 1
    ) %>%
    standardize(d$metadata)
}
