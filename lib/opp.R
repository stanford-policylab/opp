library(here)
source(here::here("lib", "common.R"))


clear <- function() {
  env = globalenv()
  rm(list=ls(envir = env), envir = env)
  source("opp.R")
}
cl <- clear


for_filename <- function(state, city) {
  str_c(normalize_state(state), "_", normalize_city(city))
}


has_files <- function(dir) {
  dir.exists(dir) & length(list.files(dir)) > 0
}


normalize_city <- function(city) {
  str_to_lower(str_replace(city, " ", "_"))
}


normalize_state <- function(state) {
  str_to_lower(state)
}


opp_add_contraband_types_func <- function(state, city = "statewide") {
  function(tbl, join_col) {
    join_on <- c("text")
    names(join_on) <- c(join_col)
    add_data(
      tbl,
      opp_load_csv_func(state, city)("contraband_types.csv"),
      join_on,
      col_types = "iic",
      rename_map = c(
        "d" = "contraband_drugs",
        "w" = "contraband_weapons",
        "a" = "contraband_alcohol",
        "o" = "contraband_other"
      )
    )
  }
}


opp_add_county_from_highway_milepost_func <- function(
  state,
  city = "statewide"
) {
  function(
    tbl,
    highway_col = "highway",
    milepost_col = "milepost",
    mapping_csv = "highway_milepost_county.csv",
    mapping_highway_col = "highway",
    mapping_min_milepost_col = "min_milepost",
    mapping_max_milepost_col = "max_milepost",
    mapping_county_col = "county"
  ) {
    # NOTE: assumes mapping_csv has closed, open limits for milemarkers,
    # [a, b), i.e. [0, 80) => milemarkers 0-79
    mp <- opp_load_csv_func(state, city)(mapping_csv)
    # these have to be numeric, otherwise the filter below doesn't work
    tbl[[milepost_col]] <- as.numeric(tbl[[milepost_col]])
    mp[[mapping_min_milepost_col]] <- as.numeric(mp[[mapping_min_milepost_col]])
    mp[[mapping_max_milepost_col]] <- as.numeric(mp[[mapping_max_milepost_col]])

    # join on the highway, then filter using min_mp < mp < max_mp
    join_on <- c(mapping_highway_col)
    names(join_on) <- c(highway_col)
    mp <- distinct(
      tbl[c(highway_col, milepost_col)]
    ) %>%
    left_join(
      mp,
      by = join_on
    ) %>%
    filter_(str_c(
      milepost_col, " >= ", mapping_min_milepost_col,
      " & ",
      milepost_col, " < ", mapping_max_milepost_col
    )) %>%
    select_(
      highway_col,
      milepost_col,
      mapping_county_col
    ) %>%
    distinct(
    ) %>%
    na.omit()

    left_join(tbl, mp)
  }
}


opp_add_lat_lng_func <- function(state, city = "statewide") {
  function(tbl, join_col = "location") {
    join_on <- c("loc")
    names(join_on) <- c(join_col)
    locs <- opp_load_csv_func(state, city)(
      "geocoded_locations_sanitized.csv",
      col_types = "cdd"
    ) %>%
    filter(!is.na(loc))

    add_data(
      tbl,
      locs,
      join_on,
      col_types = "cdd"
    )
  }
}


opp_add_search_basis_func <- function(state, city = "statewide") {
  function(tbl, join_col) {
    join_on <- c("text")
    names(join_on) <- c(join_col)
    add_data(
      tbl,
      opp_load_csv_func(state, city)("search_basis.csv"),
      join_on,
      col_types = "cc",
      rename_map = c("label" = "search_basis"),
      translators = list(
        "search_basis" = c(
          k9 = "k9",
          pv = "plain view" ,
          cn = "consent",
          pc = "probable cause",
          o = "other"
        )
      )
    )
  }
}


