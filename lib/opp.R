library(knitr)
library(rmarkdown)
library(stringr)

source("utils.R")


opp_load <- function(state, city) {
  readRDS(opp_clean_data_path(state, city))
}


opp_load_data <- function(state, city) {
  opp_load(state, city)$data
}


opp_clean_data_path <- function(state, city) {
  # NOTE: all clean data is stored and loaded in RDS format to
  # maintain data types
  data_dir = opp_data_dir(state, city)
  file.path(data_dir, "clean", str_c(normalize_city(city), ".rds"))
}


opp_data_dir <- function(state, city) {
  file.path(
    "..",
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


opp_processor_path <- function(state, city) {
  file.path(
    "states",
    normalize_state(state),
    str_c(normalize_city(city), ".R")
  )
}


opp_raw_data_dir <- function(state, city) {
  data_dir = opp_data_dir(state, city)
  file.path(data_dir, "raw_csv")
}


opp_calculated_features_path <- function(state, city) {
  data_dir = opp_data_dir(state, city)
  file.path(data_dir, "calculated_features")
}


opp_clean <- function(d, state, city) {
  source(opp_processor_path(state, city), local = TRUE)
  clean(d, opp_calculated_features_path(state, city))
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
  output_dir = file.path("..", "reports")
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
  source("plot.R", local = TRUE)
  output_dir = file.path("..", "plots")
  dir.create(output_dir, showWarnings = FALSE)
  plot_cols(
    opp_load(state, city),
    file.path(output_dir, pdf_filename(state, city))
  )
}


opp_population <- function(state, city) {

  p <- read_csv(
    file.path("..", "data", "populations.csv"),
    col_types = cols_only(
      STATE = "c",
      NAME = "c",
      STNAME = "c",
      FUNCSTAT = "c",
      CENSUS2010POP = "i"
    )
  )
  fips <- read_delim(
    file.path("..", "data", "fips.csv"),
    delim = "|",
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
    matches(NAME, capitalize_first_letters(city))
  ) %>%
  summarize(
    population = max(CENSUS2010POP, na.rm = TRUE)
  )

	# return scalar, not tibble
	as.integer(v)
}
