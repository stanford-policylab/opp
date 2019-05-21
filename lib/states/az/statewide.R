source(here::here("lib", "common.R"))
# NOTE: Data is too sparse in 2009, 2010, and part of 2011; don't trust it until 
# mid 2011. 
# TODO: Missing two weeks of data in 2012 (oct 1-14), and two weeks of data in 
# 2013 (nov 2-14) - see: https://app.asana.com/0/456927885748233/1110901769782597
# We're also missing Dec 2015.
# NOTE from old opp: "Some contraband information is available and so we define 
# a contraband_found column in case it is useful to other researchers. But the 
# data is messy and there are multiple ways contraband_found might be defined, 
# and so we do not include Arizona in our contraband analysis."

load_raw <- function(raw_data_dir, n_max) {
  d <- load_years(raw_data_dir, n_max)
  d_16_17 <- load_regex(raw_data_dir, "^contact_form", n_max)
  # 2016-2017 data is really messy and has a long tail of gibberish columns
  d_16_17$data <- d_16_17$data %>% 
    select(intersect(colnames(d$data), colnames(d_16_17$data)))
  d$data <- bind_rows(d$data, d_16_17$data)
  bundle_raw(d$data, c(d$loading_problems, d_16_17$loading_problems))
}

clean <- function(d, helpers) {

  # TODO(phoebe): lacking translations for violations: EQ FD FY LU OT TS
  # https://app.asana.com/0/456927885748233/754158606630626
  tr_violations <- c(
    # NOTE: these are taken from correspondence with the PD
    "DU" = "DUI",
    "ER" = "expired registration",
    "EV" = "equipment violation",
    "FC" = "following too close",
    "FS" = "failure to signal",
    "FT" = "failure to stop",
    "IT" = "improper turning",
    "LR" = "lamps required",
    "NI" = "no insurance",
    "NL" = "no license",
    "OM" = "other moving violation",
    "ON" = "other non-moving violation",
    "SP" = "speed",
    "UL" = "unsafe lane change"
  )

  tr_pre_stop_indicator <- c(
    VT = "Vehicle Type, Condition or Modification",
    BL = "Driver Body Language",
    PB = "Passenger Behavior",
    DB = "Driving Behavior",
    OT = "Other",
    NO = "None"
  )

  # NOTE: this map was reverse engineered from the highways; i.e. the county
  # was determined by the highways that pass through it
  tr_county <- c(
    "01" = "Apache County",
    "02" = "Cochise County",
    "03" = "Coconino County",
    "04" = "Gila County",
    "05" = "Graham County",
    "06" = "Greenlee County",
    "07" = "Maricopa County",
    "08" = "Mohave County",
    "09" = "Navajo County",
    "10" = "Pima County",
    "11" = "Pinal County",
    "12" = "Santa Cruz County",
    "13" = "Yavapai County",
    "14" = "Yuma County",
    "15" = "La Paz County"
  )

  tr_race <- c(
    W = "white",
    H = "hispanic",
    B = "black",
    N = "other/unknown",
    A = "asian/pacific islander",
    M = "other/unknown",
    X = "other/unknown"
  )
  
  tr_reason_for_stop <- c(
    H = "Moving violation",
    N = "Non-moving violation",
    V = "Vehicle equipment",
    I = "Investigative stop",
    E = "Externally generated contact",
    C = "Collision",
    O = "Criminal offense",
    M = "Motorist assist",
    W = "Wrong way"
  )
  # TODO(phoebe): what are kots_* and dots_* files vs the yearly data?
  # https://app.asana.com/0/456927885748233/727769678078699
  # TODO(phoebe): can we get a data dictionary for ReasonForStop?
  # https://app.asana.com/0/456927885748233/750432191394464
  d$data %>%
    add_raw_colname_prefix(
      TypeOfSearch,
      Ethnicity,
      ReasonForStop,
      ViolationsObserved,
      OutcomeOfStop
    ) %>% 
    rename(
      date = DateOfStop,
      time = TimeOfStop,
      officer_id = BadgeNumber,
      vehicle_year = VehicleYear,
      vehicle_type = VehicleStyle
    ) %>%
    helpers$add_county_from_highway_milepost(
      "Highway",
      "Milepost"
    ) %>%
    mutate(
      # NOTE: there doesn't seem to be any other way to suss out whether this
      # was a pedestrian stop; presumably this is quite low, since these are
      # state patrol stops; PE = Pedestrian, BI = Bicyclist
      type = if_else_na(
        str_detect(raw_TypeOfSearch, "PE|BI"),
        "pedestrian",
        "vehicular"
      ),
      # NOTE: use County column if possible, otherwise, use the values
      # generated from add_county_from_highway_milepost
      county_name = coalesce(
        fast_tr(County, tr_county),
        county
      ),
      # rename to for consistency in county naming
      county_name = if_else(
        !str_detect(county_name, "County"), 
        str_c(county_name, " County"), 
        county_name
      ),
      location = coalesce(
        OtherLocation,
        str_c_na(Highway, Milepost, sep = " ")
      ),
      subject_race = fast_tr(raw_Ethnicity, tr_race),
      subject_sex = fast_tr(Gender, tr_sex),
      reason_for_stop = fast_tr(raw_ReasonForStop, tr_reason_for_stop),
      violation = translate_by_char_group(
        raw_ViolationsObserved,
        tr_violations,
        ","
      ),
      # NOTE: DR = Driver, PS = Passenger, PE = Pedestrian, BI = Bicyclist
      search_person = str_detect(raw_TypeOfSearch, "DR|PS|PE|BI")
        | tr_yn[SearchOfDriver],
      search_vehicle = tr_yn[SearchOfVehicle],
      search_conducted = tr_yn[SearchPerformed],
      search_basis = first_of(
        "consent" = tr_yn[ConsentSearchAccepted],
        "other" = tr_yn[DUISearchWarrant],
        "probable cause" = search_conducted 
      ),
      contraband_drugs = !is.na(DrugSeizureType),
      contraband_other = (DriverItemsSeized != 'N' & !is.na(DriverItemsSeized)) |
        (VehicleItemsSeized != 'N' & !is.na(VehicleItemsSeized)),
      contraband_found = contraband_drugs | contraband_other,
      warning_issued = str_detect(raw_OutcomeOfStop, "WA"),
      citation_issued = str_detect(raw_OutcomeOfStop, "CI|DV|TC"),
      arrest_made = str_detect(raw_OutcomeOfStop, "AR|WR"),
      outcome = first_of(
        arrest = arrest_made,
        citation = citation_issued,
        warning = warning_issued
      )
    ) %>%
    standardize(d$metadata)
}
