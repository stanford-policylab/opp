source("common.R")

load_raw <- function(raw_data_dir, n_max) {
  wy2011 <- load_regex(raw_data_dir, ".*2011.csv", n_max = n_max)
  wy2012_1 <- load_single_file(raw_data_dir, "jan-june2012.csv", n_max = n_max)
  # NOTE: Second 2012 file is missing `trci_id` column but is otherwise the same.
  wy2012_2 <- load_single_file(raw_data_dir, "jul-dec2012.csv", n_max = n_max)
  bind_rows(
    wy2011$data,
    wy2012_1$data,
    wy2012_2$data
  ) %>%
  select(
    # NOTE: There are lots of empty columns from the spreadsheet conversion
    # that we drop here.
    -starts_with("X")
  ) %>%
  # NOTE: Each row represents an individual event in a stop. The following
  # grouping will get us to the stop level. Combine the events (statutes
  # and charges) as a string list to summarize the stop.
  # NOTE: Also combine street information, since minor typos and discrepancies 
  # in describing the same location overcount number of stops if included
  # in grouping
  # NOTE: Old OPP chooses to group violation information by the information below
  # plus street (but not streetnbr); after investigating a bit, there are enough
  # minor variations in what is clearly the same street, that in our deduping, we
  # choose not to group by this and instead to collect all those variations in the 
  # location field. This difference is minor (it leads us to have 144 fewer stops than
  # the old OPP -- only about 0.08% of stops)
  group_by(
    tc_date,
    tc_time,
    offcr_id,
    emdivision,
    city,
    age,
    race,
    sex
  ) %>%
  summarize(
    loc = str_c(streetnbr, " ", street, collapse = "|"),
    statute = str_c(unique(statute), collapse = '|'),
    charge = str_c(unique(charge), collapse = '|')
  ) %>%
  ungroup(
  ) %>%
  bundle_raw(c(
    wy2011$loading_problems,
    wy2012_1$loading_problems,
    wy2012_2$loading_problems
  ))
}


clean <- function(d, helpers) {
  
  tr_race = c(
    "A" = "asian/pacific islander",
    "B" = "black",
    "H" = "hispanic",
    "I" = "other/unknown",
    "U" = "other/unknown",
    "W" = "white"
  )
  
  # TODO(phoebe): can we get reason_for_stop/search/contraband fields?
  # https://app.asana.com/0/456927885748233/731173686918279
  d$data %>%
    rename(
      officer_id = offcr_id,
      violation = charge,
      subject_age = age
    ) %>%
    mutate(
      date = parse_date(tc_date, "%Y/%m/%d"),
      time = parse_time(tc_time, "%H%M"),
      # NOTE: `city` column actually holds county
      location = str_c_na(loc, city),
      county_name = if_else(
        str_detect(city, "COUNTY$"),
        str_to_title(city),
        str_c(str_to_title(city), " County")
      ),
      department_id = emdivision,
      subject_race = tr_race[race],
      subject_sex = tr_sex[sex],
      # NOTE: All stops in data are vehicle stops.
      type = "vehicular"
    ) %>%
    standardize(d$metadata)
}
