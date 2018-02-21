library(dplyr)

source("sanitizers.R")
source("standards.R")


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
    add_missing_required_columns %>%
    predication_correction %>%
    enforce_types %>%
    sanitize %>%
    select_schema_cols

  # put all local metadata in standarize sublist of all metadata
  metadata[["standardize"]] <- d$metadata
  list(
    data = d$data,
    metadata = metadata
  )
}


add_missing_required_columns <- function(d) {
  print("adding missing required columns...")
  added <- c()
  for (name in names(required_schema)) {
    if (!(name %in% colnames(d$data))) {
      if (name == "incident_id") {
        d$data[[name]] <- seq.int(nrow(d$data))
      } else {
        d$data[[name]] <- NA
      }
      added <- c(added, name)
    }
  }
  d$metadata[["add_missing_required_columns"]] <- sort(added)
  d
}


predication_correction <- function(d) {
  print("correcting predicated columns...")
  for (predicated_column in names(predicated_columns)) {
    if (predicated_column %in% colnames(d$data)) {
      predicate = predicated_columns[[predicated_column]]$predicate
      if_not = predicated_columns[[predicated_column]]$if_not
      d$data[[predicated_column]] <- ifelse(as.logical(d$data[[predicate]]),
                                            d$data[[predicated_column]],
                                            if_not)
    }
  }
  d
}


enforce_types <- function(d) {
  print("enforcing standard types...")
  req <- apply_schema_and_collect_null_rates(required_schema, d$data)
  ext <- apply_schema_and_collect_null_rates(extra_schema, req$data)
  d$data <- ext$data
  d$metadata[["enforce_types"]] <- bind_rows(req$null_rates, ext$null_rates)
  d
}


sanitize <- function(d) {
  print("sanitizing...")
  # required
  sanitize_schema = c(
    incident_date = sanitize_incident_date 
  )
  # optional
  for (col in colnames(d$data)) {
    if (endsWith(col, "age")) {
      sanitize_schema <- cs(sanitize_schema, col, sanitize_age)
    }
    if (col == "vehicle_year") {
      sanitize_schema <- cs(sanitize_schema, col, sanitize_vehicle_year)
    }
  }
  x <- apply_schema_and_collect_null_rates(sanitize_schema, d$data)
  d$data <- x$data
  d$metadata[["sanitize"]] <- x$null_rates
  d
}


select_schema_cols <- function(d) {
  print("selecting schema columns first...")
  req <- names(required_schema)
  extra <- Filter(function(n) { n %in% colnames(d$data) }, names(extra_schema))
  d$data <- select_(d$data, .dots = c(req, extra))
  d
}
