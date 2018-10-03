source("opp.R")
source("outcome_test.R")
source("threshold_test.R")
source("disparity_plot.R")


main <- function() {
  d <- load_data()

  ots <- individual_outcome_tests(d)
  tts <- individual_threshold_tests(d)
  plt_each(ots, "outcome")
  plt_each(tts, "threshold")

  ot <- outcome_test(d, sub_geography)
  tt <- threshold_test(d, sub_geography)
  plt(ot, "outcome")
  plt(tt, "threshold")
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
    ) %>%
    filter(
      search_conducted,
      !is.na(contraband_found),
      !is.na(subject_race),
      !is.na(sub_geography)
    )
}


individual_outcome_tests <- function(d) {
  d %>%
    group_by(state, city) %>%
    summarize(results = outcome_test(., sub_geography))
}


individual_threshold_tests <- function(d) {
  d %>%
    group_by(state, city) %>%
    summarize(results = threshold_test(., sub_geography))
}


plt_each <- function(ds, prefix) {
  f <- (state, city, d) {plt(d, str_c(prefix, "_", create_title(state, city)))}
  par_pmap(ds, f)
}


plt <- function(d, prefix) {
  output_dir <- dir_create(here:here("plots"))
  fpath <- path(output_dir, str_c(prefix, ".png"))
  p <- disparity_plot(d$results, sub_geography)
  ggsave(p, fpath)
}
