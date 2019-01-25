source(here::here("lib", "opp.R"))
source(here::here("lib", "outcome_test.R"))
source(here::here("lib", "threshold_test.R"))
source(here::here("lib", "disparity_plot.R"))
###
source(here::here("lib", "state_validation.R"))
###

disparity <- function(state_or_city = c("state", "city")) {
  if(state_or_city == "TRUE") 
    state_or_city = c("state", "city")
  state_or_city %>% 
    map(generate_disparity_report)
}

generate_disparity_report <- function(state_or_city) {
  print(sprintf("Generating %s disparity reports.",  state_or_city))
  ###
  # old_d <- bind_rows(
  #   load_old("AZ") %>% select(-driver_age_raw),
  #   load_old("CO") %>% select(-driver_age_raw),
  #   load_old("CT") %>% select(-driver_age_raw),
  #   load_old("IL") %>% select(-driver_age_raw),
  #   load_old("MA") %>% select(-driver_age_raw),
  #   load_old("NC") %>% select(-driver_age_raw),
  #   load_old("OH") %>% select(-driver_age_raw),
  #   load_old("RI") %>% select(-driver_age_raw),
  #   load_old("SC") %>% select(-driver_age_raw),
  #   load_old("TX") %>% select(-driver_age_raw),
  #   load_old("WA") %>% select(-driver_age_raw),
  #   load_old("WI") %>% select(-driver_age_raw)
  # ) %>% 
  #   filter(driver_race %in% c("Black", "White", "Hispanic")) %>% 
  # mutate(
  #   subject_race = str_to_lower(driver_race),
  #   sg = NA_character_,
  #   sg = if_else(state == "AZ", county_name, sg),
  #   sg = if_else(state == "CO", county_name, sg),
  #   sg = if_else(state == "CT", county_name, sg),
  #   sg = if_else(state == "IL", location_raw, sg),
  #   sg = if_else(state == "MA", county_name, sg),
  #   sg = if_else(state == "NC", county_name, sg),
  #   sg = if_else(state == "OH", county_name, sg),
  #   sg = if_else(state == "RI", location_raw, sg),
  #   sg = if_else(state == "SC", county_name, sg),
  #   sg = if_else(state == "TX", county_name, sg),
  #   sg = if_else(state == "WA", county_name, sg),
  #   sg = if_else(state == "WI", county_name, sg)
  # ) %>%
  # rename(
  #   sub_geography = sg
  # )
  d_tx_old <- load_old("TX") %>% 
    mutate(sub_geography = county_name) %>% 
    filter(driver_race %in% c("Black", "White", "Hispanic"))
  d_tx_new <- opp_load_data("TX") %>% 
    mutate(sub_geography = county_name, state = "TX") %>% 
    filter(subject_race %in% c("black", "white", "hispanic"))
  ###
  # d <- read_rds(here::here("cache", str_c("disparity_data_loaded_", state_or_city, ".rds")))
  # d <- load_data(state_or_city)
  # print("Data loaded.")
  # write_rds(d, here::here("cache", str_c("disparity_unfiltered_data_loaded_", state_or_city, ".rds")))
  
  # print("Starting outcome test...")
  # ot <- outcome_test(d, state, city, sub_geography)
  # write_rds(ot, here::here("cache", str_c("disparity_", state_or_city, "outcome.rds")))
  # print(sprintf(
  #   "Results saved to: %s",
  #   here::here("cache", str_c("disparity_", state_or_city, "outcome.rds"))
  # ))
  # print("Starting local outcome test plots...")
  # plt_all(ot$results, "outcome")
  # print("Starting aggregate outcome test plot...")
  # plt(ot$results, str_c("outcome aggregate: ", state_or_city))
  
  print("Starting threshold tests...")
  # tts <- threshold_tests(d)
  ###
  tt_tx_old <- threshold_test(
    d_tx_old, state, sub_geography,
    geography_col = state,
    demographic_col = driver_race,
    action_col = search_conducted,
    outcome_col = contraband_found,
    majority_demographic = "White"
  )
  write_rds(tt_tx_old, here::here("cache", "tt_tx_old.rds"))
  tt_tx_new <- threshold_test(
    d_tx_new, state, sub_geography,
    geography_col = state,
    demographic_col = subject_race,
    action_col = search_conducted,
    outcome_col = contraband_found
  )
  write_rds(tt_tx_old, here::here("cache", "tt_tx_new.rds"))
  # print("Starting local threshold test plots...")
  # plt_all(tt_tx_old$results$thresholds, "threshold OLD (unfiltered)")
  # plt_all(tt_tx_new$results$thresholds, "threshold NEW (unfiltered)")
  # write_rds(tts_old, here::here("cache", str_c("disparity_threshold_old_data_by_", state_or_city, ".rds")))
  ###
  # write_rds(tts, here::here("cache", str_c("disparity_threshold_by_", state_or_city, ".rds")))
  # tt <- threshold_test(d, state, city, sub_geography)
  # write_rds(tt, here::here("cache", str_c("disparity_unfiltered", state_or_city, "threshold.rds")))
  # print(sprintf(
  #   "Results saved to: %s", 
  #   here::here("cache", str_c("disparity_", state_or_city, "threshold.rds"))
  # ))
  # print("Starting local threshold test plots...")
  # plt_all(tt$results$thresholds, "threshold (unfiltered)")
  # print("Starting aggregate threshold test plot...")
  # plt(tt$results$thresholds, str_c("threshold (unfiltered) aggregate: ", state_or_city))
}