opp_add_shapefiles_data_func <- function(state, city = "statewide") {
  function(tbl) {
    source(here::here("lib", "shapefiles.R"), local = TRUE)
    shapes_dfs <- opp_load_all_shapefiles_dfs(state, city)
    for (shapes_df in shapes_dfs) {
      tbl <- add_shapes_df_data(
          tbl,
          shapes_df,
          "lng",
          "lat"
        )
    }
    tbl
  }
}


opp_add_type_func <- function(state, city) {
  function(tbl, join_col = "reason_for_stop") {
    join_on <- c("text")
    names(join_on) <- c(join_col)
    add_data(
      tbl,
      opp_load_csv_func(state, city)("types.csv"),
      join_on,
      col_types = "cc",
      rename_map = c("label" = "type"),
      translators = list(
        "type" = c(
          p = "pedestrian",
          v = "vehicular",
          o = "other"
        )
      )
    )
  }
}


opp_apply <- function(func, only = NULL) {
  if (is.null(only)) { only <- opp_available() }
  par_pmap(only, func)
}


opp_available <- function() {
  paths <- opp_data_paths()
  tibble(
    state = simple_map(paths, opp_extract_state_from_path),
    # NOTE: city could be 'statewide' too 
    city = simple_map(paths, opp_extract_city_from_path)
  ) %>%
  anti_join(
    opp_bad_data()
  )
}


opp_bad_data <- function() {
  tribble(
    ~state, ~city,
    "TX", "El Paso", # numbers too high, don't align with external reports
    "TX", "Fort Worth", # precipitous decline yoy
    "TX", "Dallas", # too many stops
    "WI", "Green Bay", # only a sample
  )
}


opp_bunching_report <- function() {
  print("building report...")
  output_dir <- dir_create(here::here("reports"))
  render(
    "bunching_report.Rmd",
    "pdf_document",
    file.path(output_dir, "bunching.pdf")
  )
}


opp_calculated_features_path <- function(state, city = "statewide") {
  data_dir <- opp_data_dir(state, city)
  file.path(data_dir, "calculated_features")
}


opp_city_demographics <- function(state, city) {
  state_query <- str_to_upper(state)
  city_fmt <- str_to_title(str_replace(city, "Saint", "St."))
  city_query <- str_c("^", city_fmt, " (city|town)$")
  # NOTE: https://en.wikipedia.org/wiki/Nashville-Davidson_(balance),_Tennessee
  if (city_fmt == "Nashville")
    city_query <- "Nashville-Davidson metropolitan government"
  tbl <-
    opp_load_acs_race_data("acs_2017_5_year_city_level_race_data.csv") %>%
    filter(state_abbreviation == state_query, str_detect(place, city_query))
  if (nrow(tbl) != length(valid_races))
    stop(str_c("Demographic query for ", city_fmt, ", ", state_fmt, " failed!"))
  tbl
}


opp_city_population <- function(state, city) {
  sum(opp_city_demographics(state, city)$population)
}


opp_clean <- function(d, state, city = "statewide") {
  source(opp_processor_path(state, city), local = TRUE)
  helpers <- c(
    "add_lat_lng" = opp_add_lat_lng_func(state, city),
    "add_search_basis" = opp_add_search_basis_func(state, city),
    "add_type" = opp_add_type_func(state, city),
    "add_contraband_type" = opp_add_contraband_types_func(state, city),
    "add_shapefiles_data" = opp_add_shapefiles_data_func(state, city),
    "add_county_from_highway_milepost" = 
      opp_add_county_from_highway_milepost_func(state, city),
    "fips_to_county_name" = opp_fips_to_county_name_func(state),
    "load_json" = opp_load_json_func(state, city),
    "load_csv" = opp_load_csv_func(state, city)
  )
  clean(d, helpers)
}


opp_clean_data_path <- function(state, city = "statewide") {
  # NOTE: all clean data is stored and loaded in RDS format to
  # maintain data types
  clean_data_dir <- dir_create(path(opp_data_dir(state, city), "clean"))
  path(clean_data_dir, str_c(normalize_city(city), ".rds"))
}


