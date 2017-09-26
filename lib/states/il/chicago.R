opp_load <- function() {
  arrests <- read_csv("data/states/il/chicago_arrests.csv",
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
      officer_position              = col_factor(NULL, include_na = TRUE),
      officer_years_of_service      = col_integer()
    ),
    skip = 1
  )

  citations <- read_csv("data/states/il/chicago_citations.csv",
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
      officer_position              = col_factor(NULL, include_na = TRUE),
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
}

opp_save <- function(tbl) {
}