load_data <- function(state_or_city) {
  if(state_or_city == "state") load_state_data()
  else if(state_or_city == "city") load_city_data()
  else print("Error in disparity load_data: Speficy state or city")
}

load_city_data <- function() {
  eligible_cities <- tribble(
    ~state, ~city,
    "CA", "San Diego",
    "CA", "San Francisco",
    # "CT", "Hartford",
    "LA", "New Orleans",
    "PA", "Philadelphia",
    "TN", "Nashville",
    "TX", "Dallas",
    "TX", "El Paso",
    "TX", "San Antonio"
  )
  opp_load_all_clean_data(only=eligible_cities) %>%
    filter(
      ifelse(
        city == "San Diego",
        # NOTE: 2015 only has 64.4% coverage of variables we care about
        # 2014 has over 70%
        year(date) != 2015
        # NOTE: these service areas have insufficient data
        & !(service_area %in% c("530", "630", "840", "Unknown")),
        T
      ),
      ifelse(
        city == "San Francisco",
        # NOTE: 2014 has no sub-geography
        year(date) != 2014
        # NOTE: these districts have insufficient data
        & !(district %in% c("K", "S", "T")),
        T
      ),
      # ifelse(
      #   city == "Hartford",
      #   # NOTE: data outside this range is sparse and/or unavailable
      #   date >= as.Date("2014-01-01")
      #   & as.yearmon(date) <= as.yearmon("2015-05"),
      #   T
      # ),
      ifelse(
        city == "New Orleans",
        # NOTE: data outside this range is sparse and/or unavailable
        as.yearmon(date) >= as.yearmon("2013-05")
        & as.yearmon(date) <= as.yearmon("2018-06"),
        T
      ),
      # NOTE: nothing to filter in Philadelphia
      ifelse(
        city == "Nashville",
        # NOTE: U stands for Unknown, remove these
        precinct != "U",
        T
      ),
      ifelse(
        city == "Dallas",
        # NOTE: district T has insufficent data
        district != "T",
        T
      ),
      # NOTE: El Paso is good, possiblly filter region 0 (insufficent data)
      # NOTE: San Antonio looks good
      # NOTE: remove these to compare only blacks/hispanics with whites
      !(subject_race %in% c("asian/pacific islander", "other/unknown")),
      type == "vehicular"
    ) %>%
    mutate(
      sg = NA_character_,
      sg = if_else(city == "San Diego", service_area, sg),
      sg = if_else(city == "San Francisco", district, sg),
      # sg = if_else(city == "Hartford", district, sg),
      sg = if_else(city == "New Orleans", district, sg),
      sg = if_else(city == "Philadelphia", district, sg),
      sg = if_else(city == "Nashville", precinct, sg),
      sg = if_else(city == "Dallas", district, sg),
      sg = if_else(city == "El Paso", region, sg),
      sg = if_else(city == "San Antonio", substation, sg)
    ) %>%
    rename(
      sub_geography = sg
    )
}

