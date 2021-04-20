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
# stops which seems reasonable.

load_raw <- function(raw_data_dir, n_max) {

  arrests <- load_single_file(raw_data_dir, "arrests.csv", n_max)
  citations <- load_single_file(raw_data_dir, "citations.csv", n_max)

  colnames(arrests$data) <- make_ergonomic(colnames(arrests$data))
  colnames(citations$data) <- make_ergonomic(colnames(citations$data))

  old_d <- full_join(
    mutate(arrests$data, arrest_made = T),
    mutate(citations$data, citation_issued = T),
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
    mutate(source = "old_data")

  tsss_1 <- load_single_file(
    raw_data_dir,
    "15327-p580999-traffic-isr_sheet_3.csv",
    n_max
  )
  tsss_2 <- load_single_file(
    raw_data_dir,
    "15327-p580999-traffic-isr_sheet_4.csv",
    n_max
  )
  tsss_1$data <- make_ergonomic_colnames(tsss_1$data)
  tsss_2$data <- make_ergonomic_colnames(tsss_2$data)

  new_d <- bind_rows(tsss_1$data, tsss_2$data) %>%
    distinct() %>%
    mutate(source = "new_data")

  bundle_raw(
    bind_rows(old_d, new_d),
    c(arrests$loading_problems, citations$loading_problems,
      tsss_1$loading_problems, tsss_2$loading_problems)
  )

}

clean <- function(d, helpers) {
  tr_race = c(
    "AMER IND/ALASKAN NATIVE" = "other",
    "ASIAN/PACIFIC ISLANDER" = "asian/pacific islander",
    "BLACK" = "black",
    "HISPANIC" = "hispanic",
    "UNKNOWN" = "unknown",
    "WHITE" = "white"
  )

  d$data %>%
    # date, time,
    separate(contactdate, into=c("date_new","time_new"), sep=" ") %>%
    mutate(
      date = if_else(
        source == "old_data",
        date(ymd(date)),
        date(dmy(date_new))
      ),
      time = if_else(
        source == "old_data",
        parse_time(arrest_hour, "%H"),
        parse_time(time_new)
      )
    ) %>%
    # location, county, beat, district,
    mutate(
      location = if_else(
        source == "old_data",
        str_c(street_no, street_name, street_direction, sep = " "),
        str_c(street_no, dir, street_nme, sep = " ")
      ),
      county = "Cook County"
    ) %>%
    # subject_age, subject_race, subject_sex
    mutate(
      subject_age = if_else(
        source == "old_data",
        as.numeric(age),
        year(date) - as.numeric(year_of_birth)
      ),
      subject_race = if_else(
        source == "old_data",
        fast_tr(coalesce(race, driver_race), tr_race),
        fast_tr(race, tr_race)
      ),
      subject_sex = if_else(
        source == "old_data",
        fast_tr(coalesce(gender, driver_gender), tr_sex),
        fast_tr(sex, tr_sex)
      )
    ) %>%
    # officer vars
    rename(officer_id = officer_employee_no) %>%
    mutate(
      officer_race = fast_tr(officer_race, tr_race),
      officer_sex = fast_tr(officer_gender, tr_sex)
    ) %>%
    # unit, type, violation
    rename(unit = cpd_unit_no) %>%
    mutate(
      violation = if_else(source == "old_data", statute_description, statute),
      type = if_else(source == "old_data",
                     if_else(
                       str_detect(violation, "PEDEST")
                       & !str_detect(violation, "FAILURE TO YIELD TO PEDESTRIAN")
                       & !str_detect(violation, "PASS VEH STOPPED FOR PEDEST"),
                       "pedestrian",
                       "vehicular"
                     ),
                     "vehicular")
    ) %>%
    # arrest_made, citation_issued, outcome
    rename(arrest = arrest_made, citation = citation_issued) %>%
    mutate(outcome = first_of(
      arrest = arrest,
      citation = citation
    )) %>%
    # contraband, search,
    # - convert char and NA into logical
    mutate_at(
      vars("contraband_found_i", ends_with("searched")),
      ~ !(is.na(.) | . == "N")
    ) %>%
    mutate_at(vars(ends_with("found")), ~ !is.na(.)) %>%
    # - coerce into expected names
    mutate(
      contraband_found = contraband_found_i,
      contraband_drugs = (veh_drug_found | drv_pas_drug_found),
      contraband_weapons = (veh_weapon_found | drv_pas_weapon_found),
      contraband_alcohol = (veh_alcohol_found | drv_pas_alcohol_found),
      contraband_other = (veh_other_found | drv_pas_other_found |
                            veh_paraphernalia_found | drv_pas_paraphernalia_found |
                            veh_stolen_property_found | drv_pas_stolen_prop_found),
      search_person = (drv_searched | pass_searched),
      search_vehicle = veh_searched,
      search_conducted = (search_person | search_vehicle)
    ) %>%
    # make/model
    rename(
      vehicle_make = make_descr,
      vehicle_model = model_descr
    ) %>%
    # rename raw
    rename(
      raw_race = race,
      raw_driver_race = driver_race
    ) %>%
    standardize(d$metadata)
}