library(getopt)
library(lubridate)
library(tidyverse)


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


matches <- function(col, s) {
  as.vector(!is.na(str_match(col, s)))
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


read_csv_with_types <- function(path, type_vec) {
  tbl <- read_csv(path,
                  col_names = names(type_vec),
                  col_types = str_c(type_vec, collapse = ""),
                  skip = 1)
}


separate_cols <- function(tbl, lst, sep = " ") {
  for (colname in names(lst)) {
    tbl <- separate_(tbl, colname, lst[[colname]], sep = sep, extra = "merge")
  }
  tbl
}



add_lat_lng <- function(tbl, join_col, geocodes_path) {
  geocoded_locations <- read_csv(geocodes_path, col_types = 'cdd')
  join_on <- c("loc")
  names(join_on) <- c(join_col)
  tbl %>%
    left_join(
      geocoded_locations, by = join_on
    ) %>%
    rename(
      incident_lat = lat,
      incident_lng = lng
    )
}


find_similar_rows <- function(tbl, threshold = 0.95) {
  tbls <- sort_all(tbl)
  sim <- row_similarity(tbls)
  idx <- which(sim >= threshold)
  idxAll <- sort(unique(c(idx - 1, idx)))
  tbls[idxAll,]
}


sort_all <- function(tbl) {
  tbl %>% arrange_(.dots=colnames(.))
}


row_similarity <- function(tbl) {
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


row_similarity_report <- function(tbl) {
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


merge_rows <- function(tbl, ...) {
  m <- function(...) {
    str_c(sort(unique(str_replace_na(...))), collapse = "|")
  }
  group_by(tbl, ...) %>% summarise_all(m)
}


str_combine <- function(left, right,
                        prefix_left = "", prefix_right = "",
                        na_left = "NA", na_right = "NA") {
  str_c(str_c(prefix_left, str_replace_na(left, na_left)),
        str_c(prefix_right, str_replace_na(right, na_right)),
        sep = "|")
}
