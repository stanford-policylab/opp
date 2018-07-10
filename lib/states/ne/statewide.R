source("common.R")

load_raw <- function(raw_data_dir, n_max) {
  # Load 2014 data (originally Microsoft Access)
  ne14_time <- load_single_file(
      raw_data_dir,
      "nebraska_racialprofiling_2014_tbl_quarters.csv"
    )
  ne14_repo <- load_single_file(
      raw_data_dir,
      "nebraska_racialprofiling_2014_tbl_reports.csv",
      n_max = n_max
    )
  ne14_qtr_id <- load_single_file(
      raw_data_dir,
      "nebraska_racialprofiling_2014_tbl_quarter_id.csv"
    )
  ne14_dept <- load_single_file(
      raw_data_dir,
      "nebraska_racialprofiling_2014_tbl_ori.csv"
    )

  ne_dept <- select(
    ne14_dept$data,
    DeptID = ID,
    agency_id = ORI,
    dept = ORI_Description,
    dept_lvl = ORITYPEID,
    county = AgencyCounty
  ) %>%
  mutate(dept = str_replace_all(dept, "\\.", ""))

  # NOTE: Data in these sources are aggregated by quarter. The date field
  # is the first day of the quarter.
  ne14 <- ne14_qtr_id$data %>%
    select(
      TimeID = QuarterID,
      DeptID = ID,
      ReportID,
      n = Value
    ) %>%
    inner_join(
      select(
        ne14_time$data,
        TimeID = QuarterID,
        TimeStart = `Actual Quarter Date Start`
      ),
      by = "TimeID"
    ) %>%
    inner_join(
      ne_dept,
      by = "DeptID"
    ) %>%
    inner_join(
      select(
        ne14_repo$data,
        ReportID,
        Race,
        Reason = TopicDescription,
        Outcome = DetailDescription
      ),
      by = "ReportID"
    ) %>%
    filter(
      Reason == "Searches"
    ) %>%
    mutate(
      date = parse_date(str_sub(TimeStart, 1, 8), "%m/%d/%y")
    ) %>%
    select(date, dept_lvl, dept, county, Race, Outcome, n)

  # Load 2015-16 data (originally Excel)
  ne15_stops <- load_single_file(
    raw_data_dir,
    "nebraska_traffic-stop-2015-2016.csv",
    n_max = n_max
  )

  ne15 <- ne15_stops$data %>%
    rename(
      agency_id = Agency_Cd
    ) %>%
    # NOTE: Aggregate newer data by quarter to match old data.
    mutate(
      stop_month = str_pad(
        ((as.integer(Racial_Profile_Quarter) - 1) * 3) + 1, 2,
        "left",
        "0"
      ),
      date = parse_date(
        paste(Racial_Profile_Year, stop_month, "01", sep="-"),
        "%Y-%m-%d"
      )
    ) %>%
    left_join(
      ne_dept,
      by = "agency_id"
    ) %>%
    mutate(
      # NOTE: The department name is joined from a dictionary and in a small
      # number of cases is missing. For these, fall back on the ID, which in
      # these cases is human-readable.
      dept = coalesce(dept, agency_id)
    ) %>%
    select(
      date,
      dept,
      dept_lvl,
      county,
      Search_Conducted_White,
      Search_Not_Conducted_White,
      Search_Conducted_Black,
      Search_Not_Conducted_Black,
      Search_Conducted_Hispanic,
      Search_Not_Conducted_Hispanic,
      Search_Conducted_NatAmerican,
      Search_Not_Conducted_NatAmerican,
      Search_Conducted_Asian,
      Search_Not_Conducted_Asian,
      Search_Conducted_Other,
      Search_Not_Conducted_Other
    ) %>%
    gather(
      type,
      n,
      -date:-county
    ) %>%
    mutate(
      Outcome = str_replace(str_extract(type, ".*(?=_)"), "_", " "),
      Race = substr(type, nchar(Outcome) + 2, nchar(type))
    ) %>%
    select(date, dept_lvl, dept, county, Race, Outcome, n)

  # Combine everything
  bind_rows(
    ne14,
    ne15
  ) %>%
  bundle_raw(c(
    ne14_dept$loading_problems,
    ne14_repo$loading_problems,
    ne14_time$loading_problems,
    ne14_qtr_id$loading_problems,
    ne15_stops$loading_problems
  ))
}


clean <- function(d, helpers) {

  tr_race <- c(
    "White" = "white",
    "Black" = "black",
    "Hispanic" = "hispanic",
    "Asian" = "asian/pacific islander",
    "Asian / Pacific Islander" = "asian/pacific islander",
    "Native American - Alaskan" = "other/unknown",
    "Other" = "other/unknown",
    "NatAmerican" = "other/unknown"
  )

  # TODO(phoebe): can we get gender/reason_for_stop/search/contraband fields?
  # Also can we get data at the stop level (not aggregated by quarter)?
  # https://app.asana.com/0/456927885748233/737933462134621
  d$data %>%
    rename(
      police_department = dept
    ) %>%
    mutate(
      county = if_else(
        county %in% c("Inactive", "NSP and Other", "Private"),
        NA_character_,
        county
      ),
      location = county,
      subject_race = tr_race[Race],
      search_conducted = Outcome == "Search Conducted"
    ) %>%
    standardize(d$metadata)
}
