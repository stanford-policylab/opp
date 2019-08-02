source(here::here("lib", "common.R"))
# NOTE: New Jersey uses sofware produced by LawSoft Inc.. There are two sets 
# of data: CAD (computer aided dispatch, recorded at the time of stop) and 
# RMS (record management system, recorded later). They have almost completely 
# disjoint fields, and only RMS records have information on searches. We 
# believe the data from the two systems should really be joined, but according 
# to the NJSP there is not a programmatic way to do so. Therefore, we process 
# the CAD data fully, which appear to be the dataset which corresponds to 
# traffic stops. We did noticed that you could join the RMS file if you combine 
# a few of the fields in a certain way. This method isn't perfect, and there 
# are lots of nulls; but we include it in hopes that some data is better than 
# no data.
# Becuase of the above, we only know search/frisk/contraband information in 
# about 13% of stops.
# Thus, we leave searches as NA rather than casting them to FALSE as we do in 
# other jurisdictions.

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
    "AS - ASIAN INDIAN" = "asian/pacific islander",
    "OA - OTHER ASIAN" = "asian/pacific islander",
    "AI - AMERICAN INDIAN" = "other",
    "UO - UNABLE TO OBSERVE" = "unknown",
    "NP - NOT PROVIDED" = "unknown",
    "UA - UNATTENDED" = "unknown" 
  )
  
  # NOTE: race and ethnicity conflict in about 1% of stops
  tr_ethnicity <- c(
    "White" = "white",
    "Black" = "black",
    "Hispanic / Latino" = "hispanic",
    "Asian Indian" = "asian/pacific islander",
    "Other Asian" = "asian/pacific islander",
    "American Indian" = "other",
    "Unknown" = "unknown"
  )
  
  tr_sex <- c(
    "M - MALE" = "male",
    "F - FEMALE" = "female"
  )

  # TODO(phoebe): can we get reason_for_stop/search/contraband fields?
  # https://app.asana.com/0/456927885748233/722133259228547
  d$data %>%
    add_raw_colname_prefix(
      RACE,
      Ethnicity,
      TOWNSHIP
    ) %>% 
    separate_cols(
      DATE_TIME = c("date", "time")
    ) %>%
    rename(
      officer_id = BADGE,
      department_id = UNIT,
      vehicle_color = VEH_COLOR,
      vehicle_make = VEH_MAKE,
      vehicle_model = VEH_MODEL,
      vehicle_registration_state = VEH_STATE,
      violation = STATUTE
    ) %>%
    mutate(
      date = parse_date(date, "%m/%d/%Y"),
      time = parse_time(time, "%I:%M:%S%p"),
      # TODO(jnu): Geocode locations.
      # https://app.asana.com/0/456927885748233/722133259228546
      location = str_c_na(LOCATION, raw_TOWNSHIP, sep = ", "),
      subject_race = fast_tr(raw_RACE, tr_race),
      # Since raw race and ethnicity columns agree most of the time, we
      # use ethnicity to populate race when race is NA
      subject_race = replace_na(fast_tr(raw_Ethnicity, tr_ethnicity)),
      subject_sex = fast_tr(GENDER, tr_sex),
      type = "vehicular"
    ) %>%
    group_by(
      `Case Number`
    ) %>%
    mutate(
      # NOTE(jnu): the state claimed there was no way to join the RMS and CAD files. 
      # But I noticed that you could join the files if you combine a few of the 
      # fields in a certain way. But this method isn't perfect, and there are lots of
      # nulls; we include it in hopes that some data is better than no data
      arrest_made = any(Arrested == "Y"),
      citation_issued = any(ACTION == "SUMMONS"),
      warning_issued = any(ACTION == "WARNING"),
      frisk_performed = any(Frisk == "Y"),
      search_conducted = any(Searched == "Y"),
      contraband_found = any(`Search Evid Seized` == "Y") | 
        any(`Frisk Evid Seized` == "Y"),
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
    ) %>%
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
