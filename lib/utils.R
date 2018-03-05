library(getopt)
library(lubridate)
library(tidyverse)
library(stringr)


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


str_expr <- function(expr) {
  deparse(substitute(expr))
}


cs <- function(v, name, val) {
  nms <- names(v)
  v <- c(v, val)
  names(v) <- c(nms, name)
  v
}


any_matches <- function(pattern, ...) {
  Reduce(function(a, b) { a | b }, lapply(list(...), str_detect, pattern))
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


predicated_null_rates <- function(tbl, pred_v) {
  # NOTE: pred_v is c(target_colname = predicate_colname, ...)
  pnr <- c()
  for (colname in colnames(tbl)) {
    if (colname %in% names(pred_v)) {
      idx <- tbl[[pred_v[colname]]]
      idx <- idx & !is.na(idx)
      if (any(idx)) {
        pnr[colname] <- null_rate(tbl[[colname]][idx])
      } else {  # idx is all FALSE, which probably means predicate is all NA
        pnr[colname] <- 1
      }
    } else {
      pnr[colname] <- null_rate(tbl[[colname]])
    }
  }
  transpose_one_line_table(
    pnr,
    colnames = c("features", "null rate"),
    f = pretty_percent
  )
}


null_rates <- function(tbl) {
  nulls_tbl <- tbl %>% summarize_all(funs(null_rate))
  transpose_one_line_table(
    nulls_tbl,
    colnames = c("features", "null rate"),
    f = pretty_percent
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
  if (length(null_rates_list) == 0) {
    tibble()
  } else {
    null_rates_matrix <- t(bind_rows(null_rates_list))
    tbl <- as_tibble(rownames_to_column(as.data.frame(null_rates_matrix)))
    colnames(tbl) <- c("col", "null_rate_before", "null_rate_after")
    mutate(
      tbl,
      null_rate_after_less_before = null_rate_after - null_rate_before
    ) %>%
    arrange(
      desc(null_rate_after_less_before)
    )
  }
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


pretty_percent <- function(v) {
  paste0(formatC(100 * v, format = "f", digits = 2), "%")
}


read_csv_with_types <- function(path,
                                type_vec,
                                na = c("", "NA", "NULL"),
                                n_max = Inf) {
  tbl <- read_csv(path,
                  col_names = names(type_vec),
                  col_types = str_c(type_vec, collapse = ""),
                  na = na,
                  n_max = n_max,
                  skip = 1)
}


separate_cols <- function(tbl, ..., sep = " ") {
  lst = list(...)
  for (colname in names(lst)) {
    tbl <- separate_(tbl, colname, lst[[colname]], sep = sep, extra = "merge")
  }
  tbl
}



add_lat_lng <- function(tbl, join_col, calculated_features_path) {
  join_on <- c("loc")
  names(join_on) <- c(join_col)
  add_calculated_feature(
    tbl,
    join_on,
    calculated_features_path,
    "geocoded_locations.csv",
    "cdd"
  ) %>%
  rename(
    incident_lat = lat,
    incident_lng = lng
  )
}


add_contraband_types <- function(tbl, join_col, calculated_features_path) {
  join_on <- c("text")
  names(join_on) <- c(join_col)
  add_calculated_feature(
    tbl,
    join_on,
    calculated_features_path,
    "contraband_types.csv",
    "iic"
  ) %>%
  rename(
    contraband_drugs = d,
    contraband_weapons = w
  )
}


add_search_types <- function(tbl, join_col, calculated_features_path) {
  join_on <- c("text")
  names(join_on) <- c(join_col)
  tr_search_type <- c(
    k9 = "k9",
    pv = "plain view" ,
    cn = "consent",
    pc = "probable cause",
    nd = "non-discretionary"
  )
  add_calculated_feature(
    tbl,
    join_on,
    calculated_features_path,
    "search_types.csv",
    "cc"
  ) %>%
  mutate(
    search_type = tr_search_type[label]
  )
}


add_incident_types <- function(tbl, join_col, calculated_features_path) {
  join_on <- c("text")
  names(join_on) <- c(join_col)
  tr_incident_type <- c(
    p = "pedestrian",
    v = "vehicular",
    o = "other"
  )
  add_calculated_feature(
    tbl,
    join_on,
    calculated_features_path,
    "offense_desc.csv",
    "cc"
  ) %>%
  mutate(
    incident_type = tr_incident_type[label]
  )
}


add_calculated_feature <- function(tbl, join_on, calculated_features_path,
                                   filename, col_types) {

  feats <- read_csv(file.path(calculated_features_path, filename),
                    col_types = col_types)
  left_join(tbl, feats, by = join_on)
}


bundle_raw <- function(data, loading_problems) {
  data <- mutate(data, incident_id = seq_len(n()))
	list(data = data, metadata = list(loading_problems = loading_problems))
}


left_coalesce_cols_by_suffix <- function(tbl, left_suffix, right_suffix) {
  left_names <- which_ends_with(names(tbl), left_suffix)
  right_names <- str_replace(left_names, fixed(left_suffix), right_suffix)
  new_names <- str_replace(left_names, fixed(left_suffix), "")
  for (i in seq_along(new_names)) {
    tbl[[new_names[i]]] = coalesce(tbl[[left_names[i]]], tbl[[right_names[i]]])
  }
  select(tbl, -dplyr::ends_with(left_suffix), -dplyr::ends_with(right_suffix))
}


which_ends_with <- function(v, ending) {
  names(which(sapply(v, endsWith, ending)))
}


similar_rows <- function(tbl, threshold = 0.95) {
  tbls <- sort_all(tbl)
  sim <- rolling_row_similarity(tbls)
  idx <- which(sim >= threshold)
  idxAll <- sort(unique(c(idx - 1, idx)))
  tbls[idxAll,]
}


sort_all <- function(tbl) {
  tbl %>% arrange_(.dots=colnames(.))
}


rolling_row_similarity <- function(tbl) {
  # NOTE: you probably want rows sorted using sort_all before calling
  compare_current_row_to_previous(tbl) %>% mutate(sim = rowMeans(.)) %>%
    # TODO(danj): replace with 'pull' once dplyr updated to 0.7.0
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


similar_rows_report <- function(tbl) {
  tbl_sorted <- sort_all(tbl)
  sim <- compare_current_row_to_previous(tbl_sorted) %>% summarise_all(mean)
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


str_combine_cols <- function(left, right,
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


extract_and_add_lat_lng <- function(tbl, colname) {
  mtx <- do.call(rbind, str_extract_all(tbl[[colname]], "-?[0-9.]+"))
  colnames(mtx) <- c("incident_lat", "incident_lng")
  bind_cols(tbl, as_tibble(mtx))
}


extract_inside_parens <- function(v) {
  t <- str_extract(v, "\\([^()]+\\)") #[[1]]
  gsub("[()]", "", t)
}


first_of <- function(..., default = NA) {
  tbl <- cbind(..., "__default" = TRUE)
  nms <- colnames(tbl)
  v <- nms[apply(tbl, 1, which.max)]
  str_replace(v, "__default", as.character(default))
}


apply_translator_to <- function(tbl, translator, ...) {
  tr <- function(v) {
    translator[v]
  }
  cols <- as.vector(unlist(list(...)))
  mutate_each_(tbl, funs(tr), cols)
}


capitalize_first_letters <- function(x) {
  s <- strsplit(x, " ")[[1]]
  paste(toupper(substring(s, 1,1)), substring(s, 2),
      sep="", collapse=" ")
}


format_proper_noun <- function(x) {
  capitalize_first_letters(str_replace(x, "_", " "))
}


comma_num <- function(n) {
	prettyNum(n, big.mark = ",")
}


translator_from_tbl <- function(tbl, from, to) {
  v <- tbl[[to]]
  names(v) <- tbl[[from]]
  v
}


translate_by_char <- function(str_vec, translator, sep = "|") {
  tr <- function(v) {
    str_c(str_replace_na(translator[v]), collapse = sep)
  }
  unlist(lapply(str_split(str_vec, ""), tr))
}


parse_time_int <- function(v, fmt = "%H%M", pad_num = 4) {
  parse_time(str_pad(v, pad_num, pad = "0"), fmt)
}
