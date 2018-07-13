library(getopt)
library(lubridate)
library(tidyverse)
library(stringi)
library(stringr)
library(here)


p <- function(obj) { print(obj, n = Inf) }
tna <- function(v) { sum(is.na(v)) }


if_else_na <- function(pred, pred_true, pred_false_or_na) {
  ifelse(!is.na(pred) && pred, pred_true, pred_false_or_na)
}


create_title <- function(state, city) {
  str_c(
    format_proper_noun(city),
    toupper(state),
    sep = ", "
  )
}


make_ergonomic <- function(strs) {
  tolower(str_replace_all(strs, "[[:punct:]]| ", "_"))
}


calculate_if <- function(pred_fun, func) {
  ifelse(pred_func(), func(), NA)
}


parse_args <- function(tbl) {
  argument_types <- c("none", "required", "optional")
  tmp <- mutate(tbl,
    argument_type = parse_factor(argument_type, levels = argument_types)
  )
  getopt(as.matrix(mutate(tmp, argument_type = as.integer(argument_type) - 1)))
}


modified_time <- function(file) {
  file.info(file)$mtime
}


not_null <- function(v) {
  !is.null(v)
}


simple_map <- function(v, func) {
  unlist(map(v, func))
}


expr_to_str <- function(expr) {
  deparse(substitute(expr))
}


str_to_expr <- function(expr_str) {
  eval(parse(text = expr_str))
}


any_matches <- function(pattern, ...) {
  Reduce(function(a, b) { a | b }, lapply(list(...), str_detect, pattern))
}


elements_from_sublists <- function(lst, idx) {
  unlist(lapply(lst, `[`, idx), recursive = FALSE)
}


tokenize_path <- function(path) {
  strsplit(path, "\\/")[[1]]
}


top <- function(tbl, ..., n = 50) {
  tbl %>%
    group_by(...) %>%
    summarize(count = n()) %>%
    arrange(desc(count)) %>%
    ungroup() %>%
    slice(1:n)
}


top_str <- function(tbl, cols, n = 50) {
  tbl %>% 
    group_by_(.dots=simple_map(cols, as.name)) %>%
    summarize(count = n()) %>%
    arrange(desc(count)) %>%
    ungroup() %>%
    slice(1:n)
}


