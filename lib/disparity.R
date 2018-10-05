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
  plt(ot$results, "outcome (filtered)")
  tt <- threshold_test(d, state, city, sub_geography)
  plt(tt$results$thresholds_by_group, "thresholds (filtered: aggregate)")
}


load_data <- function() {
  eligible_cities <- tribble(
    ~state, ~city,
    "CA", "San Diego",
    "CA", "San Francisco",
    "CT", "Hartford",
    "LA", "New Orleans",
    "PA", "Philadelphia",
    "TN", "Nashville",
    "TX", "Dallas",
    "TX", "El Paso",
    "TX", "San Antonio"
  )
  opp_load_all_data(only=eligible_cities) %>%
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
      ifelse(
        city == "Hartford",
        # NOTE: data outside this range is sparse and/or unavailable
        date >= as.Date("2014-01-01")
        & as.yearmon(date) <= as.yearmon("2015-05"),
        T
      ),
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
      !(subject_race %in% c("asian/pacific islander", "other/unknown"))
    ) %>%
    mutate(
      sg = NA_character_,
      sg = if_else(city == "San Diego", service_area, sg),
      sg = if_else(city == "San Francisco", district, sg),
      sg = if_else(city == "Hartford", district, sg),
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
      threshold_test(., state, city, sub_geography)$results$thresholds_by_group
    ) %>%
    ungroup()
}


plt_all <- function(tbl, prefix) {
  output_dir <- dir_create(here::here("plots"))
  f <- function(grp) {
    title <- str_c(prefix, ": ", create_title(grp$state[1], grp$city[1]))
    fpath <- path(output_dir, str_c(title, ".pdf"))
    if (str_detect(prefix, "outcome")) {
      p <- plot_rates(grp, state, city, sub_geography)
    } else {
      p <- plot_rates(
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
    p <- plot_rates(d, state, city, sub_geography)
  } else {
    p <- plot_rates(
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
