source("common.R")


# VALIDATION: [YELLOW] The Wichita Police Department's Year In Review for 2016
# has no substantial statistics.
load_raw <- function(raw_data_dir, n_max) {
  d <- load_years(raw_data_dir, n_max)
  colnames(d$data) <- make_ergonomic(colnames(d$data))
  bundle_raw(d$data, d$loading_problems)
}


clean <- function(d, helpers) {

  # TODO(phoebe): can we get reason_for_stop/search/contraband fields?
  # https://app.asana.com/0/456927885748233/595493946182532
  d$data %>%
    # TODO(phoebe): are citation numbers unique? sometimes it looks like the
    # represent the same stop, other times, there are two separate locations
    # for the same citation number, i.e. "07M000645"?
    # https://app.asana.com/0/456927885748233/1106093271701480
    merge_rows(
      citation_date_time,
      citation_location,
      defendant_first_name,
      defendant_last_name,
      defendant_age,
      defendant_sex,
      defendant_race
    ) %>%
    rename(
      subject_age = defendant_age,
      subject_first_name = defendant_first_name,
      subject_last_name = defendant_last_name,
      # TODO(ravi): is this acceptable? should we filter out anything else?
      # https://app.asana.com/0/456927885748233/595493946182533
      violation = charge_description,
      disposition = charge_disposition
    ) %>%
    right_separate_cols(
      officer_name = c("officer_first_name", "officer_last_name")
    ) %>%
    mutate(
      type = if_else(
        str_detect(
          violation,
          str_c(
            "BICYCLE-LICENSE REQUIRED",
            "BIKE( IMPEDE|-OBSERVE|-PEDAL)",
            "LOITERING-OBST TRF/PEDESTRIAN",
            "PED( CROSS| USE|-SOLICIT|-USE|-YIELD)",
            "PEDESTRAIN UNDER INFLUENCE", # NOTE: misspelled in data
            "PEDESTRIAN (DISOBEY|FAIL|MUST|RUN|STOP|USE|WALK|YIELD)",
            "PEDESTRIAN-YIELD",
            sep = "|"
          )
        ),
        "pedestrian",
        "vehicular"
      ),
      # NOTE: some of the date info in the new 2018-2020 data
      # has what appears to be some sort of timezone info at the end
      # of the string - e.g., "2018/01/01 10:48:00+00". All 
      # entries with this format have "+00" at the end, which we remove 
      # for processing
      citation_date_time = sub("\\+.*$", "", citation_date_time), 
      datetime = coalesce(
        parse_datetime(citation_date_time, locale = locale(tz = "US/Central")),
        parse_datetime(citation_date_time, "%Y-%m-%d %H:%M:%S"),
        parse_datetime(citation_date_time, "%Y/%m/%d %H:%M:%S"),
        parse_datetime(citation_date_time, "%Y/%m/%d")
      ),
      date = as.Date(datetime),
      time = format(datetime, "%H:%M:%S"),
      # OLD NOTE: all the files are named citations_<year>.csv
      # NEW NOTE: the 2020 file has a different name, citations_20200518.csv
      citation_issued = TRUE,
      outcome = "citation",
      # TODO(phoebe): can we get other outcomes (warnings, arrests)?
      # https://app.asana.com/0/456927885748233/595493946182534
      location = str_c_na(
        citation_location,
        citation_city,
        citation_state,
        citation_zip,
        sep = ", "
      ),
      subject_race = tr_race[if_else_na(
        defendant_ethnicity == "H",
        "H",
        defendant_race
      )],
      subject_sex = tr_sex[defendant_sex]
    ) %>%
    helpers$add_lat_lng(
    ) %>%
    rename(
      raw_defendant_ethnicity = defendant_ethnicity,
      raw_defendant_race = defendant_race
    ) %>%
    standardize(d$metadata)
}
