source("lib/schema.R")

opp_load <- function() {
  arrests <- read_csv("data/states/il/chicago/arrests.csv",
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
      street_direction              = col_factor(NULL, include_na = TRUE),
      street_name                   = col_character(),
      statute                       = col_character(),
      statute_description           = col_character(),
      defendant_age                 = col_integer(),
      defendant_gender              = col_factor(NULL, include_na = TRUE),
      defendant_race                = col_factor(NULL, include_na = TRUE),
      officer_role                  = col_factor(NULL, include_na = TRUE),
      officer_employee_no           = col_integer(),
      officer_last_name             = col_character(),
      officer_first_name            = col_character(),
      officer_middle_initial        = col_character(),
      officer_gender                = col_factor(NULL, include_na = TRUE),
      officer_race                  = col_factor(NULL, include_na = TRUE),
      officer_age                   = col_integer(),
      officer_position              = col_character(),
      officer_years_of_service      = col_integer()
    ),
    skip = 1
  )

  citations <- read_csv("data/states/il/chicago/citations.csv",
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
      street_direction              = col_factor(NULL, include_na = TRUE),
      street_name                   = col_character(),
      statute                       = col_character(),
      statute_description           = col_character(),
      citation                      = col_integer(),
      driver_gender                 = col_factor(NULL, include_na = TRUE),
      driver_race                   = col_factor(NULL, include_na = TRUE),
      officer_last_name             = col_character(),
      officer_first_name            = col_character(),
      officer_gender                = col_factor(NULL, include_na = TRUE),
      officer_race                  = col_factor(NULL, include_na = TRUE),
      officer_position              = col_character(),
      officer_years_of_service      = col_integer()
    ),
    skip = 1
  )

  full_join(arrests, citations,
            by = c("arrest_date" = "contact_date",
                   "arrest_hour" = "time_of_day",
                   "officer_first_name" = "officer_first_name",
                   "officer_last_name" = "officer_last_name"))
}

opp_clean <- function(tbl) {
  tbl %>%
    rename(incident_date = arrest_date,
           )
           # arrest_id and contact_card_id have different ranges, so it's ok
    mutate(incident_id = coalesce(arrest_id, contact_card_id),
           # TODO(danj): use statute_description
           # does bicycle matter? traffic vs pedestrian vs vehicular
           incident_type = factor("vehicular", levels = valid_incident_types),
           incident_time = parse_time(arrest_hour, "%H"),
           incident_location = str_c(coalesce(street_no.x, street_no.y),
                                     coalesce(street_name.x, street_name.y),
                                     coalesce(street_direction.x,
                                              street_direction.y), sep = " "),
           # TODO(danj): get these
           incident_lat = NA,
           incident_lng = NA,
           defendant_race = coalesce(defendant_race, driver_race),
           statute = coalesce(statute.x, statute.y),
           statute_description = coalesce(statute_description.x,
                                          statute_description.y),
           driver_age = defendant_age,
           driver_gender = coalesce(defendant_gender, driver_gender),
           officer_gender = coalesce(officer_gender.x, officer_gender.y),
           officer_race = coalesce(officer_race.x, officer_race.y),
           officer_position = coalesce(officer_position.x,
                                       officer_position.y),
           officer_years_of_service = coalesce(officer_years_of_service.x,
                                               officer_years_of_service.y),
           arrest_made = !is.na(arrest_id),
           citation_issued = !is.na(citation)
          ) %>%
    select(outcome_citation,
           outcome_arrest,
           date,
           hour,
           street_no,
           street_name,
           street_direction,
           statute,
           statute_description,
           driver_age,
           driver_gender,
           driver_race,
           officer_first_name,
           officer_last_name,
           officer_gender,
           officer_race,
           officer_age,
           officer_position,
           officer_years_of_service)
}

opp_save <- function(tbl) {
}
