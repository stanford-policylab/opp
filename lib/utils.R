library(tidyverse)
library(lubridate)
library(getopt)
library(stringr)

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


top_n_by_year <- function(tbl, date_col, col_to_rank, top_n = 10) {
  stopifnot(is.data.frame(tbl) || is.list(tbl) || is.environment(tbl))

  date_enquo <- enquo(date_col)
  rank_enquo <- enquo(col_to_rank)

  d <- tbl %>%
    mutate(yr = year(!!date_enquo)) %>%
    group_by(yr, !!rank_enquo) %>%
    count() %>%
    group_by(yr) %>%
    mutate(yr_rank = row_number(-n)) %>%
    filter(yr_rank <= top_n) %>%
    arrange(yr, yr_rank)
}


plot_top_n_by_year <- function(tbl, date_col, col_to_rank, top_n = 10) {

  date_enquo <- enquo(date_col)
  rank_enquo <- enquo(col_to_rank)

  d <- top_n_by_year(tbl, !!date_enquo, !!rank_enquo, top_n)
  ggplot(d) +
    geom_bar(aes(x = eval(rlang::UQE(rank_enquo)), y = n), stat = "identity") +
    facet_grid(yr ~ .) +
    theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
    xlab(enquo(col_to_rank))
}


get_primary_class <- function(obj) {
  class(obj)[1]
}


get_null_rates <- function(tbl) {
  nulls_tbl <- tbl %>% summarize_all(funs(sum(is.na(.)) / length(.)))
  nulls_vec <- named_vector_from_list_firsts(nulls_tbl)
  nulls_pcts <- paste0(formatC(100 * nulls_vec, format = "f", digits = 2), "%")
  tibble(features = names(nulls_vec), null_pct = nulls_pcts) %>% print(n = Inf)
}


add_lat_lng <- function(tbl, join_col, path_prefix) {
  geocoded_locations <- read_csv(str_c(path_prefix,
                                       "/geocodes/",
                                       "geocoded_locations.csv"))
  join_on <- c("loc")
  names(join_on) <- c(join_col)
  tbl %>% left_join(geocoded_locations, by = join_on)
}


save_clean_csv <- function(tbl, path_prefix, city) {
  write_csv(tbl, str_c(path_prefix, "/clean/", city, ".csv"))
}