load_state_data <- function() {
  eligible_states <- tribble(
    ~state, ~city,
    "AZ", "Statewide",
    "CO", "Statewide",
    "CT", "Statewide",
    "IL", "Statewide",
    "MA", "Statewide",
    "NC", "Statewide",
    "OH", "Statewide",
    "RI", "Statewide",
    "SC", "Statewide",
    "TX", "Statewide",
    "WA", "Statewide",
    "WI", "Statewide"
  )
  print("Loading eligible states...")
  opp_load_all_clean_data(only=eligible_states) %>% 
    filter(
      if_else(
        # NOTE: old OPP doesn't use AZ because the contraband data is too messy
        # Our contraband data, while indeed a little messy, seems reasonable.
        state == "AZ",
        # NOTE: 2009 and 2010 have insufficient data
        year(date) >= 2011
        # NOTE: remove non-discretionary searches
        # & (is.na(search_basis) | search_basis != "other")
        # NOTE: don't use NA county (15 non-NA counties, account for ~90%)
        & !is.na(county_name)
        # NOTE: these counties have insufficient data for all races
        & !county_name %in% c("Greenlee County")
        # NOTE: these counties have insufficient data for one race
        & !(county_name %in% c("Gila County", "Graham County", "Santa Cruz County")
            & subject_race == "black"),
        T
      ),
      if_else(
        state == "CO",
        # NOTE: remove non-discretionary searches
        # (is.na(search_basis) | search_basis != "other")
        # NOTE: remove the stops for which a search was conducted but we don't have
        # contraband recovery info
         !(search_conducted & is.na(contraband_found))
        # NOTE: these counties have insufficient data for 2 or all 3 races
        & !county_name %in% c(
          "Archuleta County", "Baca County", "Bent County", "Broomfield County",
          "Cheyenne County", "Crowley County", "Denver County", "Dolores County",
          "Fremont County", "Gilpin County", "Grand County", "Gunnison County",
          "Jackson County", "Kiowa County", "Lake County", "Mineral County",
          "Otero County", "Ouray County", "Park County", "Phillips County",
          "Pitkin County", "Rio Blanco County", "Saguache County", "San Juan County",
          "San Miguel County", "Sedgwick County", "Teller County", "Washington County",
          "Yuma County"
        )
        # NOTE: these counties have insufficient data for one race
        & !(county_name %in% c(
            "Adams County", "Alamosa County", "Boulder County", "Chaffee County",
            "Clear Creek County", "Costilla County", "Delta County", "Elbert County",
            "Huerfano County", "La Plata County", "Las Animas County", "Moffat County",
            "Montezuma County", "Montrose County", "Prowers County", "Rio Grande County",
            "Routt County"
            )
          & subject_race == "black"),
        T
      ),
      if_else(
        state == "CT",
        # NOTE: use just state patrol stops
        department_name == "State Police"
        # NOTE: remove non-discretionary searches (5% of searches)
        # NOTE: keeps searches for which search basis is not given (~7%)
        # & (is.na(search_basis) | search_basis != "other")
        # NOTE: all counties are fine; just filter the 1 NA entry
        & !is.na(county_name),
        T
      ),
      if_else(
        state == "IL",
        # NOTE: we're missing state patrol stops from 2013
        # NOTE: we don't have information on non-discretionary searches
        # NOTE: use just state patrol stops
        department_name == "ILLINOIS STATE POLICE"
        # NOTE: these police districts have insufficient data for 2 or all 3 races
        & !beat %in% c("0", "00", "93", "99", "D2")
        # NOTE: these districts have insufficient data for one race
        & !(beat %in% c("19") & subject_race == "hispanic"),
        T
      ),
      if_else(
        state == "MA",
        # NOTE: old OPP says contraband info is too messy; seems reasonable to me
        # NOTE: remove non-discretionary searches (32% of searches)
        # NOTE: keeps searches for which search basis is not given (~9%)
        # (is.na(search_basis) | search_basis != "other")
        # NOTE: these counties have insufficient data for 2 or all 3 races
         !county_name %in% c("Dukes", "Nantucket")
        & !is.na(county_name),
        T
      ),
      if_else(
        state == "NC",
        # NOTE: use just state patrol stops
        department_name == "NC State Highway Patrol"
        # NOTE: remove non-discretionary searches (68% of searches)
        # & (is.na(search_basis) | search_basis != "other")
        # NOTE: these counties have insufficient data for 2 or all 3 races
        & !county_name %in% c(
          "Ashe County", "Chowan County", "Clay County", "Dare County", "Graham County",
          "Hyde County", "Jackson County", "Lincoln County", "Macon County",
          "Madison County", "Mitchell County", "Moore County", "Perquimans County",
          "Polk County", "Rutherford County", "Stanly County", "Swain County",
          "Transylvania County", "Vance County", "Warren County", "Watauga County",
          "Wilkes County", "Yancey County"
        )
        & !is.na(county_name)
        # NOTE: these counties have insufficient data for one race
        & !(county_name %in% c("Avery County", "Yadkin County") & subject_race == "black")
        & !(county_name %in% c(
            "Granville County", "Hertford County", "Iredell County", "New Hanover County",
            "Northampton County", "Orange County", "Pamlico County", "Pasquotank County",
            "Pender County", "Person County", "Scotland County", "Tyrell County",
            "Union County", "Washington County"
          ) & subject_race == "hispanic"),
        T
      ),
      if_else(
        state == "OH",
        # NOTE: old opp excludes because only search reasons listed are k9 and consent,
        # which they say makes them skeptical of the recording scheme;
        # however, 87% of searches are not labeled -- we call default them to probable cause,
        # but regardless, it seems reasonable to assume that all searches are indeed
        # being tallied up, but i would not trust the search_basis categorization itself.
        # Thus we _do_ use OH in our analysis
        # NOTE: if not listed as k9 or consent search, we deem the search probable cause
        # i.e., we don't know if a search is incident to arrest or not.
        # NOTE: these counties have insufficient data for 2 or all 3 races
        !county_name %in% c(
          "Adams County", "Carroll County", "Coshocton County", "Darke County",
          "Holmes County", "Mercer County", "Monroe County", "Morgan County",
          "Putnam County", "Vinton County"
        )
        & !is.na(county_name)
        # NOTE: these counties have insufficient data for one race
        & !(county_name %in% c("Henry County") & subject_race == "black")
        & !(county_name %in% c(
            "Athens County", "Belmont County", "Champaign County", "Columbiana County",
            "Crawford County", "Fayette County", "Gallia County", "Hardin County",
            "Harrison County", "Highland County", "Hocking County", "Jefferson County",
            "Lawrence County", "Logan County", "Marion County", "Meigs County",
            "Noble County"
          ) & subject_race == "hispanic"),
        T
        # NOTE: when contraband wasn't found after a search it was labeled NA
        # we fix this after the mega filter statement
      ),
      if_else(
        state == "RI",
        # NOTE: remove non-discretionary searches (49% of searches)
        # (is.na(search_basis) | search_basis != "other"),
        # NOTE: use zone (no county info) -- 6 zones, all ok
        !is.na(zone),
        T
      ),
      if_else(
        state == "SC",
        # NOTE: all counties ok
        !is.na(county_name),
        T
      ),
      if_else(
        state == "TX",
        # NOTE: remove non-discretionary searches (28% of searches)
        # NOTE: keep searches for which search basis is not given (<<<1%)
        # (is.na(search_basis) | search_basis != "other")
        # NOTE: these counties have insufficient data for 2 or all 3 races
         !county_name %in% c(
          "Borden", "Foard", "Hansford", "Kent", "King", "Lipscomb", "Loving",
          "Sabine"
        )
        & !is.na(county_name)
        # NOTE: these counties have insufficient data for one race
        & !(county_name %in% c(
            "Bandera", "Briscoe", "Castro", "Cochran", "Coke", "Concho", "Edwards",
            "Glasscock", "Hemphill", "Irion", "Jeff Davis", "Jim Hogg", "McMullen",
            "Menard", "Ochiltree", "Presidio", "Reagan", "Real", "Roberts", "San Saba",
            "Schleicher", "Shackelford", "Somervell", "Stephens", "Stonewall", "Terrell",
            "Throckmorton", "Upton", "Zapata"
          ) & subject_race == "black"),
        T
      ),
      if_else(
        state == "WA",
        # NOTE: remove non-discretionary searches (95%?!?!?)
        # (is.na(search_basis) | search_basis != "other")
        # NOTE: these counties have insufficient data for 2 or all 3 races
         !county_name %in% c(
          "Asotin", "Columbia", "Ferry", "Garfield", "Pend Oreille", "Skamania",
          "Stevens", "Wahkiakum"
        )
        & !is.na(county_name)
        # NOTE: these counties have insufficient data for one race
        & !(county_name %in% c(
          "Douglas", "Klickitat", "Pacific", "Walla Walla"
        ) & subject_race == "black"),
        T
      ),
      if_else(
        state == "WI",
        # NOTE: 2010 is too sparse to trust
        year(date) > 2010
        # NOTE: remove non-discretionary searches (33%)
        # NOTE: keep searches for which search basis is not given (<<<1%)
        # & (is.na(search_basis) | search_basis != "other")
        # NOTE: these counties have insufficient data for 2 or all 3 races
        & !county_name %in% c(
          "ADAMS", "ASHLAND", "BARRON", "BAYFIELD", "BUFFALO", "BURNETT", "CALUMET",
          "CHIPPEWA", "CLARK", "CRAWFORD", "DOOR", "DOUGLAS", "FOREST", "GREEN LAKE",
          "IOWA", "IRON", "JUNEAU", "KEWAUNEE", "LAFAYETTE", "LANGLADE", "LINCOLN",
          "MARINETTE", "MARQUETTE", "OCONTO", "ONEIDA", "OZAUKEE", "PEPIN", "PIERCE",
          "POLK", "PRICE", "RICHLAND", "RUSK", "SAWYER", "SHAWANO", "TAYLOR", "VERNON",
          "VILAS", "WASHBURN", "WASHINGTON", "WAUPACA", "WAUSHARA"
        )
        & !is.na(county_name)
        # NOTE: these counties have insufficient data for one race
        & !(county_name %in% c(
          "DODGE", "EAU CLAIRE", "FOND DU LAC", "GRANT", "MANITOWOC", "MARATHON",
          "MONROE", "TREMPEALEAU", "WINNEBAGO", "WOOD"
        ) & subject_race == "hispanic")
        & !(county_name %in% c(
          "WALWORTH"
        ) & subject_race == "black"),
        T
      ),
      # NOTE: compare only blacks/hispanics with whites
      subject_race %in% c("black", "white", "hispanic"),
      type == "vehicular"
    ) %>%
    mutate(
      # If a search was conducted and we don't have contraband info,
      # assume no contraband was found
      contraband_found = if_else(
        search_conducted,
        replace_na(contraband_found, FALSE),
        contraband_found
      ),
      sg = NA_character_,
      sg = if_else(state == "AZ", county_name, sg),
      sg = if_else(state == "CO", county_name, sg),
      sg = if_else(state == "CT", county_name, sg),
      sg = if_else(state == "IL", beat, sg),
      sg = if_else(state == "MA", county_name, sg),
      sg = if_else(state == "NC", county_name, sg),
      sg = if_else(state == "OH", county_name, sg),
      sg = if_else(state == "RI", zone, sg),
      sg = if_else(state == "SC", county_name, sg),
      sg = if_else(state == "TX", county_name, sg),
      sg = if_else(state == "WA", county_name, sg),
      sg = if_else(state == "WI", county_name, sg)
    ) %>%
    rename(
      sub_geography = sg
    )
}

