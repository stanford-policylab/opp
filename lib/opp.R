library(fs)
library(here)
library(jsonlite)
library(knitr)
library(purrr)
library(rmarkdown)
library(stringr)
library(fs)

source(here::here("lib", "utils.R"))
source(here::here("lib", "standards.R"))


clear <- function() {
  env = globalenv()
  rm(list=ls(envir = env), envir = env)
  source("opp.R")
}
cl <- clear


opp_data_paths <- function() {
  here::here(
    "data",
    list.files(here::here("data"), ".*\\.rds$", recursive = TRUE)
  )
}


opp_load_all_data <- function() {
  paths <- opp_data_paths()
  tbl <- tibble(
    state = simple_map(paths, opp_extract_state_from_path),
    # NOTE: city could be 'statewide' too 
    city = simple_map(paths, opp_extract_city_from_path)
  )
  bind_rows(
    par_pmap(
      tbl,
      function(state, city) {
        mutate(
          opp_load_data(state, city),
          state = state,
          city = city
        )
      }
    )
  )
}


opp_eligiblity <- function(tbl) {

  nr <- function(v) { sum(!is.na(v)) / length(v) }
  eqr <- function(v, val) { sum(v == val, na.rm = T) / length(v) }

  mutate(
    tbl,
    lat_lng = !is.na(lat) & !is.na(lng),
    # neither null or if search_conducted = F, contraband_found 
    # can be F, T, or NA 
    search_contraband = (!is.na(search_conducted) & !is.na(contraband_found))
      | if_else_na(search_conducted == F, T, F)
  ) %>%
  group_by(
    state,
    city,
    year = year(date)
  ) %>%
  summarize(
    # coverage
    n = n(),
    universe = n_distinct(outcome) == 3,  # arrest, citation, warning
    arrest_rate = eqr(outcome, "arrest"),
    citation_rate = eqr(outcome, "citation"),
    warning_rate = eqr(outcome, "warning"),
    # disparity
    subject_race = nr(subject_race),
    frisk_performed = nr(frisk_performed),
    search_conducted = nr(search_conducted),
    contraband_found = nr(contraband_found),
    search_contraband = sum(search_contraband) / n,
    # bunching
    speed = nr(speed),
    # locations
    location = nr(location),
    lat_lng = sum(lat_lng) / n,
    county_name = nr(county_name),
    neighborhood = nr(neighborhood),
    beat = nr(beat),
    district = nr(district),
    subdistrict = nr(subdistrict),
    division = nr(division),
    subdivision = nr(subdivision),
    police_grid_number =nr(police_grid_number),
    precinct = nr(precinct),
    region = nr(region),
    reporting_area = nr(reporting_area),
    sector = nr(sector),
    subsector = nr(subsector),
    service_area = nr(service_area),
    zone = nr(zone),
    department_id = nr(department_id),
    department_name = nr(department_name)
  ) %>%
  ungroup()
}


opp_simplify_eligibility <- function(eligibility_tbl) {
  mutate(
    eligibility_tbl,
    sub_geography = ifelse(
      city == "Statewide" ,
      pmax(!!!state_sub_geographies, na.rm = T),
      pmax(!!!city_sub_geographies, na.rm = T)
    )
  ) %>%
  select(
    state,
    city,
    year,
    n,
    universe,
    subject_race,
    sub_geography,
    contraband_found,
    search_contraband,
    lat_lng,
    frisk_performed
  ) %>%
  arrange(
    -universe,
    -sub_geography,
    -contraband_found,
    -search_contraband,
    state,
    city,
    -year
  )
}


