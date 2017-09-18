library("tidyverse")
library("getopt")
library("stringr")

source("lib/contract.R")


parse_args <- function(tbl) {
  argument_types <- c("none", "required", "optional")
  tmp <- mutate(tbl,
    argument_type = parse_factor(argument_type, levels = argument_types)
  )
  getopt(as.matrix(mutate(tmp, argument_type = as.integer(argument_type) - 1)))
}


not_null <- function(v) {
  !is.null(v)
}


relative_path <- function(...) {
  # TODO(djenson): figure out robust way of getting project root directory
  file.path(...)
}


source_opp_funcs_for <- function(state, city) {
  source(relative_path("lib",
                       "states",
                       str_to_lower(state),
                       str_c(str_to_lower(city), ".R")))
  ensure_contract()
}


named_vector_from_list_firsts <- function(lst) {
  unlist(lapply(lst, `[[`, 1), recursive = FALSE)
}
