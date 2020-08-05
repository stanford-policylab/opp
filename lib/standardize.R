library(here)
source(here::here("lib", "utils.R"))
source(here::here("lib", "sanitizers.R"))


standardize <- function(data, metadata) {
  # NOTE: rows that were merged will likley have some values coerced to NA when
  # types are enforced. For instance, let's say a car was stopped with 2 people
  # ages 18 and 22, with a row per person for that stop. If those rows are
  # merged, the age value in that record will be 18<sep>22; when age is later
  # coerced to an integer type, this value will be coerced to NA; typically,
  # this is what you want unless you have some logic for selecting one value
  # over another; if that's the case, a new column should be created that
  # reflects that choice
  d <- list(
      data = data,
      # collect metadata local to standardize here
      metadata = list()
    ) %>%
    add_calculated_columns %>%
    select_only_schema_cols %>%
    enforce_types %>%
    correct_predicates %>%
    sanitize

  # put all local metadata in standarize sublist of all metadata
  metadata[["standardize"]] <- d$metadata

  print("finished!")

  list(
    data = d$data,
    metadata = metadata
  )
}


add_calculated_columns <- function(d) {
  print("adding calculated columns...")
  for(col in colnames(d$data)) {
    if (endsWith(col, "_dob")) {
      new_colname <- str_c(prefix(col), "_", "age")
      d$data[[new_colname]] <- age_at_date(d$data[[col]], d$data[["date"]])
    }
    # retain manually calculated officer_id_hash
    if (col == "officer_id" && !("officer_id_hash" %in% colnames(d$data))) {
      d$data[["officer_id_hash"]] <- simple_map(d$data[[col]], simple_hash)
    }
  }
  d
}


select_only_schema_cols <- function(d) {
  cols <- colnames(d$data)
  target_cols <- intersect(names(schema), cols)
  target_raw_cols <- cols[str_detect(cols, "^raw_")]
  d$data <- select_(d$data, .dots = c(target_cols, target_raw_cols))
  d
}


enforce_types <- function(d) {
  print("enforcing standard types...")
  res <- apply_schema_and_collect_null_rates(schema, d$data)
  d$data <- res$data
  d$metadata[["enforce_types"]] <- res$null_rates
  d
}


correct_predicates <- function(d) {
  print("correcting predicated columns...")
  # TODO(danj): add a function record not just change in null rates but
  # distribution of values, i.e. TRUE -> FALSE
  f <- function(if_not) {
    # hack to capture value
    default <- if_not
    function(predicated_v, predicate_v) {
      if_else(predicate_v, predicated_v, default)
    }
  }
  predication_schema <- c()
  predicates <- c()
  for (predicated_column in names(predicated_columns)) {
    if (predicated_column %in% colnames(d$data)) {
      predicate_column <- predicated_columns[[predicated_column]]$predicate
      if_not <- predicated_columns[[predicated_column]]$if_not
      predication_schema <- append_to(
        predication_schema,
        predicated_column,
        f(if_not)
      )
      predicates[predicated_column] <- predicate_column
    }
  }
  res <- apply_predicated_schema_and_collect_null_rates(
    predication_schema,
    predicates,
    d$data
  )
  d$data <- res$data
  d$metadata[["predication_correction"]] <- res$null_rates
  d
}


prefix <- function(s) {
  str_split(s, "_")[[1]][1]
}


sanitize <- function(d) {
  print("sanitizing...")
  # NOTE: be careful that these don't try to sanitize raw_* columns
  sanitize_schema <- c()
  for (col in colnames(d$data)) {
    if (endsWith(col, "date")) {
      sanitize_schema <- append_to(sanitize_schema, col, sanitize_date)
    }
    if (endsWith(col, "age")) {
      sanitize_schema <- append_to(sanitize_schema, col, sanitize_age)
    }
    if (endsWith(col, "dob")) {
      sanitize_schema <- append_to(
        sanitize_schema,
        col,
        sanitize_dob_func(d$data$date)
      )
    }
    if (col == "speed" | col == "posted_speed") {
      sanitize_schema <- append_to(
        sanitize_schema,
        col,
        sanitize_speed
      )
    }
    if (col == "vehicle_year") {
      sanitize_schema <- append_to(
        sanitize_schema,
        col,
        sanitize_vehicle_year_func(d$data$date)
      )
    }
    if (
      !(col %in% c(
        "raw_row_number",
        "violation",
        "disposition",
        "location",
        "subject_drivers_license",
        "officer_assignment",
        "officer_id",
        "officer_id_hash",
        quos_names(city_subgeographies),
        quos_names(state_subgeographies),
        "unit",
        "vehicle_color",
        "vehicle_license_plate",
        "vehicle_make",
        "vehicle_model",
        "vehicle_type",
        "raw_driver_race",
        "raw_race",
        "raw_subject_race"
      ))
      & get_primary_class(d$data[[col]]) == "character"
    ) {
      sanitize_schema <- append_to(sanitize_schema, col, sanitize_digits)
    }
  }
  x <- apply_schema_and_collect_null_rates(sanitize_schema, d$data)
  d$data <- x$data
  d$metadata[["sanitize"]] <- x$null_rates
  d
}