opp_county_demographics <- function(state, county) {
  # TODO(danj,amyshoe): spot check
  state_query <- str_to_upper(state)
  county_query <- str_c("^", str_to_title(county), " (County)$")
  tbl <-
    opp_load_acs_race_data("acs_2017_5_year_county_level_race_data.csv") %>%
    filter(state_abbreviation == state_query, str_detect(place, county_query))
  if (nrow(tbl) != length(valid_races))
    stop(str_c("Demographic query for ", state, ", ", county, " failed!"))
}


opp_county_population <- function(state, county) {
  sum(opp_county_demographics(state, county)$population)
}


opp_coverage <- function() {
  print("generateing coverage report...")
  dir_create(here::here("reports"))
  output_path <- here::here("reports", "coverage.pdf")
  render(
    "coverage.Rmd",
    "pdf_document",
    output_path
  )
  print(str_c("saved coverage report to ", output_path))
}


opp_data_dir <- function(state, city = "statewide") {
  dir_create(here::here(
    "data",
    "states",
    normalize_state(state),
    normalize_city(city)
  ))
}


opp_data_paths <- function() {
  paths <- list.files(here::here("data"), ".*\\.rds$", recursive = T)
  here::here("data", paths[str_detect(paths, "clean")])
}


opp_download_all_data <- function() {
  opp_apply(opp_download_data)
}


opp_download_analyses_data <- function() {
  opp_apply(
    opp_download_data,
    opp_locations_used_in_analyses()
  )
}


opp_download_data <- function(state, city) {
  if (!link_exists(here::here("data")))
    opp_set_download_directory("/tmp/opp_data")
  output_path <- opp_clean_data_path(state, city)
  if (!file_exists(output_path)) {
    pattern <- str_c(normalize_state(state), normalize_city(city), sep = "_")
    urls <- opp_download_urls(state, city)
    url <- urls[str_detect(urls, "\\.rds")]
    download.file(url, output_path)
  }
}


opp_download_urls <- function(state, city) {
  prefix <- "https://embed.stanford.edu/iframe?url="
  if (city == "Statewide")
    purl <- str_c(prefix, "https://purl.stanford.edu/jb084sr9005")
  else
    purl <- str_c(prefix, "https://purl.stanford.edu/tr137st9964")
  html <- str_c(readLines(purl), collapse = "\n")
  urls <- str_match_all(html, '<a href="(.*?)"')[[1]][,2]
  pattern <- str_c(normalize_state(state), normalize_city(city), sep = "_")
  unique(urls[str_detect(urls, pattern)])
}


opp_eligibility <- function(tbl) {

  filter(
    tbl,
    search_conducted,
    !is.na(date)
  ) %>%
  mutate(
    action_outcome = !is.na(subject_race) & !is.na(contraband_found),
    ao = action_outcome,
    neighborhood = ao & !is.na(neighborhood),
    beat = ao & !is.na(beat),
    district = ao & !is.na(district),
    subdistrict = ao & !is.na(subdistrict),
    division = ao & !is.na(division),
    subdivision = ao & !is.na(subdivision),
    police_grid_number = ao & !is.na(police_grid_number),
    precinct = ao & !is.na(precinct),
    region = ao & !is.na(region),
    reporting_area = ao & !is.na(reporting_area),
    sector = ao & !is.na(sector),
    subsector = ao & !is.na(subsector),
    service_area = ao & !is.na(service_area),
    zone = ao & !is.na(zone),
    county_name = ao & !is.na(county_name),
    department_id = ao & !is.na(department_id),
    department_name = ao & !is.na(department_name)
  ) %>%
  select(
    -ao
  ) %>%
  group_by(
    state,
    city,
    year = year(date)
  ) %>%
  summarize(
    n_searches = n(),
    neighborhood = mean(neighborhood),
    beat = mean(beat),
    district = mean(district),
    subdistrict = mean(subdistrict),
    division = mean(division),
    subdivision = mean(subdivision),
    police_grid_number = mean(police_grid_number),
    precinct = mean(precinct),
    region = mean(region),
    reporting_area = mean(reporting_area),
    sector = mean(sector),
    subsector = mean(subsector),
    service_area = mean(service_area),
    zone = mean(zone),
    county_name = mean(county_name),
    department_id = mean(department_id),
    department_name = mean(department_name)
  ) %>%
  ungroup(
  )
}


