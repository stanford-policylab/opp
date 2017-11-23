library(tidyverse)
library(lubridate)
library(getopt)
library(stringr)
library(functional)

source("lib/schema.R")


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


verify_schema <- function(tbl) {
  quit_if_not_tibble(tbl)
  quit_if_not_required_schema(tbl)
  quit_if_not_valid_factors(tbl)
}


quit_if_not_tibble <- function(tbl) {
  if (class(tbl)[1] != "tbl_df") {
    print("Invalid tibble in verify_schema!")
    q(status = 1)
  }
}


quit_if_not_required_schema <- function(tbl) {
  tbl_schema <- named_vector_from_list_firsts(sapply(tbl, class))
  same <- required_schema == tbl_schema[names(required_schema)]
  if (!all(same)) {
    not_same_str <- str_c(names(required_schema)[!same], collapse = ", ")
    print(str_c("Invalid or missing columns: ", not_same_str))
    q(status = 1)
  }
}


quit_if_not_valid_factors <- function(tbl) {
  tbl_schema <- sapply(tbl, class)
  tbl_factors <- names(tbl_schema[tbl_schema == "factor"])
  invalid_factors <- map_lgl(tbl_factors, function(col) {
    values <- levels(tbl[[col]])
    valids <- valid_factors[col]
    all(valids == values)
  })
  if (any(invalid_factors)) {
    invalid_factors_str <- str_c(tbl_factors[invalid_factors], collapse = ", ")
    print(str_c("The following columns have invalid factor values: ",
                invalid_factors_str))
    q(status = 1)
  }
}


sanitize_incident_date <- function(val) {
  sanitize_date(val, valid_incident_start_date, valid_incident_end_date)
}


sanitize_date <- function(val, start, end) {
  out_of_bounds_to(val, start, end, as.Date(NA))
}


out_of_bounds_to <- function(val, start, end, fill) {
  if_else(val < start | val > end, fill, val)
}


sanitize_dob <- function(val) {
  sanitize_date(val, valid_dob_start_date, valid_dob_end_date)
}


sanitize_yob <- function(val) {
  out_of_bounds_to(val, valid_yob_start, valid_yob_end, as.integer(NA))
}


sanitize_age <- function(val) {
  out_of_bounds_to(val, valid_age_start, valid_age_end, as.numeric(NA))
}


sanitize_vehicle_year <- function(val) {
  out_of_bounds_to(val,
                   valid_vehicle_start_year,
                   valid_vehicle_end_year,
                   as.integer(NA))
}


add_lat_lng <- function(tbl, join_col, geocodes_path) {
  geocoded_locations <- read_csv(geocodes_path)
  join_on <- c("loc")
  names(join_on) <- c(join_col)
  tbl %>% left_join(geocoded_locations, by = join_on)
}


find_similar_rows <- function(tbl, threshold = 0.95) {
  tbls <- sort_all(tbl)
  sim <- rowwise_similarity(tbls)
  idx <- which(sim >= threshold)
  idxAll <- sort(unique(c(idx - 1, idx)))
  tbls[idxAll,]
}


sort_all <- function(tbl) {
  tbl %>% arrange_(.dots=colnames(.))
}


rowwise_similarity <- function(tbl) {
  # NOTE: you probably want rows sorted using sort_all before calling
  compare_current_row_to_previous(tbl) %>% mutate(sim = rowMeans(.)) %>%
    # TODO(danj): replace with pull once dplyr updated to 0.7.0
    select(sim) %>% collect %>% .[["sim"]]
}


compare_current_row_to_previous <- function(tbl) {
  diffs <- as_tibble(
    # equal or both NA
    tbl[-1,] == tbl[-nrow(tbl),] | (is.na(tbl[-1,]) & is.na(tbl[-nrow(tbl),]))
  ) %>% 
  # covers cases where one is NA and the other isn't
  mutate_all(
    funs(replace(., is.na(.), FALSE))
  )
  # prepends a row of FALSE for first row
  rbind(logical(ncol(diffs)), diffs)
}


rowwise_similarity_report <- function(tbl) {
  # NOTE: you probably want rows sorted using sort_all before calling
  sim <- compare_current_row_to_previous(tbl) %>% summarise_all(mean)
  as_tibble(
    cbind(cols = names(sim), t(sim))
  ) %>%
  arrange(
    .[[2]]
  ) %>%
  print(
    n = Inf
  )
}


merge_rowwise <- function(tbl, ...) {
  m <- function(...) {
    str_c(sort(unique(str_replace_na(...))), collapse = "|")
  }
  group_by(tbl, ...) %>% summarise_all(m)
}
