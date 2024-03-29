source(here::here("lib", "common.R"))


load_raw <- function(raw_data_dir, n_max) {
  d <- load_regex(raw_data_dir, "\\.csv$", n_max = n_max)
  bundle_raw(d$data, d$loading_problems)
}

clean <- function(d, helpers) {
  tr_chp <- helpers$load_csv("CA_chp_lookup.csv") %>%
    # if multiple rows with same code, keep the row with "Offices"
    add_count(LocationCode) %>%
    filter(n == 1 | (n > 1 & Type == "Offices")) %>%
    transmute(
      LocationCode = as.numeric(LocationCode), 
      district = Name, 
      county_name = County
    )
  
  tr_race_raw <- c(
    A = "Other Asian",
    B = "Black", 
    C = "Chinese",
    D = "Cambodian", 
    F = "Filipino", 
    G = "Guamanain", 
    H = "Hispanic", 
    I = "Indian",  
    J = "Japanese", 
    K = "Korean", 
    L = "Laotian", 
    O = "Other", 
    P = "Other Pacific Islander", 
    S = "Samoan", 
    U = "Hawaiian", 
    V = "Vietnamese", 
    W = "White", 
    Z = "Asian Indian" 
  )
  
  tr_race <- c(
    A = "asian/pacific islander", # Other Asian
    B = "black", # Black
    C = "asian/pacific islander", # Chinese
    D = "asian/pacific islander", # Cambodian
    F = "asian/pacific islander", # Filipino
    G = "asian/pacific islander", # Guamanian
    H = "hispanic", # Hispanic
    I = "other", # Indian (presumably native american, since Z)
    J = "asian/pacific islander", # Japanese
    K = "asian/pacific islander", # Korean
    L = "asian/pacific islander", # Laotian
    O = "other", # Other
    P = "asian/pacific islander", # Other Pacific Islander
    S = "asian/pacific islander", # Samoan
    U = "asian/pacific islander", # Hawaiian
    V = "asian/pacific islander", # Vietnamese
    W = "white", # White
    Z = "asian/pacific islander" # Asian Indian
  )

  tr_violation <- c(
    "1" = "Moving Violation (VC)",
    "2" = "Mechanical or Nonmoving Violation (VC)",
    "3" = "DUI Check",
    "4" = "Penal Code / All Other Codes",
    "5" = "Traffic Collision",
    "6" = "Motorist / Public Service",
    "7" = "Inspection / Scale Facility",
    "8" = "Other Agency Assist / BOLO / APB / Warrant"
  )

  tr_outcome <- c(
    "1" = "arrest", # In Custody Arrest
    "2" = "summons", # CHP 215
    "3" = "citation", # CHP 281
    "4" = "warning" # Verbal Warning
  )

  tr_search_basis <- c(
    "1" = "probable cause", # Probable Cause (positive)
    "01" = "probable cause", # Probable Cause (positive)
    "2" = "probable cause", # Probable Cause (negative)
    "02" = "probable cause", # Probable Cause (negative)
    "3" = "consent", # Consent (positive), 202D Required
    "4" = "consent", # Consent (negative), 202D Required
    "5" = "other", # Incidental to Arrest
    "6" = "other", # Vehicle Inventory
    "7" = "other", # Parole / Probation / Warrant
    "8" = "other", # Other
    "9" = "other", # Pat Down / Frisk
    "09" = "other" # Pat Down / Frisk
  )
  
  tr_search_basis_raw <- c(
    "1" = "Probable Cause (positive)",
    "01" = "Probable Cause (positive)",
    "2" = "Probable Cause (negative)",
    "02" = "Probable Cause (negative)",
    "3" = "Consent (positive), 202D Required",
    "4" = "Consent (negative), 202D Required",
    "5" = "Incidental to Arrest",
    "6" = "Vehicle Inventory",
    "7" = "Parole / Probation / Warrant",
    "8" = "Other",
    "9" = "Pat Down / Frisk",
    "09" = "Pat Down / Frisk"
  )

  d$data %>%
    # standardize LocationCode (remove inconsistent leading 0s)
    mutate(LocationCode = as.numeric(LocationCode)) %>%
    # add district, county_name
    left_join(tr_chp) %>% 
    mutate(
      # NOTE: The stop time is not provided; all times appearing in the Date
      # column are 00:00:00. The shift time is provided in the raw data but is
      # not granular enough.
      date = coalesce(
        parse_date(Date, "%m/%d/%Y"),
        parse_date(Date, "%m/%d/%Y %H:%M:%S")
      ),
      # NOTE: subject_age is provided, but only as an enum representing age
      # ranges: "0-14","15-25","25-32","33-39","40-48","49+".
      subject_race = fast_tr(Ethnicity, tr_race),
      raw_race = fast_tr(Ethnicity, tr_race_raw),
      subject_sex = fast_tr(Gender, tr_sex),
      # NOTE: Data is for California Highway Patrol vehicular stops.
      department_name = "California Highway Patrol",
      type = "vehicular",
      violation = fast_tr(Reason, tr_violation),
      outcome = fast_tr(Result, tr_outcome),
      arrest_made = outcome == "arrest",
      citation_issued = outcome == "citation",
      warning_issued = outcome == "warning",
      frisk_performed = if_else(Description == "9", TRUE, NA),
      search_conducted = Description != "0",
      contraband_found = if_else(
        Description == "1" | Description == "3" | Description == "01",
        TRUE,
        if_else(
          Description == "2" | Description == "4" | Description == "02",
          FALSE,
          NA
        )
      ),
      search_person = frisk_performed,
      search_basis = fast_tr(Description, tr_search_basis),
      raw_search_basis = fast_tr(Reason, tr_search_basis_raw),
      raw_location_code = LocationCode,
      reason_for_stop = violation
    ) %>%
    standardize(d$metadata)
}