opp_extract_city_from_path <- function(path) {
  tokens <- tokenize_path(path)
  format_proper_noun(str_replace(
    tokens[which(tokens == "states") + 2], 
    ".R",
    ""
  ))
}


opp_extract_state_from_path <- function(path) {
  tokens <- tokenize_path(path)
  toupper(tokens[which(tokens == "states") + 1])
}


opp_filter_out_non_highway_patrol_stops_from_states <- function(tbl) {
  only <- function(x, y) x == y
  exclude <- function(x, y) x != y
  f <- function(tbl, s, operator, dep_name) {
    if ("department_name" %in% colnames(tbl))
      tbl <- filter(
          tbl,
          ifelse(
            state == s & city == "Statewide",
            operator(department_name, dep_name),
            T
          )
        )
    tbl
  }
  tbl %>%
    f("FL", exclude, "FLORIDA DEPARTMENT OF AGRICULTURE") %>%
    f("NC", only, "NC State Highway Patrol") %>%
    f("IL", only, "ILLINOIS STATE POLICE") %>%
    f("CT", only, "State Police")
} 


opp_fips_to_county_name_func <- function(state) {
  # NOTE: uses 2010 FIPS codes for counties:
  # https://www.census.gov/geo/reference/codes/cou.html
  fips <- read_csv(
    here::here("resources", "fips_county.csv"),
    col_types = cols_only(STATE = "c", COUNTYFP = "c", COUNTYNAME = "c")
  ) %>%
  filter(
    STATE == toupper(state)
  ) %>%
  select(county_name = COUNTYNAME, county_code = COUNTYFP)
  function(tbl, county_code_col = "county_code") {
    tbl %>%
      mutate(
        # NOTE: Normalize county codes to use left 0-padding for join.
        county_code = str_pad(tbl[[county_code_col]], 3, "left", "0")
      ) %>%
      left_join(
        fips,
        by = c("county_code" = "county_code")
      )
  }
}


opp_load <- function(state, city) {
  raw_data <- opp_load_raw_data(state, city)
  colnames(raw_data) <- add_prefix(
    colnames(raw_data),
    prefix = "raw_",
    skip = c("raw_row_number")
  )

  d <- opp_load_clean(state, city)

  d$data <- left_join(
    raw_data,
    mutate(
      d$data,
      raw_row_number = str_split(raw_row_number, "\\|")
    ) %>%
    unnest(
    ) %>%
    mutate(
      raw_row_number = as.integer(raw_row_number)
    )
  ) %>%
  # NOTE: moves all raw columns to the end of the tibble
  select(
    -matches("^raw_"),
    everything()
  )

  d
}


opp_load_acs_race_data <- function(fname) {
  # NOTE: to get the data:
  # 1. factfinder.census.gov -> Advanced Search
  # 2. Topics -> Datasets -> ACS 5 year estimate 2017
  # 3. Geographies -> Place -> All places in United States
  # 4. Race and Ethnic groups -> Hispanic or Latino 
  # 5. HISPANIC OR LATINO ORIGIN BY RACE
  # 6. Add descriptive column names; do not put annotations in same file
  # 7. Unzip and rename file ACS_17_5YR_<X>.csv
  # 8. Delete first line of non-descriptive headers
  tbl <-
    read_csv(
      here::here("resources", fname)
    ) %>%
    select(
      -Id,
      -Id2,
      -matches("Margin of Error")
    ) %>%
    rename_all(
      funs(str_replace(., "Estimate; Not Hispanic or Latino: - ", ""))
    ) %>%
    rename(
      place = Geography,
      non_hispanic = `Estimate; Not Hispanic or Latino:`,
      white = `White alone`,
      black = `Black or African American alone`,
      asian = `Asian alone`,
      pacific_islander = `Native Hawaiian and Other Pacific Islander alone`,
      hispanic = `Estimate; Hispanic or Latino:`
    ) %>%
    mutate(
      `asian/pacific islander` = asian + pacific_islander,
      `other/unknown` = non_hispanic - white - black - `asian/pacific islander`
    ) %>%
    select(
      place,
      white,
      black,
      hispanic,
      `asian/pacific islander`,
      `other/unknown`
    ) %>%
    gather(
      race,
      population,
      -place
    )

  if (str_detect(fname, "state_level"))
    tbl <- rename(tbl, state = place)
  else
    tbl <- separate(tbl, place, c("place", "state"), sep = ", ")

  left_join(
    tbl,
    opp_load_state_fips()
  ) %>%
  rename(
    state_abbreviation = abbreviation
  )
}


