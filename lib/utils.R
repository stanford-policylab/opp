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


top_n_by <- function(tbl, ..., top_n = 10) {
  tbl %>%
    group_by(...) %>%
    count %>%
    ungroup %>%
    mutate(rank = row_number(-n)) %>%
    filter(rank <= top_n) %>%
    arrange(rank)
}


get_primary_class <- function(obj) {
  class(obj)[1]
}

pct_tbl <- function(v, colnames = c("name", "pct")) {
  tbl <- as_tibble(prop.table(table(v)) * 100)
  names(tbl) <- colnames
  tbl
}


null_rates <- function(tbl) {
  nulls_tbl <- tbl %>% summarize_all(funs(null_rate))
  transpose_one_line_table(
    nulls_tbl,
    colnames = c("features", "null rate"),
    f = pretty_percents
  )
}


null_rate <- function(v) {
	round(sum(is_null(v)) / length(v), 4)
}


is_null <- function(v) {
  if (is.character(v)) {
    is.na(v) | v == "NA" | v == "" | v == "NULL"
  } else {
    is.na(v)
  }
}


apply_schema_and_collect_null_rates <- function(schema, data) {
  null_rates <- list()
  for (name in names(schema)) {
		if (name %in% colnames(data)) {
			x <- apply_and_collect_null_rates(schema[[name]], data[[name]])
			data[[name]] <- x$v
			null_rates[[name]] <- x$null_rates 
		}
  }
  list(data = data, null_rates = create_null_rates_tbl(null_rates))
}


create_null_rates_tbl <- function(null_rates_list) {
	null_rates_matrix <- t(bind_rows(null_rates_list))
	t <- as_tibble(rownames_to_column(as.data.frame(null_rates_matrix)))
	colnames(t) <- c("col", "null_rate_before", "null_rate_after")
	mutate(t, null_rate_after_less_before = null_rate_after - null_rate_before)
}


apply_and_collect_null_rates <- function(f, v) {
	null_rate_before <- null_rate(v)
	v <- f(v)
	null_rate_after <- null_rate(v)
	list(
		v = v,
		null_rates = c(
			null_rate_before = null_rate_before,
			null_rate_after = null_rate_after
		)
	)
}


transpose_one_line_table <- function(tbl,
                                     colnames = c("names", "values"),
                                     f = identity) {
  v <- named_vector_from_list_firsts(tbl)
  tbl <- tibble(names(v), f(v))
  names(tbl) <- colnames
  tbl
}


transpose_tbl <- function(tbl) {
	as_tibble(cbind(columns = names(tbl), t(tbl)))
}


pretty_percents <- function(v) {
  paste0(formatC(100 * v, format = "f", digits = 2), "%")
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


merge_rows <- function(tbl, ..., null_fill = "NA", sep = "|") {
  # NOTE: merging converts all columns being merged to strings so the values
  # can be concatenated; so, for instance, the number 1987 will become the
  # string 1987, and two values, 1987 and 1989, being merged will be converted
  # to the string 1987<sep>1989. If you later force this column back to an
  # integer data type, you will introduce NAs, since merged columns will no
  # longer convert back cleanly
  # NOTE: if there is only one unique value when merging, return only the 
  # unique value; furthermore, if that unique value is the null_fill, return
  # NA_character_, since by default NAs propagate in R; however, if there
  # is more than one unique value and there is at least one NA, the NA will
  # be converted to fill_value and included in the merge,
  # i.e. banana<sep><fill_value> or banana|NA
  # NOTE: this function adds a column called unmerged_row_count that indicates
  # how many unmerged rows a current row represents, this can be used to
  # melt/explode a row back into its original rows
  m <- function(v) {
    # null_fill must be a string
    if (is.na(null_fill)) {
      null_fill <- "NA"
    }
    v <- fill_null(as.character(v), null_fill)
    if (length(unique(v)) == 1) {
      v <- v[1]
      if (v == null_fill)
        v <- as.character(NA)
    } else {
      v <- str_c(v, collapse = sep)
    }
    v
  }
  group_by(tbl, ...) %>%
    mutate(unmerged_row_count = n()) %>%
    summarise_all(m)
}


all_null <- function(v) {
  all(is_null(v))
}


fill_null <- function(v, fill = NA) {
  v[is_null(v)] <- fill
  v
}


str_combine <- function(left, right,
                        prefix_left = "", prefix_right = "",
                        sep = "||") {

  left_null <- is_null(left)
  right_null <- is_null(right)
  both_null <- left_null & right_null
  neither_null <- !left_null & !right_null
  left_null_right_not_null <- left_null & !right_null

  v = str_c(prefix_left, left)
  v[both_null] <- as.character(NA)
  v[neither_null] <- str_c(
    str_c(prefix_left, left[neither_null]),
    str_c(prefix_right, right[neither_null]),
    sep = sep
  )
  v[left_null_right_not_null] <- str_c(prefix_right,
                                       right[left_null_right_not_null])
  v
}


capitalize_first_letters <- function(x) {
  s <- strsplit(x, " ")[[1]]
  paste(toupper(substring(s, 1,1)), substring(s, 2),
      sep="", collapse=" ")
}


comma_num <- function(n) {
	prettyNum(n, big.mark = ",")
}
