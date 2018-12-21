source("common.R")


# VALIDATION: [YELLOW] This data is from a FOIA request directly to the Chicago
# Police Department. There is also local Chicago data in the statewide
# directory, but it has disparate schemas and organization; i.e. 2007 is
# consistent, but other years have the PD broken down into sub-PDs, i.e.
# University Police, Ridge Police, North Chicago Police, etc. Because of the
# difficulty in reconciling all those disparate data sources over years, we
# elected to use the data delivered directly from our city-level FOIA request
# here. The 2017 annual report has arrests by race for 2016 (pg. 83). The total
# number of arrests is stated as 85,752; we have 37,817 associated with traffic
# stops which seems reasonable. See TODOs for outstanding issues
load_raw <- function(raw_data_dir, n_max) {

  arrests <- load_single_file(raw_data_dir, "arrests.csv", n_max)
  citations <- load_single_file(raw_data_dir, "citations.csv", n_max)
  
  colnames(arrests$data) <- make_ergonomic(colnames(arrests$data))
  colnames(citations$data) <- make_ergonomic(colnames(citations$data))

  full_join(
    arrests$data,
    citations$data,
    by = c(
      "arrest_date" = "contact_date",
      "arrest_hour" = "time_of_day",
      "officer_first_name" = "officer_first_name",
      "officer_last_name" = "officer_last_name",
      "street_no" = "street_no",
      "street_name" = "street_name",
      "street_direction" = "street_direction"
    )
  ) %>%
  # NOTE: coalesce identical columns, preferring arrests to citations data
  left_coalesce_cols_by_suffix(
    ".x",
    ".y"
  ) %>%
  rename(
    # NOTE: this is both arrest_date and contact_date after the join
    date = arrest_date
  ) %>%
  bundle_raw(c(arrests$loading_problems, citations$loading_problems))
}


clean <- function(d, helpers) {

  tr_race = c(
    "AMER IND/ALASKAN NATIVE" = "other/unknown",
    "ASIAN/PACIFIC ISLANDER" = "asian/pacific islander",
    "BLACK" = "black",
    "HISPANIC" = "hispanic",
    "UNKNOWN" = "other/unknown",
    "WHITE" = "white"
  )

  d$data %>%
    rename(
      subject_age = age,
      violation = statute_description,
			officer_id = officer_employee_no
    ) %>%
    mutate(
      type = if_else(
        str_detect(violation, "PEDESTRIAN"),
        "pedestrian",
        "vehicular"
      ),
      time = parse_time(arrest_hour, "%H"),
      location = str_trim(
        str_c(
          street_no,
          street_name,
          street_direction,
          sep = " "
        )
      ),
      subject_race = fast_tr(coalesce(race, driver_race), tr_race),
      subject_sex = fast_tr(coalesce(gender, driver_gender), tr_sex),
      officer_race = fast_tr(officer_race, tr_race),
      officer_sex = fast_tr(officer_gender, tr_sex),
      arrest_made = !is.na(arrest_id),
      citation_issued = citation_i == "1",
      outcome = first_of(
        arrest = arrest_made,
        citation = citation_issued
      )
    ) %>%
    helpers$add_lat_lng(
    ) %>%
    standardize(d$metadata)
}
