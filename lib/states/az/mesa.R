source("common.R")

# VALIDATION: [GREEN] The Mesa Police Department's "2017 Annual Report
# indicates that they had between 115k and 144k traffic stops each year from
# 2014 to 2017, since our numbers are around 30k each year (except 2017 where
# we only have part of the year), it appears as though we only have those stops
# that resulted in actions taken, i.e. arrests, citations, warnings; it's also
# a little unclear as to which charges are specifically pedestrian vs.
# vehicular, so our categorization here is weak; see outstanding TODO
load_raw <- function(raw_data_dir, n_max) {
  old_d <- load_single_file(
    raw_data_dir,
    "2014-03-17_citations_data_prr.csv",
    n_max
  )
  
  # adding source variable to use in 
  # filtering out duplicates later
  old_d$data <- old_d$data %>%
    mutate(source = "old_data")
  
  updated_d <- load_single_file(
    raw_data_dir, 
    "2017_-_2019-09-23_Cites_PRR.csv", 
    n_max
  ) 
  
  updated_d$data <- updated_d$data %>%
    mutate(source = "new_data")
  
  bundle_raw(
    bind_rows(old_d$data, updated_d$data), 
    c(old_d$loading_problems, 
      updated_d$loading_problems)
  )
}


clean <- function(d, helpers) {
  
  tr_yn = c(
    YES = TRUE,
    NO = FALSE
  )
  
  # OLD NOTE: INCIDENT_NO appears to refer to the same incident but can involve
  # multiple people, i.e. 20150240096, which appears to be an alcohol bust of
  # several underage teenagers; in other instances, the rows look nearly
  # identical, but given this information and checking several other seeming
  # duplicates, it appears as though there is one row per person per incident
  d$data %>%
    rename_all(str_to_lower) %>%
    mutate(
      location = str_trim(str_c(block, city, sep = ", ")),
      # in old data, format is %Y-%m-%d (e.g., 2014-01-01)
      # in new data, format is %m/%d/%Y (e.g., 01/01/2017)
      date = ymd(if_else(
        source == "old_data", 
        lubridate::ymd(date), 
        lubridate::mdy(date)
      )),
      officer_last_name = coalesce(ofcr_lname, ofcr_lnme),
      officer_id = coalesce(ofcr_id, offcr_id),
    ) %>%
    # NOTE, DEC. 2020: Between 01/01/2017 and 03/31/2017: 
    # There are ~7000 rows in each df (old and new) for this time period
    # ~6300 in the new data are exact duplicates of rows in the old data
    # Of the remaining ~700 in the new data, ~673 are slightly different but clearly duplicates
    # They are exactly the same on date, time, citation number, city, officer id, 
    # charge description, but have slight variations here and there in the charge code, 
    # address, officer name, etc. 3 more are duplicates that are either missing a letter 
    # in the charge description or missing some data in the old version; 
    # 18 remaining entries appear to be new entries in the new data not in the old data
    # Because of this, we filter out data from the old data sources that are in this time frame 
    filter(
      (date < "2017-01-01") | 
        (date > "2017-03-31") | 
        (date >= "2017-01-01" & date <= "2017-03-31" & source=="new_data")
    ) %>% 
    helpers$add_lat_lng(
    ) %>%
    rename(
      subject_age = age,
      violation = charge_desc
    ) %>%
    mutate(
      time = parse_time_int(time),
      charge_prefix = str_extract(charge, "[0-9]+"),
      # TODO(phoebe): can we get clearer definitions of ped vs veh?
      # https://app.asana.com/0/456927885748233/571408593843006
      type = if_else(
        # all of the parking charges with this prefix appear to be parking-related, 
        # are these not considered vehicle? i guess we consider them NA?  
        charge_prefix == "28" & !str_detect(violation, "BICYC|PARK"),
        "vehicular",
        if_else(
          charge_prefix == "10" & !str_detect(violation, "SPEED LIMIT|PARK"),
          "pedestrian",
          NA_character_
        )
      ),
      arrest_made = !is.na(arrest_no),
      citation_issued = !is.na(cite_no),
      warning_issued = tr_yn[warning],
      outcome = first_of(
        arrest = arrest_made,
        citation = citation_issued,
        warning = warning_issued
      ),
      subject_sex = tr_sex[sex],
      subject_race = tr_race[if_else(ethnicity_fixed == "H", "H", race_fixed)]
    ) %>%
    rename(
      raw_charge = charge,
      raw_ethnicity_fixed = ethnicity_fixed,
      raw_race_fixed = race_fixed
    ) %>%
    standardize(d$metadata)
}