outcome_tests <- function(d) {
  d %>%
    group_by(state, city) %>%
    do(
      outcome_test(., state, city, sub_geography)$results
    ) %>%
    ungroup()
}


threshold_tests <- function(d) {
  # NOTE: Runs threshold test on each location individually.
  # For the multi-location hierarchical threshold test, call
  # threshold_test(...) on the data, directly. 
  d %>%
    group_by(state, city) %>%
    do(
      threshold_test(
        ., state, sub_geography,
        geography_col = city,
        demographic_col = subject_race,
        action_col = search_conducted,
        outcome_col = contraband_found
      )$results$thresholds
    ) %>%
    ungroup()
}


plt_all <- function(tbl, prefix) {
  output_dir <- dir_create(here::here("plots"))
  f <- function(grp) {
    title <- str_c(prefix, ": ", create_title(grp$state[1], grp$city[1]))
    fpath <- path(output_dir, str_c(title, ".pdf"))
    if (str_detect(prefix, "outcome")) {
      str_city <- unique(grp$city)
      str_state <- unique(grp$state)
      p <- disparity_plot(
        grp, state, city, sub_geography, 
        title = str_c(str_city, " ", str_state, " Contraband recovery rates by sub-geography")
      )
    } else {
      p <- disparity_plot(
        grp,
        state, city, sub_geography,
        demographic_col = subject_race,
        rate_col = threshold,
        size_col = n_action,
        title = title,
        axis_title = "threshold"
      )
    }
    ggsave(fpath, p, width=12, height=6, units="in")
    print(str_c("saved: ", fpath))
    grp
  }
  group_by(tbl, state, city) %>% do(f(.)) %>% ungroup()
}


plt <- function(d, prefix) {
  output_dir <- dir_create(here::here("plots"))
  fpath <- path(output_dir, str_c(prefix, ".pdf"))
  if (str_detect(prefix, "outcome")) {
    p <- disparity_plot(d, state, city, sub_geography)
  } else {
    p <- disparity_plot(
      d,
      state, city, sub_geography,
      demographic_col = subject_race,
      rate_col = threshold,
      size_col = n_action,
      title = prefix,
      axis_title = "threshold"
    )
  }
  ggsave(fpath, p, width=12, height=6, units="in")
  print(str_c("saved: ", fpath))
  p
}

