# NOTE: January 2013 looks suspiciously low in both the old OPP data and in this cleaned version
# NOTE: search/hit counts are a bit different between old opp and this version, because the old
# opp counted all search NAs as FALSE, whereas we check other fields when NA. (i believe our new
# method to be more accurate)
# NOTE: there are also some slight discrepancy in by-month numbers throughout 2013 and 2014, between
# old opp and this cleaned data (even after filtering to the patrol-only data); 
# though the total counts and race breakdowns are identical between
# old opp and newly cleaned data. it is unclear to me where these discrepancies arise from. it is 
# possible that 2013 sheets 23467 should be used instead of sheet 1, however when merging the two,
# they line up identically, so i can't see that helping.
# TODO(amyshoe): figure out what is causing discrepancies between old and new opp data in by-month 
# 2013 counts 
source("common.R")

load_raw <- function(raw_data_dir, n_max) {
  d13_1 <- load_single_file(
    raw_data_dir,
    '2013_master_traffic_stop_data_for_2014_report_sheet_1.csv',
    n_max = n_max
  )
  # NOTE: pages 23467 contain duplicates of pg 1, so we don't process them
  # d13_23467 <- load_regex(
  #   raw_data_dir,
  #   '2013_master_traffic_stop_data_for_2014_report_sheet_[23467].csv',
  #   n_max = n_max
  # )
  d13_5 <- load_single_file(
    raw_data_dir,
    '2013_master_traffic_stop_data_for_2014_report_sheet_5.csv',
    n_max = n_max
  )
  d13 <- bind_rows(
    d13_1$data %>%
      select(-`Age at the time of stop`, -X8) %>%
      rename(Registration = `Registration (tag)`),
    #d13_23467$data %>%
    #  rename(Location = LOCATION),
    d13_5$data %>%
      rename(
        Location = LOCATION,
        Agency = AGENCY,
        `Arrest Made` = Arrest
      )
  )

  d07_1 <- load_single_file(
    raw_data_dir,
    '2007_master_traffic_stop_data_for_2008_report.csv',
    n_max = n_max
  )
  d07 <- d07_1$data %>%
    rename(
      Agency = Jurisdiction,
      `Arrest Made` = Arrest,
      `Arrest Reason` = AReason,
      `Stop Reason` = StopC,
      Search = SType,
      `Search Reason` = SReason,
      contra_prop = SProp,
      contra_narc = SNarc
    ) %>%
    mutate(
      # NOTE: 2007 actually kept more data about registration; we drop it here
      # because all other years track only in-state or out-of-state.
      `State of Residence` = if_else(toupper(DReg) == "MD", "i", "o"),
      `State of Registration` = if_else(toupper(VReg) == "MD", "i", "o"),
      # NOTE: 2007 data do not have dates; mark stops at first of year.
      `Date of Stop` = "2007/01/01"
    ) %>%
    select(-StopG, -StopE, -Consent, -Citation, -SERO, -Warning, -DReg, -VReg)

  # 2009-12 data are similar except for some slight variations in column names.
  d09 <- load_single_file(
    raw_data_dir,
    '2009_master_traffic_stop_data_for_2010_report.csv',
    n_max = n_max
  )
  d11 <- load_single_file(
    raw_data_dir,
    '2011_master_traffic_stop_data_for_2012_report.csv',
    n_max = n_max
  )
  d12 <- load_single_file(
    raw_data_dir,
    '2012_master_traffic_stop_data_for_2013_report.csv',
    n_max = n_max
  )

  bind_rows(
    # NOTE: 2009-11 data do not have dates; mark stops at first of year.
    d09$data %>% mutate(`Date of Stop` = "2009/01/01"),
    d11$data %>% mutate(`Date of Stop` = "2011/01/01")
  ) %>%
  rename(
    `Stop Reason` = Stopreason,
    `Arrest Reason` = Arrestreason,
    `Search Reason` = Searchreason
  ) %>%
  bind_rows(
    # NOTE: 2012 data do not have dates; mark stops at first of year.
    d12$data %>% mutate(`Date of Stop` = "2012/01/01") %>% select(-X11),
    d13
  ) %>%
  mutate(
    # NOTE: Convert these to a character for row-binding; we'll turn the
    # them back into logical later in processing with the other years' data.
    contra_prop = if_else(str_detect(Disposition, "both|prop"), "T", "F"),
    contra_narc = if_else(str_detect(Disposition, "both|narc"), "T", "F")
  ) %>%
  bind_rows(
    d07
  ) %>%
  bundle_raw(c(
    d13_1$loading_problems,
    # d13_23467$loading_problems,
    d13_5$loading_problems,
    d07_1$loading_problems,
    d09$loading_problems,
    d11$loading_problems,
    d12$loading_problems
  ))
}