opp_load_all_clean_data <- function(only = NULL) {
  opp_load_all_data(only, include_raw = F)
}


opp_load_all_data <- function(only = NULL, include_raw = T) {
  load_func <- ifelse(include_raw, opp_load_data, opp_load_clean_data)
  if (is.null(only)) { only <- opp_available() }
  bind_rows(
    par_pmap(
      only,
      function(state, city) {
        mutate(
          load_func(state, city),
          state = state,
          city = city
        )
      }
    )
  )
}


opp_load_all_shapefiles_dfs <- function(state, city = "statewide") {
  source(here::here("lib", "shapefiles.R"), local = TRUE)
  load_all_shapefiles_dfs(opp_shapefiles_dir(state, city))
}


opp_load_clean <- function(state, city = "statewide") {
  readRDS(opp_clean_data_path(state, city))
}


opp_load_clean_data <- function(state, city = "statewide") {
  opp_load_clean(state, city)$data
}


opp_load_csv_func <- function(state, city = "statewide") {
  function(
    csv_filename,
    n_max = Inf,
    col_types = cols(.default = "c"),
    col_names = TRUE,
    skip = 0,
    na = c("", "NA")
  ) {
    read_csv(
      file.path(opp_calculated_features_path(state, city), csv_filename),
      col_types = col_types,
      col_names = col_names,
      skip = skip,
      na = na
    )
  }
}


opp_load_data <- function(state, city) {
  opp_load(state, city)$data
}


opp_load_json_func <- function(state, city = "statewide") {
  function(json_filename) {
    fromJSON(file.path(
      opp_calculated_features_path(state, city),
      json_filename
    ))
  }
}


opp_load_raw <- function(state, city = "statewide", n_max = Inf) {
  source(opp_processor_path(state, city), local = TRUE)
  load_raw(opp_raw_data_dir(state, city), n_max)
}


opp_load_raw_data <- function(state, city = "statewide", n_max = Inf) {
  opp_load_raw(state, city, n_max)$data
}


opp_load_raw_data_file <- function(state, city = "statewide", file, n_max = Inf) {
  read_csv(file.path(opp_raw_data_dir(state, city), file), n_max = n_max)
}


opp_load_state_fips <- function() {
  fips <- read_csv(
    here::here("resources", "fips_state.csv"),
    col_types = cols_only(
      STATE = "c",
      STUSAB = "c",
      STATE_NAME = "c"
    )
  ) %>%
  rename(
    fip = STATE,
    abbreviation = STUSAB,
    state = STATE_NAME
  ) %>%
  select(
    fip,
    abbreviation,
    state
  )
}


opp_locations_used_in_analyses <- function() {
  bind_rows(
    opp_locations_used_in_analysis("veil_of_darkness"),
    opp_locations_used_in_analysis("marijuana_legalization_analysis"),
    opp_locations_used_in_analysis("disparity")
  ) %>%
  distinct()
}


opp_locations_used_in_analysis <- function(analysis_name) {
  source(here::here("lib", str_c(analysis_name, ".R")), local = T)
  states <- tibble()
  cities <- tibble()
  if (exists("ELIGIBLE_STATES"))
    states <- ELIGIBLE_STATES
  if (exists("ELIGIBLE_CITIES"))
    cities <- ELIGIBLE_CITIES
  bind_rows(states, cities)
}


