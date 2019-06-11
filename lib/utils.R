library(digest)
library(getopt)
library(here)
library(lazyeval)
library(lubridate)
library(parallel)
library(rlang)
library(stringi)
library(stringr)
library(tidylog)
library(tidyverse)


`%|%` <- function(d, func) {
  # logging pipe; use is identical to %>% except each function in the pipeline
  # must have the signature <func_name>(tbl, log) where log is a function that
  # allows a user defined function to log to a global metadata object.
  # examples:
  # f <- function(tbl, log) { log("banana"); filter(tbl, v > 5) }
  # f <- function(tbl, log) { log(list(apple = "banana")); filter(tbl, v > 5) }
  # the function only needs to return the data tibble

  func_name <- lazyeval::expr_text(func)

  if (get_primary_class(d) != "list") {
    d <- list(data = d, metadata = list())
  }

  # add call number suffix to avoid overwriting metadata
  n <- sum(str_detect(names(d$metadata), str_c("^", func_name)))
  if (n > 0) { func_name <- str_c(func_name, "_", n + 1) }

  d$metadata[[func_name]] <- list()
  log_to_metadata <- function(key) {
    function(info) {
      d$metadata[[func_name]][[key]] <<- info
    }
  }
  options("tidylog.display" = list(log_to_metadata("dplyr")))

  d$data <- func(d$data, log_to_metadata("custom"))

  d
}


add_data <- function(
  tbl,
  data,
  join_on,
  col_types = cols(.default = "c"),
  rename_map = c(),
  translators = list()
) {
  left_join(
    tbl,
    data,
    by = join_on
  ) %>%
  rename_cols(
    rename_map
  ) %>%
  apply_translators(
    translators
  )
}


add_prefix <- function(v, prefix, skip = c()) {
  idx <- !(v %in% skip)
  v[idx] <- str_replace(v[idx], "^", prefix)
  v
}


add_raw_colname_prefix <- function(tbl, ...) {
  colqs <- enquos(...)
  nms <- quos_names(colqs)
  new_nms <- simple_map(nms, function(nm) { str_c("raw_", nm) })
  names(new_nms) <- nms
  rename_cols(tbl, new_nms)
}


age_at_date <- function(birth_date, date) {
  # Calculate age at a certain date, given date of birth.
  # NOTE: age returned as floating point and will differ slightly from birthday
  # age due to leap years.
  as.numeric(
    difftime(
      parse_date(date),
      parse_date(birth_date),
      units = "days"
    )
  ) / 365.242
}


all_null <- function(v) {
  all(is_null(v))
}


any_matches <- function(pattern, ...) {
  Reduce(function(a, b) { a | b }, lapply(list(...), str_detect, pattern))
}


append_to <- function(v, name, val) {
  nms <- c(names(v), name)
  v <- c(v, val)
  names(v) <- nms
  v
}


apply_and_collect_null_rates <- function(f, v, ...) {
	null_rate_before <- null_rate(v)
	v <- f(v, ...)
	null_rate_after <- null_rate(v)
	list(
		v = v,
		null_rates = c(
			null_rate_before = null_rate_before,
			null_rate_after = null_rate_after
		)
	)
}


