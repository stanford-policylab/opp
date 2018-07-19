library(knitr)
library(rmarkdown)
library(stringr)
library(jsonlite)
library(here)

source("utils.R")
source("standards.R")


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


opp_extract_state_from_path <- function(path) {
  tokens <- tokenize_path(path)
  toupper(tokens[which(tokens == "states") + 1])
}


opp_extract_city_from_path <- function(path) {
  tokens <- tokenize_path(path)
  format_proper_noun(tokens[which(tokens == "states") + 2])
}


opp_load <- function(state, city) {
  readRDS(opp_clean_data_path(state, city))
}


opp_load_data <- function(state, city) {
  opp_load(state, city)$data
}


opp_load_required_data <- function(state, city) {
  opp_load_data(state, city) %>% select_(.dots = opp_required_fields())
}


opp_required_fields <- function() {
  names(required_schema)
}


opp_clean_data_path <- function(state, city) {
  # NOTE: all clean data is stored and loaded in RDS format to
  # maintain data types
  data_dir = opp_data_dir(state, city)
  file.path(data_dir, "clean", str_c(normalize_city(city), ".rds"))
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
    "fips_to_county_name" = opp_fips_to_county_name_func(state),
    "load_json" = opp_load_json_func(state, city)
  )
  clean(d, helpers)
}


opp_add_lat_lng_func <- function(state, city) {
  function(tbl, join_col = "location") {
    join_on <- c("loc")
    names(join_on) <- c(join_col)
    add_data(
      tbl,
      file.path(
        opp_calculated_features_path(state, city),
        "geocoded_locations.csv"
      ),
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
      file.path(
        opp_calculated_features_path(state, city),
        "search_basis.csv"
      ),
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
      file.path(
        opp_calculated_features_path(state, city),
        "types.csv"
      ),
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


opp_add_contraband_types_func <- function(state, city) {
  function(tbl, join_col) {
    join_on <- c("text")
    names(join_on) <- c(join_col)
    add_data(
      tbl,
      file.path(
        opp_calculated_features_path(state, city),
        "contraband_types.csv"
      ),
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


opp_load_block_group_shapefiles <- function(state) {
  source(here::here("lib", "shapefiles.R"), local = TRUE)
  # NOTE: all these block group shapefiles are from 2017
  # NOTE: there should only be one shapefile layer for each state, so 1st index
  load_all_shapefiles_objects(
    here::here("data", "block_group_shapefiles", "2017", state)
  )[[1]]
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
  dir.create(output_dir, showWarnings = FALSE)
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
  dir.create(output_dir, showWarnings = FALSE)
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
  dir.create(output_dir, showWarnings = FALSE)
  render(
    "coverage.Rmd",
    "pdf_document",
    file.path(output_dir, "coverage.pdf")
  )
}
