load_raw <- function(raw_data_dir, geocodes_path) {
  arrests <- read_csv(str_c(raw_data_dir, "arrests.csv"),
    col_names = c(
      "arrest_id",
      "arrest_date",
      "arrest_hour",
      "street_no",
      "street_direction",
      "street_name",
      "statute",
      "statute_description",
      "defendant_age",
      "defendant_gender",
      "defendant_race",
      "officer_role",
      "officer_employee_no",
      "officer_last_name",
      "officer_first_name",
      "officer_middle_initial",
      "officer_gender",
      "officer_race",
      "officer_age",
      "officer_position",
      "officer_years_of_service"
    ),
    col_types = cols(
      arrest_id                     = col_integer(),
      arrest_date                   = col_date(),
      arrest_hour                   = col_integer(),
      street_no                     = col_character(),
      street_direction              = col_character(),
      street_name                   = col_character(),
      statute                       = col_character(),
      statute_description           = col_character(),
      defendant_age                 = col_double(),
      defendant_gender              = col_character(),
      defendant_race                = col_character(),
      officer_role                  = col_character(),
      officer_employee_no           = col_integer(),
      officer_last_name             = col_character(),
      officer_first_name            = col_character(),
      officer_middle_initial        = col_character(),
      officer_gender                = col_character(),
      officer_race                  = col_character(),
      officer_age                   = col_double(),
      officer_position              = col_character(),
      officer_years_of_service      = col_integer()
    ),
    skip = 1
  )

  citations <- read_csv(str_c(raw_data_dir, "citations.csv"),
    col_names = c(
      "contact_card_id",
      "contact_date",
      "time_of_day",
      "street_no",
      "street_direction",
      "street_name",
      "statute",
      "statute_description",
      "citation",
      "driver_gender",
      "driver_race",
      "officer_last_name",
      "officer_first_name",
      "officer_gender",
      "officer_race",
      "officer_position",
      "officer_years_of_service"
    ),
    col_types = cols(
      contact_card_id               = col_integer(),
      contact_date                  = col_date(),
      time_of_day                   = col_integer(),
      street_no                     = col_character(),
      street_direction              = col_character(),
      street_name                   = col_character(),
      statute                       = col_character(),
      statute_description           = col_character(),
      citation                      = col_integer(),
      driver_gender                 = col_character(),
      driver_race                   = col_character(),
      officer_last_name             = col_character(),
      officer_first_name            = col_character(),
      officer_gender                = col_character(),
      officer_race                  = col_character(),
      officer_position              = col_character(),
      officer_years_of_service      = col_integer()
    ),
    skip = 1
  )

  # TODO(danj): verify that this join is sufficient, it's only hourly
  j <- full_join(arrests, citations,
                 by = c("arrest_date" = "contact_date",
                        "arrest_hour" = "time_of_day",
                        "officer_first_name" = "officer_first_name",
                        "officer_last_name" = "officer_last_name")
       ) %>%
       # NOTE: normally mutates are reserved for cleaning, but
       # here it's required to join to geolocation data
       mutate(incident_location = str_trim(str_c(coalesce(street_no.x,
                                                          street_no.y),
                                                 coalesce(street_name.x,
                                                          street_name.y),
                                                 coalesce(street_direction.x,
                                                          street_direction.y),
                                                 sep = " ")))

  add_lat_lng(j, "incident_location", geocodes_path)
}


clean <- function(tbl) {
  tr_race = c(
    "AMER IND/ALASKAN NATIVE" = "other/unknown",
    "ASIAN/PACIFIC ISLANDER" = "asian/pacific islander",
    "BLACK" = "black",
    "HISPANIC" = "hispanic",
    "UNKNOWN" = "other/unknown",
    "WHITE" = "white"
  )
  tr_sex = c(
    F = "female",
    M = "male"
  )

  # TODO(danj): write tibble coalescer
  # TODO(danj) write column combiner 
  tbl %>%
    rename(
      citation_issued = citation
    ) %>%
    mutate(
      incident_id = as.character(coalesce(arrest_id, contact_card_id)),
      # arrest_id and contact_card_id have different ranges, so it's ok
      incident_type = factor("vehicular", levels = valid_incident_types),
      incident_time = parse_time(arrest_hour, "%H"),
      street_no = coalesce(street_no.x, street_no.y),
      street_name = coalesce(street_name.x, street_name.y),
      street_direction = coalesce(street_direction.x, street_direction.y),
      defendant_race = factor(tr_race[coalesce(defendant_race,
                                               driver_race)],
                              levels = valid_races),
      statute = coalesce(statute.x, statute.y),
      statute_description = coalesce(statute_description.x,
                                     statute_description.y),
      defendant_sex = factor(tr_sex[coalesce(defendant_gender,
                                             driver_gender)],
                             levels = valid_sexes),
      defendant_age = sanitize_age(defendant_age),
      officer_sex = factor(tr_sex[coalesce(officer_gender.x,
                                           officer_gender.y)],
                           levels = valid_sexes),
      officer_race = factor(tr_race[coalesce(officer_race.x, officer_race.y)],
                            levels = valid_races),
      officer_age = sanitize_age(officer_age),
      officer_position = coalesce(officer_position.x,
                                  officer_position.y),
      officer_years_of_service = coalesce(officer_years_of_service.x,
                                          officer_years_of_service.y),
      search_conducted = as.logical(NA),
      search_type = factor(NA, levels = valid_search_types),
      contraband_found = as.logical(NA),
      arrest_made = !is.na(arrest_id),
      # NOTE: values 0, 1, and NA are coerced to logical T/F
      citation_issued = as.logical(citation_issued)
    ) %>%
    rename(
      incident_date = arrest_date,
      incident_lat = lat,
      incident_lng = lng,
      reason_for_stop = statute_description
    ) %>%
    replace_na(
      list(defendant_race = "unknown/other")
    ) %>%
    select(
      incident_id,
      incident_type,
      incident_date,
      incident_time,
      incident_location,
      incident_lat,
      incident_lng,
      defendant_race,
      reason_for_stop,
      search_conducted,
      search_type,
      contraband_found,
      arrest_made,
      citation_issued,
      street_no,
      street_name,
      street_direction,
      statute,
      defendant_age,
      defendant_sex,
      officer_employee_no,
      officer_first_name,
      officer_middle_initial,
      officer_last_name,
      officer_age,
      officer_sex,
      officer_race,
      officer_role,
      officer_position,
      officer_years_of_service
    )
}
