source("opp.R")
source("outcome_test.R")
source("threshold_test.R")
source("disparity_plot.R")


disparity <- function() {
  d <- load_data()
  
  ots <- outcome_tests(d)
  plt_all(ots, "outcome (filtered)")
  tts <- threshold_tests(d)
  plt_all(tts, "threshold (filtered)")
  plt(tts, "thresholds (filtered: all cities)")

  ot <- outcome_test(d, state, city, sub_geography)
  plt(ot$results, "test - outcome (filtered)")
  tt <- threshold_test(d, state, city, sub_geography)
  plt(tt$results$thresholds, "test - thresholds (filtered: aggregate)")
}


load_data <- function() {
  eligible_states <- tribble(
    ~state, ~city,
    "CO", "Statewide",
    "CT", "Statewide",
    "IL", "Statewide",
    "NC", "Statewide",
    "RI", "Statewide",
    "SC", "Statewide",
    "TX", "Statewide",
    "WA", "Statewide",
    "WI", "Statewide"
  )
  opp_load_all_clean_data(only=eligible_states) %>%
    filter(
      # NOTE: CO is taken to be entirely state patrol; nothing to filter
      ifelse(
        state == "CT",
        !is.na(county_name) &
        department_name == "State Police",
        T
      ),
      ifelse(
        state == "IL",
        department_name == "ILLINOIS STATE POLICE",
        # NOTE: We're missing IL state patrol data for 2013
        # NOTE: No county name; use beat instead: 
        # http://www.isp.state.il.us/districts/districtfinder.cfm
        T
      ),
      ifelse(
        state == "NC",
        department_name == "NC State Highway Patrol"
        # NOTE: 2003-2006 (trickling into 2007 and 2008), many of the state 
        # highway patrol stops were listed under 
        # department_name == "SHP - Motor Carrier Enforcement Section"
        # For consistency, we start our NC analysis at 2009
        & year(date) >= 2009,
        T
      ),
      ifelse(
        city == "New Orleans",
        # NOTE: data outside this range is sparse and/or unavailable
        as.yearmon(date) >= as.yearmon("2013-05")
        & as.yearmon(date) <= as.yearmon("2018-06"),
        T
      ),
      # NOTE: El Paso is good, possiblly filter region 0 (insufficent data)
      # NOTE: San Antonio looks good
      # NOTE: remove these to compare only blacks/hispanics with whites
      subject_race %in% c("black", "white", "hispanic")
    ) %>%
    mutate(
      sg = NA_character_,
      sg = if_else(state == "CO", county_name, sg),
      sg = if_else(state == "CT", county_name, sg),
      sg = if_else(state == "IL", beat, sg),
      sg = if_else(state == "NC", district, sg),
      sg = if_else(state == "RI", county_name, sg),
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
  d %>%
    group_by(state, city) %>%
    do(
      threshold_test(., state, city, sub_geography)$results$thresholds
    ) %>%
    ungroup()
}


plt_all <- function(tbl, prefix) {
  output_dir <- dir_create(here::here("plots"))
  f <- function(grp) {
    title <- str_c(prefix, ": ", create_title(grp$state[1], grp$city[1]))
    fpath <- path(output_dir, str_c(title, ".pdf"))
    if (str_detect(prefix, "outcome")) {
      p <- disparity_plot(grp, state, city, sub_geography)
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
}
