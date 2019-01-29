source(here::here("lib", "common.R"))


load_raw <- function(raw_data_dir, n_max) {
  citations_data <- load_single_file(
    raw_data_dir,
    "ecco_data.csv",
    n_max = n_max
  )
  citations_data$data$outcome = "citation"

  warnings_data <- load_single_file(
    raw_data_dir,
    "ewc_data.csv",
    n_max = n_max
  )
  warnings_data$data$outcome = "warning"

  data <- bind_rows(citations_data$data, warnings_data$data)
  loading_problems <- c(
    citations_data$loading_problems,
    warnings_data$loading_problems
  )
  bundle_raw(data, loading_problems)
}


clean <- function(d, helpers) {
  tr_county <- json_to_tr(helpers$load_json("IA_counties.json"))
  tr_race <- c(
    # Non-Hispanic
    "N" = "other/unknown",
    # Hispanic
    "H" = "hispanic",
    # Unknown
    "U" = "other/unknown"
  )

  d$data %>%
    rename(
      # NOTE: location does not include city or county.
      # TODO(walterk): Determine whether it is worth it to geocode.
      # https://app.asana.com/0/456927885748233/727769678078700
      location = OFFENSELOCATN,
      # NOTE: subject_age, officer_id, department_name are NA for all warnings.
      subject_age = LOCKAGE,
      officer_id = BADGENUMBER,
      # NOTE: vehicle_* is NA for all warnings.
      vehicle_color = LOCKVEHICLECOLOR,
      vehicle_make = LOCKVEHICLEMAKE,
      vehicle_model = LOCKVEHICLEMODEL,
      vehicle_registration_state = LOCKVEHICLEPLATESTATE,
      # TODO(walterk): Is vehicle_year the model year or the year on the plates?
      # Possibly LOCKVEHICLEPLATEYEAR. In either case, the data is a bit messy.
      # https://app.asana.com/0/456927885748233/729888734192511
      vehicle_year = LOCKVEHICLEYEAR
    ) %>%
    mutate(
      date = parse_date(VIOLATIONDATE, "%m/%d/%Y"),
      time = coalesce(
        parse_time(VIOLATIONTIME, "%H:%M"),
        parse_time(VIOLATIONTIME, "%I:%M:%S %p")
      ),
      department_name = str_to_title(DEPARTMENTNAME),
      # NOTE: county_name is NA for all warnings.
      # TODO(walterk): Should we use COUNTY or LOCKCOUNTY?
      # https://app.asana.com/0/456927885748233/729888734192512
      county_name = fast_tr(LOCKCOUNTY, tr_county),
      # NOTE: subject_race, subject_sex are NA for all warnings.
      subject_race = fast_tr(LOCKETHNICITY, tr_race),
      subject_sex = fast_tr(LOCKGENDER, tr_sex),
      # NOTE: Inferring type "vehicular" based on if vehicle data is not NA or
      # if the violation section is vehicle related based on:
      # https://www.legis.iowa.gov/law/iowaCode/sections?codeChapter=321&year=2018
      type = if_else(
        !is.na(vehicle_color)
        | !is.na(vehicle_make)
        | !is.na(vehicle_model)
        | !is.na(vehicle_registration_state)
        | !is.na(vehicle_year)
        | !is.na(LOCKVEHICLEPLATEYEAR)
        | !is.na(LOCKVEHICLESTYLE)
        | grepl("^321", SECTIONVIOLATED),
        "vehicular",
        NA_character_
      ),
      violation = if_else(
        is.na(SECTIONVIOLATED) | is.na(VIOLDESCRIPTION),
        coalesce(SECTIONVIOLATED, VIOLDESCRIPTION),
        str_c(SECTIONVIOLATED, VIOLDESCRIPTION, sep=": ")
      ),
      citation_issued = outcome == "citation",
      warning_issued = outcome == "warning"
    ) %>%
    # records with NA for key have no other fields
    filter(!is.na(INDIVKEY)) %>%
    # dedupe
    # NOTE: (old opp) There are duplicates where more than one warning or citation is given within 
    # the same stop. We remove these by grouping by the remaining fields by the stop key and date.
    # In some cases, there are multiple time stamps per unique (key, date) combination. 
    # In most of these cases, the timestamps differ by a few minutes, but all other fields 
    # (except for violation) are the same. In 0.1% of stops, the max span between timestamps 
    # is more than 60 minutes. In those cases it looks like the same officer stopped the same 
    # individual more than once in the same day.
    merge_rows(INDIVKEY, date) %>% 
    standardize(d$metadata)
}