opp_package_for_archive <- function(dir = "/share/data/opp-for-archive") {
  opp_apply(
    function(state, city) {
      opp_package_location_for_archive(state, city, dir)
    }
  )
}


opp_package_location_for_archive <- function(
  state,
  city,
  dir = "/share/data/opp-for-archive"
) {
  fn <- for_filename(state, city)
  base <- file.path(dir, fn)
  dt <- str_c("_", str_replace_all(Sys.Date(), "-", "_"))
  csv <- str_c(base, dt, ".csv")
  rds <- str_c(base, dt, ".rds")
  tgz <- str_c(base, dt, ".tgz")
  shp <- str_c(base, "_shapefiles", dt, ".tgz")
  d <- opp_load_clean_data(state, city) %>%
    select(-one_of(redact_for_public_release))
  write_csv(d, csv) 
  zip(str_c(csv, ".zip"), csv)
  file.remove(csv)
  saveRDS(d, rds)
  tar(opp_data_dir(state, city), tgz, fn)
  shp_dir <- opp_shapefiles_dir(state, city)
  if (has_files(shp_dir))
    tar(shp_dir, shp, str_c(fn, "_shapefiles"))
}


opp_plot <- function(state, city = "Statewide") {
  source(here::here("lib", "plot.R"), local = TRUE)
  output_dir = here::here("plots")
  dir_create(output_dir)
  plot_cols(
    opp_load_clean_data(state, city),
    file.path(output_dir, pdf_filename(state, city))
  )
}


opp_plot_distribution <- function(
  state,
  city,
  sub_geography = district
) {
  subgq <- enquo(sub_geography)
  subgq_name <- quo_name(subgq)
  tbl <- opp_load_clean_data(state, city) %>%
    filter(
      search_conducted,
      !is.na(contraband_found),
      !is.na(!!subgq)
    ) %>%
    mutate(year_month = as.yearmon(date))
  print(str_c(nrow(tbl), " data points"))
  # NOTE: facet_grid doesn't like year_month ~ !!subgq or vars or anything
  fmla <- as.formula(str_c("year_month", "~", subgq_name))
  p <- ggplot(tbl) +
    geom_bar(aes(subject_race, fill = subject_race)) +
    facet_grid(fmla, switch = "y") +
    theme(
      axis.text.x = element_blank(),
      axis.ticks.x = element_blank()
    ) + 
    scale_y_continuous(position="right") +
    ylab("year_month") +
    xlab(subgq_name) +
    scale_fill_brewer(palette="Set1")
  output_dir <- dir_create(here::here("plots"))
  fname <- str_c("distribution_", pdf_filename(state, city))
  width <- select(tbl, !!subgq) %>% distinct %>% count
  height <- tbl %>%
    mutate(year_month = as.yearmon(date)) %>% distinct(year_month) %>% count
  ggsave(
    path(output_dir, fname),
    p,
    width = width$n[1] * 2,
    height = height$n[1] * 2,
    units = "in",
    limitsize = F
  )
}


