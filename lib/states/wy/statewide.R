source(here::here("lib", "common.R"))

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
    # NOTE: Each row represents an individual event in a stop. The following
    # grouping will get us to the stop level. Combine the events (statutes
    # and charges) as a string list to summarize the stop.
    # NOTE: Old OPP chooses to group violation information by the information 
    # below plus street (but not streetnbr); after investigating a bit, there 
    # are enough minor variations in what is clearly the same street, that in 
    # our deduping, we choose not to group by this and instead to collect all 
    # those variations in the location field. This difference is minor (it leads 
    # us to have 144 fewer stops than the old OPP -- only about 0.08% of stops)
    merge_rows(
      tc_date,
      tc_time,
      offcr_id,
      emdivision,
      city,
      age,
      race,
      sex
    ) %>%
    add_raw_colname_prefix(
      race,
      sex,
      streetnbr,
      street
    ) %>% 
    rename(
      officer_id = offcr_id,
      subject_age = age
    ) %>%
    mutate(
      date = parse_date(tc_date, "%Y/%m/%d"),
      time = parse_time(tc_time, "%H%M"),
      # NOTE: Also combine street information, since minor typos and discrepancies 
      # in describing the same location overcount number of stops if included
      # in grouping
      location = str_c_na(
        str_c_na(raw_streetnbr),
        str_c_na(raw_street),
        city),
      # NOTE: `city` column actually holds county
      county_name = if_else(
        str_detect(city, "COUNTY$"),
        str_to_title(city),
        str_c(str_to_title(city), " County")
      ),
      # NOTE: deal with all the many many typos
      county_name = str_replace(county_name, "Ablany|Alabany", "Albany"),
      county_name = str_replace(county_name, "Bighorn", "Big Horn"),
      county_name = str_replace(
        county_name, 
        "Cambell|Campell|Campbelle|Capmbell", 
        "Campbell"
      ),
      county_name = str_replace(
        county_name, 
        "Carban|Carbn|Carboncounty", 
        "Carbon"
      ),
      county_name = str_replace(county_name, "Coverse", "Converse"),
      county_name = str_replace(county_name, "Laramia |Larami |Laram ", "Laramie "),
      county_name = str_replace(county_name, "Linciln|Lincon", "Lincoln"),
      county_name = str_replace(
        county_name, 
        " Coutny| Counry| Coundy| Coutry| Couinty| Country| Ounty| Cunty|( Count$)", 
        ""
      ),
      county_name = str_replace(county_name, " Co | Wy ", " "),
      department_id = emdivision,
      subject_race = tr_race[raw_race],
      subject_sex = tr_sex[raw_sex],
      # NOTE: All stops in data are vehicle stops.
      type = "vehicular",
      # NOTE: Only citations
      outcome = "citation"
    ) %>%
    standardize(d$metadata)
}
