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
  
  # duplicates and near duplicates from overlapping time frame are
  # not getting removed -> how to fix this? 
  updated_d <- load_single_file(
    raw_data_dir, 
    "2017_-_2019-09-23_Cites_PRR.csv", 
    n_max
  ) 
  
  new_d <- updated_d$data %>% 
    rename(
      OFCR_LNME = OFCR_LNAME, 
      OFCR_ID = OFFCR_ID
    )
  
  bundle_raw(
    bind_rows(old_d$data, new_d), 
    c(old_d$loading_problems, 
      updated_d$loading_problems)
  )
}


clean <- function(d, helpers) {
  
  tr_yn = c(
    YES = TRUE,
    NO = FALSE
  )
  
  colnames(d$data) <- tolower(colnames(d$data))
  
  # OLD NOTE: INCIDENT_NO appears to refer to the same incident but can involve
  # multiple people, i.e. 20150240096, which appears to be an alcohol bust of
  # several underage teenagers; in other instances, the rows look nearly
  # identical, but given this information and checking several other seeming
  # duplicates, it appears as though there is one row per person per incident
  d$data %>%
    mutate(
      location = str_trim(str_c(block, city, sep = ", ")),
      # is there a better way to do this? 
      # in old data, format is %Y-%m-%d (e.g., 2014-01-01)
      # in new data, format is %m/%d/%Y (e.g., 01/01/2017)
      date = coalesce(
        lubridate::mdy(date), 
        lubridate::ymd(date)
      )
    ) %>%
    helpers$add_lat_lng(
    ) %>%
    rename(
      subject_age = age,
      officer_id = ofcr_id,
      officer_last_name = ofcr_lnme,
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
