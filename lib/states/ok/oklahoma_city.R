source("common.R")


# VALIDATION: [YELLOW] Prior to 2011, it appears as though there is only
# partial data, same with the latter part of 2017. The Oklahoma City PD doesn't
# appear to produce annual reports or anything with traffic statistics
# (although crime is reported). That said, the figures for years where there
# appears to be complete data, 2012-2016, the counts seem reasonable.
load_raw <- function(raw_data_dir, n_max) {
  # NOTE: Here, "new" means the updated data gathered by Phoebe in 2020.  This
  # includes only information about citations, not arresting officers and
  # vehicles, while "old" refers to second-wave OPP, led by Dan and Amy in 2018
  # and 2019.
  stops <- load_single_file(
    raw_data_dir,
    'orr_20171017191427.csv',
    n_max = n_max
  )
  officer <- load_single_file(
    raw_data_dir,
    'orr_-_okcpd_roster_2007-2017_sheet_1.csv',
    n_max = n_max
  )
  officer$data[["ID #"]] <- str_pad(officer$data[["ID #"]], 4, pad = "0")
  old_d <- left_join(
    stops$data,
    officer$data,
    by = c("ofc_badge_no" = "ID #")
  )

  citations <- load_single_file(
    raw_data_dir,
    "citationstops.csv",
    n_max = n_max
  )
  new_d <- citations$data %>%
    # The contents of the columns are the same, but the column names have
    # slightly different spellings in the updated data.
    rename(
      Citation_No = Citation_no,
      DfndRace = Race,
      DfndSex = Sex,
      violDate = ViolDate,
      violTime = ViolTime,
      OffenseDesc = Offense_Desc
    )

  bundle_raw(
    bind_rows(old_d, new_d),
    c(
      stops$loading_problems,
      officer$loading_problems,
      citations$loading_problems
    )
  )
}


clean <- function(d, helpers) {

  # TODO(phoebe): can we get search/contraband information?
  # https://app.asana.com/0/456927885748233/739362458819579 
  tr_race = c(
    tr_race,
    M = "other",
    S = "other",
    X = "other"
  )

  d$data %>%
  merge_rows(
    violDate,
    violTime,
    violLocation,
    DfndRace,
    DfndSex,
    DfndDOB,
    ofc_badge_no
  ) %>%
  rename(
    date = violDate,
    time = violTime,
    location = violLocation,
    subject_dob = DfndDOB,
    violation = OffenseDesc,
    officer_id = ofc_badge_no,
    speed = viol_actl_spd,
    posted_speed = viol_post_spd,
    # NOTE: veh_color_2 is null 99.8% of the time
    vehicle_color = veh_color_1,
    vehicle_make = veh_make,
    vehicle_model = veh_model,
    # TODO(phoebe): what is veh_tag_st TU? roughly 10% are these
    # https://app.asana.com/0/456927885748233/521735743717410
    vehicle_registration_state = veh_tag_st,
    vehicle_year = veh_year
  ) %>%
  helpers$add_lat_lng(
  ) %>%
  helpers$add_shapefiles_data(
  ) %>%
  rename(
    division = DIVISION.x,
    sector = SECTOR,
    beat = BEAT
  ) %>%
  helpers$add_type(
    "violation"
  ) %>%
  mutate(
    # NOTE: these are all citations
    citation_issued = TRUE,
    # TODO(phoebe): can we get other types of outcomes?
    # https://app.asana.com/0/456927885748233/739362458819581 
    # NOTE: For "new" data, arrest outcomes are available.
    arrest_made = if_else(viol_arrest == "NULL", NA_character_, viol_arrest),
    arrest_made = arrest_made == "Y",
    outcome = first_of(
      arrest = arrest_made,
      citation = citation_issued
    ),
    date = parse_date(date, "%Y%m%d"),
    time = parse_time_int(time),
    subject_race = tr_race[DfndRace],
    subject_sex = tr_sex[DfndSex],
    subject_dob = parse_date(subject_dob, "%Y%m%d"),
    subject_age = age_at_date(subject_dob, date)
  ) %>%
  filter(
    # NOTE: data before 2011 is partial
    year(date) > 2010
  ) %>%
  rename(
    raw_dfnd_race = DfndRace
  ) %>%
  standardize(d$metadata)
}