top_all <- function(tbl, exclude = c(), n = 50) {
  lapply(
    setdiff(colnames(tbl), exclude),
    function(col) { top_str(tbl, c(col)) }
  )
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


coverage_rate <- function(v) {
  1 - null_rate(v)
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


transpose_one_line_table <- function(
  tbl,
  colnames = c("names", "values"),
  f = identity
) {
  v <- elements_from_sublists(tbl, 1)
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


read_csv_with_types <- function(
  path,
  type_vec,
  na = c("", "NA", "NULL"),
  n_max = Inf
) {
  tbl <- read_csv(
    path,
    col_names = names(type_vec),
    col_types = str_c(type_vec, collapse = ""),
    na = na,
    n_max = n_max,
    skip = 1
  )
}


col_match <- function(d, pattern) {
  cols <- colnames(d)
  cols[str_detect(cols, pattern)]
}


separate_cols <- function(tbl, ..., sep = " ") {
  lst = list(...)
  for (colname in names(lst)) {
    tbl <- separate_(
      tbl,
      colname,
      lst[[colname]],
      sep = sep,
      extra = "merge"
    )
  }
  tbl
}


right_separate_cols <- function(tbl, ..., sep = " ") {
  lst = list(...)
  for (colname in names(lst)) {
    splits <- stri_split_fixed(stri_reverse(tbl[[colname]]), sep, n = 2)
    left_name <- lst[[colname]][1]
    right_name <- lst[[colname]][2]
    tbl[[left_name]] <- stri_reverse(elements_from_sublists(splits, 2))
    tbl[[right_name]] <- stri_reverse(elements_from_sublists(splits, 1))
  }
  tbl
}


add_data <- function(
  tbl,
  csv_path,
  join_on,
  col_types = cols(.default = "c"),
  rename_map = c(),
  translators = list()
) {
  left_join(
    tbl,
    read_csv(csv_path, col_types = col_types),
    by = join_on
  ) %>%
  rename_cols(
    rename_map
  ) %>%
  apply_translators(
    translators
  )
}


rename_cols <- function(tbl, rename_map) {
  # NOTE: rename_map format: c("from_1" = "to_1", "from_2" = "to_2")
  nms <- colnames(tbl)
  names(nms) <- nms
  nms[names(rename_map)] <- rename_map
  colnames(tbl) <- nms
  tbl
}


apply_translators <- function(tbl, translators) {
  # NOTE: translators format: list("col_1": c("a" = "b", "z" = "w")...)
  for (colname in names(translators)) {
    tbl[colname] <- translators[[colname]][tbl[[colname]]]
  }
  tbl
}


bundle_raw <- function(data, loading_problems, comments = list()) {
  data <- mutate(data, raw_row_number = seq_len(n()))
	list(
    data = data,
    metadata = list(
      loading_problems = loading_problems,
      comments = comments
    )
  )
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


append_to <- function(v, name, val) {
  nms <- c(names(v), name)
  v <- c(v, val)
  names(v) <- nms
  v
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


duplicate_row_count <- function(tbl) {
  tbl %>% group_by_(.dots=colnames(.)) %>%
    count %>%
    filter(n > 1) %>%
    arrange(desc(n))
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
    summarise_all(m) %>%
    ungroup()
}


all_null <- function(v) {
  all(is_null(v))
}


fill_null <- function(v, fill = NA) {
  v[is_null(v)] <- fill
  v
}


str_c_na <- function(..., sep = "", collapse = NULL) {
  # same as str_c, but ignores rather than propagates NAs when joining
  args <- lapply(list(...), str_replace_na)
  args[["sep"]] = sep
  args[["collapse"]] = collapse
  joined <- do.call(str_c, args)
  pattern <- str_c(str_c(sep, "NA"), str_c("NA", sep), "NA", sep = "|")
  str_replace_all(joined, pattern, "")
}


str_combine_cols <- function(left, right,
                             prefix_left = "", prefix_right = "",
                             sep = "||") {
  # this is the same as str_c but gracefully handles NAs and allows prefixes
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


# Sort unique values and collapse to a string.
# Useful in dply summarize after a group_by when collapsing multiple values in a
# group. NAs are omitted unless all values are NA in which case returns NA.
# Examples:
#   str_c_sort_uniq(c("A", NA, "A", NA, "B")) == "A|B"
#   str_c_sort_uniq(c("A", NA, "A", NA)) == "A"
#   str_c_sort_uniq(c(NA, NA)) == NA
#   str_c_sort_uniq(c()) == NA
str_c_sort_uniq <- function(x, collapse = "|") {
  result <- str_c(str_sort(unique(x), na_last = NA), collapse = collapse)
  ifelse(length(result) > 0, result, NA_character_)
}


extract_and_add_decimal_lat_lng <- function(tbl, colname) {
  mtx <- do.call(rbind, str_extract_all(tbl[[colname]], "-?[0-9.]+"))
  colnames(mtx) <- c("lat", "lng")
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
  str_to_title(str_replace(x, "_", " "))
}


comma_num <- function(n) {
	prettyNum(n, big.mark = ",")
}


translator_from_tbl <- function(tbl, from, to) {
  v <- tbl[[to]]
  names(v) <- tbl[[from]]
  v
}


translate_by_char <- function(char_vec, translator, collapse = "|") {
  # translate each character in a string using translator
  tr <- function(char) {
    str_c(str_replace_na(translator[char]), collapse = collapse)
  }
  unlist(lapply(str_split(char_vec, ""), tr))
}


translate_by_char_group <- function(
  char_vec,
  translator,
  group_sep,
  collapse = "|"
) {
  # translate each grouping in a string using translator i.e. AB,CD ->
  # i.e. tr = c("AB" = 1, "BC" = 2); f("AB,CD", tr, ",") -> "1|2"
  tr <- function(char_chunk) {
    str_c(str_replace_na(translator[char_chunk]), collapse = collapse)
  }
  unlist(lapply(str_split(char_vec, group_sep), tr))
}


parse_time_int <- function(v, fmt = "%H%M", pad_num = 4) {
  parse_time(str_pad(v, pad_num, pad = "0"), fmt)
}


seconds_to_hms <- function(v) {
  h = v %/% 60^2
  v = v %% 60^2
  m = v %/% 60
  s = v %% 60
  sprintf("%02d:%02d:%02d", h, m, s)
}


rename_with_str <- function(tbl, from, to) {
  rename_(tbl, .dots=setNames(names(tbl), gsub(from, to, names(tbl))))
}


format_two_digit_year <- function(yr, cutoff = year(Sys.Date())) {
  yr_int <- as.integer(yr)
  ifelse(yr_int <= cutoff - 2000, 2000 + yr_int, 1900 + yr_int)
}


# NOTE: years 2000-2029
recent_years_regex <- function() {
  "20[0-2][0-9]"
}


range_of_years_from_filenames <- function(dir, file_pattern = "") {
  all_files <- files_with_recent_year_in_name(dir)
  filtered_matches <- all_files[str_detect(all_files, file_pattern)]
  v <- as.integer(str_extract(filtered_matches, recent_years_regex()))
  seq(min(v), max(v))
}


files_with_recent_year_in_name <- function(dir) {
  list.files(dir, recent_years_regex(), full.names=T)
}


# NOTE: this is useful when a column is mostly NA, since R's c() function
# used as a lookup table has memory management issues
fast_tr <- function(v, translator) {
  dummy <- "__default"
  str_replace(translator[str_replace_na(v, dummy)], dummy, NA_character_)
} 


# NOTE: Converts a json map loaded with jsonlite to a tr.
json_to_tr <- function(json_map) {
  n <- names(json_map)
  unlist(setNames(n %>% map(function(x) { unname(unlist(json_map[x])) }), n))
}


load_similar_files <- function(
  paths,
  n_max = Inf,
  col_types = cols(.default = "c"),
  col_names = TRUE,
  skip = 0
) {
  data <- tibble()
  loading_problems <- list()
  for (path in paths) {
    bn <- basename(path)
    print(str_c('loading ', bn))
    tbl <- read_csv(
      path,
      col_types = col_types,
      col_names = col_names,
      skip = skip
    )
    data <- bind_rows(data, tbl)
    loading_problems[[bn]] <- problems(tbl)
    if (nrow(data) > n_max) {
      data <- data[1:n_max, ]
      break
    }
  }
  list(data = data, loading_problems = loading_problems)
}


load_years <- function(
  dir,
  n_max = Inf,
  col_types = cols(.default = "c"),
  col_names = TRUE,
  skip = 0
) {
  load_similar_files(
    files_with_recent_year_in_name(dir),
    n_max,
    col_types,
    col_names,
    skip
  )
}


load_regex <- function(
  dir,
  regex,
  n_max = Inf,
  col_types = cols(.default = "c"),
  col_names = TRUE,
  skip = 0
) {
  load_similar_files(
    list.files(dir, regex, full.names=T),
    n_max,
    col_types,
    col_names,
    skip
  )
}


load_single_file <- function(
  dir,
  fname,
  n_max = Inf,
  col_types = cols(.default = "c"),
  col_names = TRUE,
  skip = 0
) {
  load_regex(
    dir,
    str_c("^", fname, "$"),
    n_max,
    col_types,
    col_names,
    skip
  )
}


# Parse a lat/lng coord string as a double.
# Assumes degrees and minutes are given, seconds are optional.
# Example:
#   parse_coord("N43 28.8656'") == 43.48109
#   parse_coord("S43 28' 51.936\"") == -43.48109
#   parse_coord("41 49 30") == 41.825
#   parse_coord("-73 6 50") == -73.11389
parse_coord <- Vectorize(function(coord) {
  parts <- str_match(
    coord,
    "([WNES-])?\\s*(\\d+)\\s+(\\d+(?:\\.\\d+)?)'?(?:\\s+(\\d+(?:\\.\\d+)?)\"?)?"
  )
  min_to_deg <- 1 / 60.0
  sec_to_deg <- 1 / 3600.0
  direction <- parts[2]
  degrees <- as.double(parts[3])
  minutes <- as.double(parts[4])
  seconds <- if_else(is.na(parts[5]), 0.0, as.double(parts[5]))
  val <- degrees +
          minutes * min_to_deg +
          seconds * sec_to_deg
  if (!is.na(direction)) {
    if (direction == "W" | direction == "S" | direction == "-") {
      val <- val * -1
    }
  }
  val
})


# Calculate age at a certain date, given date of birth.
# NOTE: age returned as floating point and will differ slightly from birthday
# age due to leap years.
age_at_date <- Vectorize(function(birth_date, date) {
  as.numeric(difftime(date, birth_date), units="days") / 365.242
})