opp_eligible_subset <- function(
  simple_eligibility_tbl,
  exclude_cities=c("Statewide"),
  min_n_per_year=10000,
  require_universe=F,
  race_threshold=0.95,
  sub_geography_threshold=0.95,
  contraband_found_threshold=0.00,
  search_contraband_threshold=0.95
) {
  simple_eligibility_tbl %>%
    filter(
      !(city %in% exclude_cities),
      n >= min_n_per_year,
      if (require_universe) universe == T else T,
      subject_race > race_threshold,
      sub_geography >= sub_geography_threshold,
      # NOTE: search_contraband = !na(search) & !na(contraband) | search=F
      # in the majority of cases, search = F, so the combined column reports
      # a high percentage; here we want to make sure contraband is also at
      # least sometimes recorded
      contraband_found > contraband_found_threshold,
      search_contraband >= search_contraband_threshold
    )
}


opp_tbl_from_eligible_subset <- function(eligible_subset_tbl) {

  prepare_city <- function(state, city, years) {

    tbl <- opp_load_data(state, city) %>%
      filter(
        year(date) %in% years[[1, 1]]
      ) %>%
      mutate(
        state = state,
        city = city
      )

    if (city == "Statewide") {
      state_regex <- str_c(quos_names(state_sub_geographies), collapse = "|")
      sub_geographies <- select(tbl, matches(state_regex))
    } else {
      city_regex <- str_c(quos_names(city_sub_geographies), collapse = "|")
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
  
  pmap_tbl <- eligible_subset_tbl %>%
    group_by(
      state,
      city
    ) %>%
    summarize(
      years = list(year)
    ) %>%
    ungroup()

  par_pmap(pmap_tbl, prepare_city)
}


opp_everything <- function() {
  paths <- opp_processor_paths()
  tbl <- tibble(
    state = simple_map(paths, opp_extract_state_from_path),
    # NOTE: city could be 'statewide' too 
    city = simple_map(paths, opp_extract_city_from_path)
  )
  par_pmap(tbl, opp_process)
  par_pmap(tbl, opp_report)
  opp_coverage()
}


opp_processor_paths <- function() {
  here::here(
    "lib/states",
    list.files(here::here("lib/states"), ".*\\.R$", recursive = TRUE)
  )
}


opp_extract_state_from_path <- function(path) {
  tokens <- tokenize_path(path)
  toupper(tokens[which(tokens == "states") + 1])
}


opp_extract_city_from_path <- function(path) {
  tokens <- tokenize_path(path)
  format_proper_noun(str_replace(
    tokens[which(tokens == "states") + 2], 
    ".R",
    ""
  ))
}


opp_load <- function(state, city) {
  readRDS(opp_clean_data_path(state, city))
}


opp_load_data <- function(state, city) {
  opp_load(state, city)$data
}


opp_load_coverage_data <- function(state, city) {
  tbl <- opp_load_data(state, city)

  coverage <- select_or_add_as_na(
    tbl,
    c(
      "date",
      "time",
      "lat",
      "lng",
      "subject_race",
      "subject_sex",
      "type",
      "warning_issued",
      "citation_issued",
      "arrest_made",
      "contraband_found",
      "frisk_performed",
      "search_conducted",
      "speed"
    )
  ) %>%
  rename(
    veh_or_ped = type
  ) %>%
  mutate(
    geolocation = !is.na(lat) & !is.na(lng)
  ) %>%
  select(
    -lat,
    -lng
  )

  vehicle_desc <- select_least_na(
    tbl,
    c(
      "vehicle_color",
      "vehicle_make",
      "vehicle_model",
      "vehicle_type"
    ),
    rename = "vehicle_desc"
  )

  subject_age <- select_least_na(
    tbl,
    c(
      "subject_age",
      "subject_dob",
      "subject_yob"
    ),
    rename = "subject_age"
  )

  violation_desc <- select_least_na(
    tbl,
    c(
      "disposition",
      "violation"
    ),
    rename = "violation_desc"
  )

  geodivision <- select_least_na(
    tbl,
    c(
      "beat",
      "district",
      "subdistrict",
      "division",
      "subdivision",
      "police_grid_number",
      "precinct",
      "region",
      "reporting_area",
      "sector",
      "subsector",
      "service_area",
      "zone"
    ),
    rename = "police_geodivision"
  )

  bind_cols(
    coverage,
    vehicle_desc,
    subject_age,
    violation_desc,
    geodivision
  )
}


opp_clean_data_path <- function(state, city) {
  # NOTE: all clean data is stored and loaded in RDS format to
  # maintain data types
  data_dir = opp_data_dir(state, city)
  file.path(data_dir, "clean", str_c(normalize_city(city), ".rds"))
}

opp_results_dir <- function(state, city) {
  dir_create(path(opp_data_dir(state, city), "results"))
}

opp_data_dir <- function(state, city) {
  here::here(
    "data",
    "states",
    normalize_state(state),
    normalize_city(city)
  )
}

normalize_state <- function(state) {
  str_to_lower(state)
}


normalize_city <- function(city) {
  str_to_lower(str_replace(city, " ", "_"))
}


opp_load_raw <- function(state, city, n_max = Inf) {
  source(opp_processor_path(state, city), local = TRUE)
  load_raw(opp_raw_data_dir(state, city), n_max)
}


opp_load_raw_data <- function(state, city, n_max = Inf) {
  opp_load_raw(state, city, n_max)$data
}


opp_load_raw_data_file <- function(state, city, file, n_max = Inf) {
  read_csv(file.path(opp_raw_data_dir(state, city), file), n_max = n_max)
}


opp_processor_path <- function(state, city) {
  here::here(
    "lib",
    "states",
    normalize_state(state),
    str_c(normalize_city(city), ".R")
  )
}


opp_raw_data_dir <- function(state, city) {
  data_dir = opp_data_dir(state, city)
  file.path(data_dir, "raw_csv")
}


opp_clean <- function(d, state, city) {
  source(opp_processor_path(state, city), local = TRUE)
  helpers <- c(
    "add_lat_lng" = opp_add_lat_lng_func(state, city),
    "add_search_basis" = opp_add_search_basis_func(state, city),
    "add_type" = opp_add_type_func(state, city),
    "add_contraband_types_func" = opp_add_contraband_types_func(state, city),
    "add_shapefiles_data" = opp_add_shapefiles_data_func(state, city),
    "add_county_from_highway_milepost" = 
      opp_add_county_from_highway_milepost_func(state, city),
    "fips_to_county_name" = opp_fips_to_county_name_func(state),
    "load_json" = opp_load_json_func(state, city),
    "load_csv" = opp_load_csv_func(state, city)
  )
  clean(d, helpers)
}


opp_add_lat_lng_func <- function(state, city) {
  function(tbl, join_col = "location") {
    join_on <- c("loc")
    names(join_on) <- c(join_col)
    locs <- opp_load_csv_func(state, city)(
      "geocoded_locations.csv",
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


opp_add_search_basis_func <- function(state, city) {
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


opp_calculated_features_path <- function(state, city) {
  data_dir = opp_data_dir(state, city)
  file.path(data_dir, "calculated_features")
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


opp_add_county_from_highway_milepost_func <- function(state, city) {
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


opp_add_contraband_types_func <- function(state, city) {
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
        "w" = "contraband_weapons"
      )
    )
  }
}


opp_add_shapefiles_data_func <- function(state, city) {
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


opp_load_all_shapefiles_dfs <- function(state, city) {
  source(here::here("lib", "shapefiles.R"), local = TRUE)
  load_all_shapefiles_dfs(opp_shapefiles_dir(state, city))
}


opp_shapefiles_dir <- function(state, city) {
  data_dir = opp_data_dir(state, city)
  file.path(data_dir, "shapefiles")
}


opp_load_json_func <- function(state, city) {
  function(json_filename) {
    fromJSON(file.path(
      opp_calculated_features_path(state, city),
      json_filename
    ))
  }
}


opp_load_csv_func <- function(state, city) {
  function(
    csv_filename,
    n_max = Inf,
    col_types = cols(.default = "c"),
    col_names = TRUE,
    skip = 0
  ) {
    read_csv(
      file.path(opp_calculated_features_path(state, city), csv_filename),
      col_types = col_types,
      col_names = col_names,
      skip = skip
    )
  }
}


opp_load_block_group_shapefiles <- function(state) {
  source(here::here("lib", "shapefiles.R"), local = TRUE)
  # NOTE: all these block group shapefiles are from 2017
  # NOTE: there should only be one shapefile layer for each state, so 1st index
  load_all_shapefiles_objects(
    here::here("data", "block_group_shapefiles", "2017", state)
  )[[1]]
}


opp_load_block_group_data <- function(state) {
  full_state_name = state.name[toupper(state) == state.abb]
  filter(
    read_csv(here::here(
      "data",
      "population_by_block_group_by_race_2012_to_2016_with_lat_lng.csv"
    )),
    state == full_state_name
  )
}


opp_save <- function(d, state, city) {
  saveRDS(d, opp_clean_data_path(state, city))
}


opp_process <- function(state, city, n_max = Inf) {
  dr <- opp_load_raw(state, city, n_max)
  dc <- opp_clean(dr, state, city)
  opp_save(dc, state, city)
  warnings()
}


opp_report <- function(state, city) {
  print("building report...")
  output_dir = here::here("reports")
  dir_create(output_dir)
  render(
    "report.Rmd",
    "pdf_document",
    file.path(output_dir, pdf_filename(state, city)),
    params = list(
      state = state,
      city = city
    )
  )
}


pdf_filename <- function(state, city) {
  str_c(normalize_state(state), "_", normalize_city(city), ".pdf")
}


opp_plot <- function(state, city) {
  source(here::here("lib", "plot.R"), local = TRUE)
  output_dir = here::here("plots")
  dir_create(output_dir)
  plot_cols(
    opp_load(state, city),
    file.path(output_dir, pdf_filename(state, city))
  )
}


opp_fips_to_county_name_func <- function(state) {
  # NOTE: uses 2010 FIPS codes for counties:
  # https://www.census.gov/geo/reference/codes/cou.html
  fips <- read_csv(
    here::here("data", "fips_county.csv"),
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


opp_population <- function(state, city) {
  # NOTE: returns 2010 population; using this because
  # it has more cities than ACS annual samples (< 200)

  # NOTE: some rows have 'A' instead of integer populations; ignore this
  p <- suppressWarnings(read_csv(
    here::here("data", "populations.csv"),
    col_types = cols_only(
      STATE = "c",
      NAME = "c",
      STNAME = "c",
      FUNCSTAT = "c",
      CENSUS2010POP = "i"
    )
  ))
  fips <- read_csv(
    here::here("data", "fips_state.csv"),
    col_types = cols_only(
      STATE = "c",
      STUSAB = "c",
      STATE_NAME = "c"
    )
  )
  v <- left_join(
    p,
    fips,
    by = c("STATE" = "STATE")
  ) %>%
  filter(
    # https://www.census.gov/geo/reference/codes/place.html, only [A]ctive
    FUNCSTAT == "A",
    STUSAB == toupper(state),
    str_detect(NAME, str_replace(format_proper_noun(city), "Saint", "St.")),
    !str_detect(NAME, "County")
  ) %>%
  summarize(
    population = max(CENSUS2010POP, na.rm = TRUE)
  )

	# return scalar, not tibble
	as.integer(v)
}


opp_demographics <- function(state, city) {
  city_query <- str_c(format_proper_noun(city), toupper(state), sep = ", ")
  read_csv(
    here::here("data", "acs_agg.csv")
  ) %>%
  filter(
    str_detect(city, city_query)
  ) %>%
  select(-city)
}


opp_coverage <- function() {
  print("assessing coverage...")
  output_dir = here::here("coverage")
  dir_create(output_dir)
  render(
    "coverage.Rmd",
    "pdf_document",
    file.path(output_dir, "coverage.pdf")
  )
}