opp_prepare_for_disparity <- function(
  tbl,
  ...,
  demographic_col = subject_race,
  action_col = search_conducted,
  outcome_col = contraband_found,
  metadata = list()
) {

  control_colqs <- enquos(...)
  demographic_colq <- enquo(demographic_col)
  action_colq <- enquo(action_col)
  outcome_colq <- enquo(outcome_col)

  stopifnot(length(quos_names(control_colqs)) > 0)

  action_colname <- quo_name(action_colq)
  outcome_colname <- quo_name(outcome_colq)

  # NOTE: if action was FALSE and outcome is NA, propagate FALSE over
  n_outcome_na_before <- sum(is.na(tbl[[outcome_colname]]))
  tbl <- 
    tbl %>%
    mutate(
      !!outcome_colname := if_else_na(
        is.na(!!outcome_colq) & !(!!action_colq),
        F,
        !!outcome_colq
      )
    )
  n_outcome_na_after <- sum(is.na(tbl[[outcome_colname]]))
  n_fill_outcome <- n_outcome_na_before - n_outcome_na_after
  metadata["fill_outcome"] <- n_fill_outcome
  if (n_fill_outcome > 0) {
    msg <- str_c(
      n_fill_outcome,
      " of ",
      outcome_colname,
      " were NA and filled with FALSE because ",
      action_colname,
      " was also FALSE (no action -> no outcome)"
    )
    warning(msg, call. = F)
  }
    

  n_before_drop_na <- nrow(tbl)
  tbl <- 
    tbl %>% 
    select(
      !!demographic_colq,
      !!action_colq,
      !!outcome_colq,
      !!!control_colqs
    ) %>%
    drop_na() 
  n_after_drop_na <- nrow(tbl)

  null_rate <- (n_before_drop_na - n_after_drop_na) / n_before_drop_na
  if (null_rate > 0) {
    pct_warning(null_rate, "of data was null for required columns and removed")
  }
  metadata["null_rate"] <- null_rate

  # NOTE: remove inconsistent data where an outcome was recorded but there
  # was no action taken
  tbl <- filter(tbl, !(!!outcome_colq & !(!!action_colq)))
  correction_rate <- (n_after_drop_na - nrow(tbl)) / n_before_drop_na
  metadata["outcome_without_action_rate"] <- correction_rate
  if (correction_rate > 0) {
    pct_warning(
      correction_rate,
      "of data was inconsistent: outcome was positive but no action was taken"
    )
  }

  tbl
}


opp_process <- function(state, city = "statewide", n_max = Inf) {
  dr <- opp_load_raw(state, city, n_max)
  dc <- opp_clean(dr, state, city)
  opp_save(dc, state, city)
  warnings()
}


opp_process_all <- function() {
  par_pmap(opp_available(), opp_process)
}


opp_processor_path <- function(state, city = "statewide") {
  here::here(
    "lib",
    "states",
    normalize_state(state),
    str_c(normalize_city(city), ".R")
  )
}


opp_processor_paths <- function() {
  here::here(
    "lib/states",
    list.files(here::here("lib/states"), ".*\\.R$", recursive = TRUE)
  )
}


opp_raw_data_dir <- function(state, city = "statewide") {
  data_dir <- opp_data_dir(state, city)
  file.path(data_dir, "raw_csv")
}


opp_report <- function(state, city = "statewide") {
  print("building report...")
  dir_create(here::here("reports"))
  output_path <- here::here("reports", pdf_filename(state, city))
  render(
    "report.Rmd",
    "pdf_document",
    output_path,
    params = list(
      state = state,
      city = city
    )
  )
}


opp_report_all <- function() {
  par_pmap(opp_available(), opp_report)
}


opp_results_path <- function(fname) {
  dir_create(here::here("results"))
  here::here("results", fname)
}


opp_run_disparity <- function() {
  # TODO(danj): implement
}


opp_run_marijuana_legalization_analysis <- function() {
  output_path <- opp_results_path("marijuana_legalization_analysis.rds")
  source(here::here("lib", "marijuana_legalization_analysis.R"), local = T)
  mj <- marijuana_legalization_analysis()
  saveRDS(mj, output_path)
  print(str_c(
    "saved to marijuana legalization analysis results to ",
    output_path
  ))
  mj
}


opp_run_prima_facie_stats <- function() {
  output_path <- opp_results_path("prima_facie_stats.rds")
  source(here::here("lib", "prima_facie_stats.R"), local = T)
  pfs <- prima_facie_stats()
  saveRDS(pfs, output_path)
  print(str_c("saved prima facie stats to ", output_path))
  pfs
}


opp_run_paper_analyses <- function() {
  # TODO(danj): uncomment
  # opp_run_prima_facie_stats()
  # opp_run_veil_of_darkness()
  # opp_run_disparity()
  # opp_run_marijuana_legalization_analysis()
  output_path <- opp_results_path("paper_results.pdf")
  render("paper_results.Rmd", "pdf_document", output_path)
  print(str_c("saved paper results to ", output_path))
}


