suppressPackageStartupMessages(source("lib/utils.R"))
suppressPackageStartupMessages(source("lib/schema.R"))


main <- function() {
  args <- get_args()
  if (not_null(args$process))
    process(args$state, args$city)
  q(status = 0)
}


get_args <- function() {
  usage <- "./process.R [-h] -s <state_name> -c <city_name>"
  spec <- tribble(
    ~long_name, ~short_name,  ~argument_type, ~data_type,
    "help",     "h",          "none",         "logical",
    "process",  "p",          "none",         "logical",
    "state",    "s",          "required",     "character",
    "city",     "c",          "required",     "character"
  )
  args <- parse_args(spec)

  if (not_null(args$help)) {
    print(usage)
    q(status = 0)
  }

  if (is.null(args$state) || is.null(args$city)) {
    print(usage)
    q(status = 1)
  }

  args
}


opp_load <- function(state, city) {
  read_csv(opp_clean_data_path(state, city))
}


opp_save <- function(tbl, state, city) {
  write_csv(tbl, opp_clean_data_path(state, city))
}


opp_clean_data_path <- function(state, city) {
  data_dir = opp_data_dir(state, city)
  str_c(data_dir, "clean/", str_to_lower(city), ".csv")
}


opp_data_dir <- function(state, city) {
  str_c("data/states/",
        str_to_lower(state), "/",
        str_to_lower(city), "/")
}


opp_process <- function(state, city) {
  source(str_c("lib/states/",
               str_to_lower(state), "/",
               str_to_lower(city), ".R"),
         local=TRUE)
  d <- load_raw(opp_raw_data_dir(state, city),
                opp_geocodes_path(state, city))
  dc <- clean(d)
  verify_schema(dc)
  opp_save(dc, state, city)
}


opp_raw_data_dir <- function(state, city) {
  data_dir = opp_data_dir(state, city)
  str_c(data_dir, "raw_csv/")
}


opp_geocodes_path <- function(state, city) {
  data_dir = opp_data_dir(state, city)
  str_c(data_dir, "geocodes/geocoded_locations.csv")
}


if (!interactive()) {
  main()
}