apply_predicated_schema_and_collect_null_rates <- function(
  schema,
  predicates,
  data
) {
  # NOTE: because closures copy the data at the time they are composed, if you
  # have cascading dependencies, they won't be observed, i.e. contraband_drugs
  # depends on contraband_found, which in turn depends on search_conducted. If
  # contraband_found is mutated based on search_conducted, when
  # contraband_drugs is mutated, it will be using the original, unmutated copy
  # of contraband_found, not the updated one. This function had to be added
  # because apply_schema_and_collect_null_rates doesn't respect these dynamic
  # dependencies.
  null_rates <- list()
  for (name in names(schema)) {
		if (name %in% colnames(data)) {
			x <- apply_and_collect_null_rates(
        schema[[name]],
        data[[name]],
        data[[predicates[[name]]]]
      )
			data[[name]] <- x$v
			null_rates[[name]] <- x$null_rates 
		}
  }
  list(data = data, null_rates = create_null_rates_tbl(null_rates))
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


apply_translator_to <- function(tbl, translator, ...) {
  tr <- function(v) {
    translator[v]
  }
  cols <- as.vector(unlist(list(...)))
  mutate_at(tbl, cols, funs(tr))
}


apply_translators <- function(tbl, translators) {
  # NOTE: translators format: list("col_1": c("a" = "b", "z" = "w")...)
  for (colname in names(translators)) {
    tbl[colname] <- translators[[colname]][tbl[[colname]]]
  }
  tbl
}


bool_to_pct <- function(data, lgl, ...) {
  # Returns data counts of a logical variable, grouped by 
  # specified grouping variables, along with the percent 
  # (within grouping variables) of observations for which logical is true 
  #
  # Inputs:
  #   data (tibble)
  #       in particular, a dataframe containing vars @... and @lgl
  #   lgl (variable name)
  #       logical variable of which we want to know percent true
  #   ... (variable names)
  #       name of grouping variables within which we want to know percents of @lgl
  # Outputs:
  #       data (tibble) with fields
  #         ... - same grouping vars as input
  #         n - count num for which @lgl == TRUE
  #         total - sum(n) for each elt in grouping_var
  #         p_lgl = n / total
  #
  grouping_vars <- quos(...)
  lgl <- enquo(lgl)
  n_lgl_name <- str_c("n_", quo_name(lgl))
  p_lgl_name <- str_c("p_", quo_name(lgl))
  
  data %>% 
    count(!!lgl, !!!grouping_vars) %>% 
    spread(!!lgl, n, fill = 0) %>% 
    group_by(!!!grouping_vars) %>% 
    mutate(
      n = `TRUE`,
      total = sum(n, `FALSE`),
      !!p_lgl_name := n / total
    ) %>% 
    select(-`TRUE`, -`FALSE`) %>% 
    ungroup()
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


calculate_if <- function(pred_fun, func) {
  ifelse(pred_func(), func(), NA)
}


comma_num <- function(n) {
	prettyNum(n, big.mark = ",")
}


compare_current_row_to_previous <- function(tbl) {
  # NOTE: there will be 1 fewer rows than in original table, since first row
  # has no previous row
  diffs <- as_tibble(
    # equal or both NA
    tbl[-1,] == tbl[-nrow(tbl),] | (is.na(tbl[-1,]) & is.na(tbl[-nrow(tbl),]))
  ) %>% 
  # covers cases where one is NA and the other isn't
  mutate_all(
    funs(replace(., is.na(.), FALSE))
  )
}


count_pct <- function(data, ...) {
  # Returns data counts and percent of a numeric variable 
  #
  # Inputs:
  #   data (tibble)
  #       in particular, a dataframe containing vars @... and @x
  #   ... (variable names)
  #       variables of which we want to know percent of each pairs of factors
  # Outputs:
  #       data (tibble) with fields
  #         n = count num for each factor in @...
  #         p = n / total
  #
  x <- quos(...)
  
  data %>% 
    ungroup() %>% 
    count(!!!x) %>% 
    mutate(p = n / sum(n)) %>% 
    arrange(desc(p))
}


coverage_rate <- function(v) {
  1 - null_rate(v)
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


create_title <- function(state, city) {
  str_c(
    format_proper_noun(city),
    toupper(state),
    sep = ", "
  )
}


detect_ssn <- function(v) {
  str_detect(as.character(v), ssn_regex())
}


disaggregate <- function(df, n, ...) {
  # Disaggregate `df` by creating `n` repetitions of the input rows.  Pass `n`
  # as the variable indicating how many times a row should be repeated, and
  # pass any variables that should appear in the output table. When no columns
  # are given explicitly, all columns will be included in the output.
  #
  # Example:
  #
  #  df <- tribble(
  #    ~n, ~X , ~Y , ~Z   ,
  #     2, "a", "q", "foo",
  #     3, "b", "r", "bar",
  #     0, "c", "s", "baz"
  #  )
  #
  #  disaggregate(df, n, my_x=X, my_y=Y)
  #
  #   my_x | my_y
  #  -------------
  #   a    | q
  #   a    | q
  #   b    | r
  #   b    | r
  #   b    | r
  #
  #  Note that X and Y are repeated according to `n`, renamed according to
  #  the invocation of the function, and the column Z has been dropped.
  #
  #  Note also that `n` can be an expression.

  # Compute the count vector based on `n`, which may be an expression.
  n <- enquo(n)
  n_clean <- eval_tidy(
    quo(
      # Ensure there are no NA values in this vector. Drop rows that would
      # have an NA count.
      coalesce(as.integer(!!n), 0L)
    ),
    data=df
  )

  # Gather all the column vectors we want to include in the output. When no
  # columns are specified (i.e., no dots are passed), include all columns.
  vecs <- c()
  if (missing(...)) {
    for (name in names(df)) {
      vecs[[name]] <- df[[name]]
    }
  } else {
    dots <- quos(...)
    for (name in names(dots)) {
      vecs[[name]] <- eval_tidy(dots[[name]], data=df)
    }
  }

  # Compute repetitions for columns.
  cols <- c()
  for (colname in names(vecs)) {
    vec <- vecs[[colname]]
    cols[[colname]] <- rep(vec, n_clean)
  }

  # Construct table using repeated columns.
  do.call(tibble, cols)
}


duplicate_row_count <- function(tbl) {
  tbl %>% group_by_(.dots=colnames(.)) %>%
    count %>%
    filter(n > 1) %>%
    arrange(desc(n))
}


elements_from_sublists <- function(lst, idx) {
  unlist(lapply(lst, `[`, idx), recursive = FALSE)
}


expr_to_str <- function(expr) {
  deparse(substitute(expr))
}


extract_and_add_decimal_lat_lng <- function(tbl, colname) {
  mtx <- do.call(rbind, str_extract_all(tbl[[colname]], "-?[0-9.]+"))
  colnames(mtx) <- c("lat", "lng")
  bind_cols(tbl, as_tibble(mtx))
}


fast_tr <- function(v, translator) {
  # NOTE: this is useful when a column is mostly NA, since R's c() function
  # used as a lookup table has memory management issues
  dummy <- "__default"
  str_replace(translator[str_replace_na(v, dummy)], dummy, NA_character_)
}


files_with_recent_year_in_name <- function(dir) {
  list.files(dir, recent_years_regex(), full.names=T)
}


fill_null <- function(v, fill = NA) {
  v[is_null(v)] <- fill
  v
}


first_of <- function(..., default = NA) {
  tbl <- cbind(..., "__default" = TRUE)
  nms <- colnames(tbl)
  v <- nms[apply(tbl, 1, which.max)]
  str_replace(v, "__default", as.character(default))
}


format_proper_noun <- function(x) {
  str_to_title(str_replace(x, "_", " "))
}


format_two_digit_year <- function(yr, cutoff = year(Sys.Date())) {
  yr_int <- as.integer(yr)
  as.integer(if_else(yr_int <= cutoff - 2000, 2000 + yr_int, 1900 + yr_int))
}


get_primary_class <- function(obj) {
  class(obj)[1]
}


if_else_na <- function(pred, pred_true, pred_false_or_na) {
  if_else(!is.na(pred) & pred, pred_true, pred_false_or_na)
}


is_null <- function(v) {
  if (is.character(v)) {
    is.na(v) | v == "NA" | v == "" | v == "NULL"
  } else {
    is.na(v)
  }
}


json_to_tr <- function(json_map) {
  # NOTE: Converts a json map loaded with jsonlite to a tr.
  nms <- names(json_map)
  unlist(setNames(
    nms %>% purrr::map(function(x) { unname(unlist(json_map[x])) }),
    nms
  ))
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


load_all_csvs <- function(
  dir,
  n_max = Inf,
  col_types = cols(.default = "c"),
  col_names = TRUE,
  skip = 0,
  na = c("", "NA")
) {
  load_regex(
    dir,
    "\\.csv$",
    n_max,
    col_types,
    col_names,
    skip,
    na
  )
}


parse_coord <- Vectorize(function(coord) {
  # Parse a lat/lng coord string as a double.
  # Assumes degrees and minutes are given, seconds are optional.
  # Example:
  #   parse_coord("N43 28.8656'") == 43.48109
  #   parse_coord("S43 28' 51.936\"") == -43.48109
  #   parse_coord("41 49 30") == 41.825
  #   parse_coord("-73 6 50") == -73.11389
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
  val <- degrees + minutes * min_to_deg + seconds * sec_to_deg
  if (!is.na(direction)) {
    if (direction == "W" | direction == "S" | direction == "-") {
      val <- val * -1
    }
  }
  val
})


load_regex <- function(
  dir,
  regex,
  n_max = Inf,
  col_types = cols(.default = "c"),
  col_names = TRUE,
  skip = 0,
  na = c("", "NA")
) {
  load_similar_files(
    list.files(dir, regex, full.names=T),
    n_max,
    col_types,
    col_names,
    skip,
    na
  )
}


load_similar_files <- function(
  paths,
  n_max = Inf,
  col_types = cols(.default = "c"),
  col_names = TRUE,
  skip = 0,
  na = c("", "NA")
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
      skip = skip,
      na = na
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


load_single_file <- function(
  dir,
  fname,
  n_max = Inf,
  col_types = cols(.default = "c"),
  col_names = TRUE,
  skip = 0,
  na = c("", "NA")
) {
  load_regex(
    dir,
    str_c("^", fname, "$"),
    n_max,
    col_types,
    col_names,
    skip,
    na
  )
}


load_years <- function(
  dir,
  n_max = Inf,
  col_types = cols(.default = "c"),
  col_names = TRUE,
  skip = 0,
  na = c("", "NA")
) {
  load_similar_files(
    files_with_recent_year_in_name(dir),
    n_max,
    col_types,
    col_names,
    skip,
    na
  )
}


make_ergonomic <- function(strs) {
  str_replace_all(
    tolower(strs),
    c(
      # replace spaces with underscores
      " " = "_",
      # make '#' human readable
      "#" = "number",
      # replace punctuation with underscores
      "[[:punct:]]" = "_",
      # replace n contiguous underscores with one
      "__+" = "_",
      # remove leading and trailing underscores
      "^_+|_+$" = ""
    )
  )
}


make_ergonomic_colnames <- function(tbl) {
  colnames(tbl) <- make_ergonomic(colnames(tbl))
  tbl
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


modified_time <- function(file) {
  file.info(file)$mtime
}


not_null <- function(v) {
  !is.null(v)
}


null_rate <- function(v) {
	round(sum(is_null(v)) / length(v), 4)
}


null_rates <- function(tbl) {
  nulls_tbl <- tbl %>% summarize_all(funs(null_rate))
  transpose_one_line_table(
    nulls_tbl,
    colnames = c("feature", "null rate"),
    f = pretty_percent
  )
}


p <- function(obj) { print(obj, n = Inf) }


par_pmap <- function(
  .l,
  .f,
  ...,
  mc.cores = max(parallel::detectCores() / 2, 1L)
) {
  # source: https://goo.gl/8sdnw5
  do.call(
    parallel::mcmapply, 
    c(
      .l,
      list(
        FUN = .f,
        MoreArgs = list(...),
        SIMPLIFY = FALSE,
        mc.cores = mc.cores
      )
    )
  )
}


parse_args <- function(tbl) {
  argument_types <- c("none", "required", "optional")
  tmp <- mutate(tbl,
    argument_type = parse_factor(argument_type, levels = argument_types)
  )
  getopt(as.matrix(mutate(tmp, argument_type = as.integer(argument_type) - 1)))
}


parse_time_int <- function(v, fmt = "%H%M", pad_num = 4) {
  parse_time(str_pad(v, pad_num, pad = "0"), fmt)
}


pct_tbl <- function(v, colnames = c("name", "pct")) {
  tbl <- as_tibble(prop.table(table(v)) * 100)
  names(tbl) <- colnames
  tbl
}


pct_warning <- function(rate, message) {
  warning(
    str_c(
      formatC(100 * rate, format = "f", digits = 2), 
      "% ",
      message
    ),
    call. = FALSE
  )
}


predicated_coverage_rates <- function(tbl, pred_v) {
  predicated_null_rates(tbl, pred_v) %>%
  mutate(`coverage rate` = 1 - `null rate`) %>%
  select(feature, `coverage rate`)
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
    colnames = c("feature", "null rate")
  )
}


pretty_percent <- function(v, d = 2) {
  str_c(formatC(100 * v, format = "f", digits = d), "%")
}


quos_names <- function(quos_var) { sapply(quos_var, quo_name) }


range_of_years_from_filenames <- function(dir, file_pattern = "") {
  all_files <- files_with_recent_year_in_name(dir)
  filtered_matches <- all_files[str_detect(all_files, file_pattern)]
  v <- as.integer(str_extract(filtered_matches, recent_years_regex()))
  seq(min(v), max(v))
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


recent_years_regex <- function() {
  # NOTE: years 2000-2029
  "20[0-2][0-9]"
}


rename_cols <- function(tbl, rename_map) {
  # NOTE: rename_map format: c("from_1" = "to_1", "from_2" = "to_2")
  nms <- colnames(tbl)
  rm <- rename_map[names(rename_map) %in% nms]
  names(nms) <- nms
  nms[names(rm)] <- rm
  colnames(tbl) <- nms
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


rolling_row_similarity <- function(tbl) {
  # NOTE: you probably want rows sorted using sort_all before calling
  compare_current_row_to_previous(tbl) %>% mutate(sim = rowMeans(.)) %>%
    # TODO(danj): replace with 'pull' once dplyr updated to 0.7.0
    select(sim) %>% collect %>% .[["sim"]]
}


seconds_to_hms <- function(v) {
  h = v %/% 60^2
  v = v %% 60^2
  m = v %/% 60
  s = v %% 60
  sprintf("%02d:%02d:%02d", h, m, s)
}


select_and_filter_missing <- function(d, ...) {
  colqs <- enquos(...)
  before_drop_na <- nrow(d$data)
  d$data <- select(d$data, !!!colqs) %>% drop_na
  after_drop_na <- nrow(d$data)
  null_percent <- (before_drop_na - after_drop_na) / before_drop_na
  d$metadata["null_rate"] <- null_percent
  if (null_percent > 0) {
    pct_warning(
      null_percent,
      "of data dropped due to missing values in required columns"
    )
  }
  d
}


select_least_na <- function(tbl, cols, rename = NA) {
  # NOTE: if the column doesn't exist, it's assumed to be all NA
  tbl <- select_or_add_as_na(
    tbl,
    cols
  ) %>%
  select_if(
    funs(which.min(sum(is.na(.))))
  )
  if (!is.na(rename)) {
    colnames(tbl) <- c(rename)
  }
  tbl
}


select_or_add_as_na <- function(tbl, desired_cols) {
  actual_cols <- colnames(tbl)
  overlap_cols <- intersect(desired_cols, actual_cols)
  missing_cols <- setdiff(desired_cols, actual_cols)
  tbl <- select_(tbl, .dots = overlap_cols)
  for (missing_col in missing_cols) {
    tbl[missing_col] <- NA
  }
  tbl
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


similar_rows <- function(tbl, threshold = 0.95) {
  tbls <- sort_all(tbl)
  sim <- rolling_row_similarity(tbls)
  idx <- which(sim >= threshold)
  idxAll <- sort(unique(c(idx - 1, idx)))
  tbls[idxAll,]
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


simple_map <- function(v, func) {
  unlist(purrr::map(v, func))
}


sort_all <- function(tbl) {
  tbl %>% arrange_(.dots=colnames(.))
}


ssn_regex <- function() {
  "([^\\d]|^)(\\d{3}[- ]?\\d{2}[- ]?\\d{4})([^\\d]|$)"
}


str_c_na <- function(..., sep = ", ") {
  # str_c_na(c("a", "b", "c"), c("1", "2", "3"), sep = "|")
  # "a|1" "b|2" "c|3"
  joined <- unite(tibble(...), sep = sep)[[1]]
  sep_literal <- str_c("\\Q", sep, "\\E")
  pattern <- str_c(
    str_c(sep_literal, "NA"),
    str_c("NA", sep_literal),
    "NA",
    sep = "|"
  )
  str_replace_all(joined, pattern, "")
}


str_c_sort_uniq <- function(x, collapse = "|") {
  # Sort unique values and collapse to a string.  Useful in dplyr summarize
  # after a group_by when collapsing multiple values in a group. NAs are
  # omitted unless all values are NA in which case returns NA.
  # Examples:
  #   str_c_sort_uniq(c("A", NA, "A", NA, "B")) == "A|B"
  #   str_c_sort_uniq(c("A", NA, "A", NA)) == "A"
  #   str_c_sort_uniq(c(NA, NA)) == NA
  #   str_c_sort_uniq(c()) == NA
  result <- str_c(str_sort(unique(x), na_last = NA), collapse = collapse)
  ifelse(length(result) > 0, result, NA_character_)
}


str_combine_cols <- function(
  left,
  right,
  prefix_left = "",
  prefix_right = "",
  sep = "||"
) {
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


str_detect_na <- function(v, pattern, na_value = F) {
  replace_na(str_detect(v, pattern), na_value)
}


str_to_expr <- function(expr_str) {
  eval(parse(text = expr_str))
}


tokenize_path <- function(path) {
  strsplit(path, "\\/")[[1]]
}


top <- function(tbl, ..., n = 1000) {
  tbl %>%
    group_by(...) %>%
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


top_str <- function(tbl, cols, n = 50) {
  tbl %>% 
    group_by_(.dots = simple_map(cols, as.name)) %>%
    summarize(count = n()) %>%
    arrange(desc(count)) %>%
    ungroup() %>%
    slice(1:n)
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


translator_from_tbl <- function(tbl, from, to) {
  v <- tbl[[to]]
  names(v) <- tbl[[from]]
  v
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


unique_value <- function(x) {
  # Returns the unique value in a list if one exists, otherwise NA.
  if_else(n_distinct(x, na.rm = T) == 1, first(x), NA_character_)
}


which_ends_with <- function(v, ending) {
  names(which(sapply(v, endsWith, ending)))
}