opp_run_veil_of_darkness <- function() {
  output_path <- opp_results_path("veil_of_darkness.rds")
  source(here::here("lib", "veil_of_darkness.R"), local = T)
  vod <- list(
    cities = veil_of_darkness_cities(),
    states = veil_of_darkness_states()
  )
  saveRDS(vod, output_path)
  print(str_c("saved veil of darkness results to ", output_path))
  vod
}


opp_save <- function(d, state, city = "statewide") {
  saveRDS(d, opp_clean_data_path(state, city))
}


opp_set_download_directory <- function(data_dir) {
  repo_data_dir <- here::here("data")
  dir_create(data_dir)
  if (dir_exists(repo_data_dir))
    file.remove(repo_data_dir)
  file.symlink(data_dir, repo_data_dir)
}


opp_shapefiles_dir <- function(state, city = "statewide") {
  data_dir <- opp_data_dir(state, city)
  file.path(data_dir, "shapefiles")
}


opp_simplify_eligibility <- function(tbl) {
  mutate(
    tbl,
    race_contra_subg_where_search = if_else(
      city == "Statewide",
      pmax(!!!state_subgeographies, na.rm = T),
      pmax(!!!city_subgeographies, na.rm = T)
    )
  ) %>%
  select(
    state,
    city,
    year,
    n_searches,
    race_contra_subg_where_search
  ) %>%
  mutate(
    n_eligible = floor(n_searches * race_contra_subg_where_search)
  ) %>%
  arrange(
    state,
    city,
    year
  )
}


opp_state_demographics <- function(state) {
  state_query <- str_to_upper(state)
  tbl <-
    opp_load_acs_race_data("acs_2017_5_year_state_level_race_data.csv") %>%
    filter(state_abbreviation == state_query)
  if (nrow(tbl) != length(valid_races))
    stop(str_c("Demographic query for ", state_query, " failed!"))
  tbl
}


opp_state_population <- function(state, city) {
  sum(opp_state_demographics(state)$population)
}


opp_tbl_from_eligible_subset <- function(eligible_subset_tbl) {

  prepare_city <- function(state, city, years) {

    tbl <- opp_load_clean_data(state, city) %>%
      filter(
        year(date) %in% years[[1]]
      ) %>%
      mutate(
        state = state,
        city = city
      )

    if (city == "Statewide") {
      state_regex <- str_c(quos_names(state_subgeographies), collapse = "|")
      sub_geographies <- select(tbl, matches(state_regex))
    } else {
      city_regex <- str_c(quos_names(city_subgeographies), collapse = "|")
      sub_geographies <- select(tbl, matches(city_regex))
    }
    sub_geography <- sub_geographies %>%
      select_if(
        # NOTE: select column with min null rate
        funs(which.min(sum(is.na(.))))
      ) %>%
      rename_(
        sub_geography = names(.)[1]
      )

    bind_cols(
      tbl,
      sub_geography
    ) %>%
    select(
      state,
      city,
      sub_geography,
      subject_race,
      search_conducted,
      contraband_found
    )
  }
  
  pmap_tbl <-
    eligible_subset_tbl %>%
    group_by(
      state,
      city
    ) %>%
    summarize(
      years = list(year)
    ) %>%
    ungroup()

  bind_rows(par_pmap(pmap_tbl, prepare_city))
}


pdf_filename <- function(state, city) {
  str_c(for_filename(state, city), ".pdf")
}


tar <- function(
  source_dir,
  output_tgz_path,
  output_basename,
  extra_args = ""
) {
  # NOTE: R's tar doesn't allow many of the arguments, like transform, which
  # allow nicer packaging and unpackaging of the tarball
  tar_cmd <- str_c(
    "cd",
    source_dir,
    "&&",
    "tar chvzf", 
    output_tgz_path,
    extra_args,
    ".",
    "--transform",
    str_c("'s/./", output_basename, "/'"),
    sep = " "
  )
  system(tar_cmd, ignore.stdout = T)
}
