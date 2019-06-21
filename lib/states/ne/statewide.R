source(here::here("lib", "common.R"))

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
  )

  # NOTE: Data in these sources are aggregated by quarter. The date field
  # is the first day of the quarter. Most of the useful fields are joined
  # in from data dictionaries.
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
    # NOTE: We derive the `Reason` column from the `TopicDescription` column.
    # The `TopicDescription` is one of stop reason, outcome, or whether there
    # was a search. Ideally we would be able to consider all of these factors,
    # but since the data are aggregated we can't cross-tabulate them. Filter
    # to consider only the search topics.
    filter(
      Reason == "Searches"
    ) %>%
    mutate(
      # NOTE: Time portion of the timestamp is always midnight, so drop it
      # and parse only the date portion.
      date = parse_date(str_sub(TimeStart, 1, 8), "%m/%d/%y")
    ) %>%
    select(date, dept_lvl, dept, county, Race, Outcome, n)

  # Load 2015-16 data (originally Excel)
  ne15_stops <- load_single_file(
    raw_data_dir,
    "nebraska_traffic-stop-2015-2016.csv",
    n_max = n_max
  )

  # List of the starting months of each quarter in a year. (I.e., Q1 starts in
  # January, Q2 in April, etc.)
  tr_qtr_start_month <- c("01", "04", "07", "10")

  ne15 <- ne15_stops$data %>%
    rename(
      agency_id = Agency_Cd
    ) %>%
    # NOTE: Aggregate newer data by quarter to match old data.
    mutate(
      # NOTE: Convert quarter number to the month when that quartert starts,
      # for consistency with old data. E.g., for Q2 return "04" for April.
      month = tr_qtr_start_month[as.integer(Racial_Profile_Quarter)],
      # NOTE: Date is the first day of the given quarter, for consistency with
      # old data.
      date = parse_date(
        str_c(Racial_Profile_Year, month, "01", sep = "-"),
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
    # NOTE: Convert from wide format to long.
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
    # NOTE: The `type` column holds the column headers as given above, e.g.
    # Search_Not_Conducted_Hispanic. This contains two pieces of information:
    # whether a search was conducted and the race. Separate this string into
    # two columns accordingly.
    right_separate_cols(
      type = c("Outcome", "Race"),
      sep = "_"
    ) %>%
    # NOTE: Clean up underscores to make this consistent with the old data.
    mutate(
      Outcome = str_replace(Outcome, "_", " ")
    ) %>%
    select(date, dept_lvl, dept, county, Race, Outcome, n)

  # Combine years
  ne_agg <- bind_rows(ne14, ne15)
  # Disaggregate rows. For each row index, repeat that row `n` times. (The
  # column `n` is the count aggregate for that row.)
  N <- nrow(ne_agg)
  ne_agg[rep(1:N, ne_agg$n),] %>%
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
    "Native American - Alaskan" = "other",
    "Other" = "other",
    "NatAmerican" = "other"
  )

  # TODO(phoebe): can we get gender/reason_for_stop/search/contraband fields?
  # Also can we get data at the stop level (not aggregated by quarter)?
  # https://app.asana.com/0/456927885748233/737933462134621
  d$data %>%
    add_raw_colname_prefix(
      dept_lvl,
      dept,
      Race
    ) %>% 
    mutate(
      county_name = if_else(
        county %in% c("Inactive", "NSP and Other", "Private"),
        NA_character_,
        str_c(county, " County")
      ),
      subject_race = tr_race[raw_Race],
      search_conducted = Outcome == "Search Conducted",
      # NOTE: All stops in these sources are vehicular.
      type = "vehicular",
      department_name = if_else(
        # Note: 1, 9, 10 are different State Patrol sectors,
        # 2 is local P.D., 3 is local Sheriff, 
        # 5 and 11 are parks/ag/national monuments, 
        # 12 is union pacific railroad,
        # 6 is Tribal (a corner of winnebago and omaha reservations are in iowa),
        # 7 is airport, 8 is university/campus P.D.
        raw_dept_lvl %in% c(1,5,9,10,11),
        "Nebraska State Agency",
        raw_dept
      )
    ) %>%
    standardize(d$metadata)
}