clean <- function(d, helpers) {

  re_yes <- regex("Y|T|1", ignore_case = TRUE)
  is_true <- function(col) str_detect(col, re_yes)

  tr_search <- c(
    "ARR" = "person",
    "ARREST" = "person",
    "b" = "both",
    "B" = "both",
    "both" = "both",
    "Both" = "both",
    "BOTH" = "both",
    "CDS" = "unknown",
    "CONS" = "unknown",
    "CONSENSUAL" = "unknown",
    "DOR" = "unknown",
    "Incident to Arrest" = "person",
    "p" = "person",
    "P" = "person",
    "PC" = "person",
    "per" = "person",
    "Per" = "person",
    "PER" = "person",
    "Per Prop" = "both",
    "pers" = "person",
    "Pers" = "person",
    "PERS" = "person",
    "Person" = "person",
    "PERSON" = "person",
    "Person and Property" = "both",
    "PERSON/PROP" = "both",
    "PR" = "person",
    "pro" = "property",
    "Pro" = "property",
    "prop" = "property",
    "Prop" = "property",
    "PROP" = "property",
    "property" = "property",
    "Property" = "property",
    "PROPERTY" = "property",
    "Prsn" = "person",
    "P/V" = "both",
    "V" = "property",
    "VEH" = "property",
    "Vehicle" = "property"
   )

  tr_race <- c(
    "w" = "white",
    "b" = "black",
    "a" = "asian/pacific islander",
    "h" = "hispanic",
    "o" = "other/unknown",
    "u" = "other/unknown",
    "asian" = "asian/pacific islander",
    "black" = "black",
    "hispanic" = "hispanic",
    "native american" = "other/unknown",
    "other" = "other/unknown",
    "unknown" = "other/unknown",
    "white" = "white",
    "am. indian" = "other/unknown",
    "american indian/alaskan" = "other/unknown",
    "asian pacific" = "asian/pacific islander",
    "asian/pac. is." = "asian/pacific islander",
    "black/african american" = "black",
    "blk" = "black",
    "hispa" = "hispanic",
    "hispanic/latino" = "hispanic",
    "indian" = "other/unknown",
    "indian/alaskin" = "other/unknown",
    "other/unknown" = "other/unknown"
  )

  d$data %>%
    rename(
      location = Location,
      department_name = Agency,
      violation = `Crime Charged`,
      disposition = Disposition,
      reason_for_arrest = `Arrest Reason`,
      reason_for_stop = `Stop Reason`,
      reason_for_search = `Search Reason`
    ) %>%
    mutate(
      # NOTE: Some dates include timestamps as well. These are redundant with
      # the `Time of Stop` column, so drop them here.
      date_raw = str_sub(`Date of Stop`, 0, 10),
      date = parse_date(date_raw, "%Y/%m/%d"),
      # NOTE: Some times include AM/PM. These are redundant with the hour,
      # which is 24-hour, so cut the string to only the HH:MM.
      time_raw = str_sub(`Time of Stop`, 0, 5),
      time = parse_time(time_raw, "%H:%M"),
      # NOTE: Some DOBs contain a junk time component (midnight); cut them off.
      # Other DOBs are malformed (e.g., 3-digit year); they will become NA.
      dob_raw = str_sub(DOB, 0, 10),
      subject_dob = parse_date(dob_raw, "%Y/%m/%d"),
      subject_age = age_at_date(subject_dob, date),
      subject_sex = fast_tr(Gender, tr_sex),
      subject_race = fast_tr(str_to_lower(Race), tr_race),
      # NOTE: Source data only include vehicle stops.
      type = "vehicular",
      # NOTE: `Arrest Made` column isn't complete, so supplement with "arrest"
      # values from the Outcome column when missing.
      outcome_arrest = str_detect(Outcome, fixed("arr", ignore_case = TRUE)),
      arrest_made_explicit = is_true(`Arrest Made`),
      arrest_made = if_else(is.na(`Arrest Made`), outcome_arrest, arrest_made_explicit),
      citation_issued = str_detect(Outcome, fixed("cit", ignore_case = TRUE)),
      warning_issued = str_detect(Outcome, fixed("warn", ignore_case = TRUE)),
      outcome = first_of(
        arrest = arrest_made,
        citation = citation_issued,
        warning = warning_issued
      ),
      contraband_drugs = is_true(contra_narc),
      contraband_weapons = is_true(contra_prop),
      contraband_found = contraband_drugs | contraband_weapons,
      # NOTE: the `Search Conducted` field is not totally reliable. Check
      # there if possible, but if it is NA check also whether the `Search`
      # field indicates that a search took place.
      search_conducted = if_else(
        !is.na(`Search Conducted`),
        is_true(`Search Conducted`),
        Search %in% names(tr_search)
      ),
      searched_what = fast_tr(Search, tr_search),
      search_person = str_detect(searched_what, "both|person"),
      search_vehicle = str_detect(searched_what, "both|property"),
      search_basis = first_of(
        "k9" = str_detect(reason_for_search, fixed("k\\-*9", ignore_case = TRUE)),
        "plain view" = str_detect(reason_for_search, "Plain View"),
        "consent" = str_detect(reason_for_search, fixed("con|cns", ignore_case = TRUE)),
        "probable cause" = str_detect(reason_for_search, fixed("prob", ignore_case = TRUE)),
        "other" = str_detect(reason_for_search, fixed("arr|invent", ignore_case = TRUE))
      )
    ) %>%
    standardize(d$metadata)
}
