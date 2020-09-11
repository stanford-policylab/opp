source(here::here("lib", "common.R"))

# Test:
DATA_DIR <- "~/opp/data/states/il/chicago/raw_csv/"
tmp <- load_raw(DATA_DIR, 3*10^6)
tmp2 <- tmp %>%
  clean()

# Search logic:
tmp$data %>%
  select(card_no, ends_with("searched"), contraband_found_i, ends_with("found")) %>%
  # convert Y/N/NA columns to T/F
  mutate_at(vars("contraband_found_i", ends_with("searched")), ~if_else(is.na(.) | . == "N", F, T)) %>%
  # convert each search result column from character to logical
  mutate_at(vars(ends_with("found")), ~if_else(is.na(.), F, T)) %>%
  # aggregate search, contraband_found columns
  mutate(searched_colwise = rowSums(select(., ends_with("searched")), na.rm=T),
         searched_colwise = searched_colwise != 0, 
         contraband_found_colwise = rowSums(select(., ends_with("found")), na.rm=T),
         contraband_found_colwise = contraband_found_colwise != 0) %>%
  # Check:
  # - Is contraband_found_i true only if searched_colwise true? => Yes
  # - Is contraband_found_i true true if and only if contraband_found_colwise true? => Yes
  count(searched_colwise, contraband_found_i, contraband_found_colwise)


load_raw <- function(raw_data_dir, n_max) {
  # TODO incorporate isr data?
  # 1: check similarity in columns
  # 2: if similar, create method for deduplication
  
  tsss_1 <- load_single_file(
    raw_data_dir,
    "15327-p580999-traffic-isr_sheet_3.csv",
    n_max
  )
  tsss_2 <- load_single_file(
    raw_data_dir,
    "15327-p580999-traffic-isr_sheet_4.csv",
    n_max
  ) 

  tsss_1$data <- make_ergonomic_colnames(tsss_1$data)
  tsss_2$data <- make_ergonomic_colnames(tsss_2$data)
  
  bind_rows(tsss_1$data, tsss_2$data)  %>%
    distinct() %>%
    bundle_raw(c(tsss_1$loading_problems, tsss_2$loading_problems))
}

# need to process the search and contraband variables 
clean <- function(d, helpers) {
  tr_race = c(
    "AMER INDIAN / ALASKAN NATIVE" = "other",
    "ASIAN" = "asian/pacific islander",
    "HAWAIIAN/PACIFIC ISLANDER" = "asian/pacific islander",
    "BLACK" = "black",
    "HISPANIC" = "hispanic",
    "UNKNOWN" = "unknown",
    "WHITE" = "white"
  )
  
  d$data %>%
    separate(contactdate, into=c("date","time"), sep=" ") %>%
    unite(location, street_no, dir, street_nme, sep=" ") %>%
    rename(
      unit = cpd_unit_no,
      violation = statute
    ) %>%
    mutate(
      date = date(dmy(date)),
      time = parse_time(time),
      county = "Cook County",
      subject_age = year(dmy(date)) - as.numeric(year_of_birth),
      subject_race = fast_tr(race, tr_race),
      subject_sex = case_when(
        sex == "F" ~ "female",
        sex == "M" ~ "male",
        T ~ "other"
      ),
      type = "vehicular") %>%
    # search variables
    # - convert search vars from character to logical
    mutate_at(vars("contraband_found_i", ends_with("searched")), ~if_else(is.na(.) | . == "N", F, T)) %>%
    mutate_at(vars(ends_with("found")), ~if_else(is.na(.), F, T)) %>%
    # - coerce into expected names
    mutate(
      contraband_found = contraband_found_i,
      contraband_drugs = (veh_drug_found | drv_pas_drug_found),
      contraband_weapons = (veh_weapon_found | drv_pas_weapon_found),
      contraband_alcohol = (veh_alcohol_found | drv_pas_alcohol_found),
      contraband_other = (veh_other_found | drv_pas_other_found |
                            veh_paraphernalia_found | drv_pas_paraphernalia_found |
                            veh_stolen_property_found | drv_pas_stolen_property_found),
      search_person = (drv_searched | pass_searched),
      search_vehicle = veh_searched,
      search_conducted = (search_person | search_vehicle)
    ) %>%
    standardize(d$metadata) 
}
