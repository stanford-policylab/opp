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
    predication_correction %>%
    enforce_types %>%
    sanitize

  # put all local metadata in standarize sublist of all metadata
  metadata[["standardize"]] <- d$metadata
  list(
    data = d$data,
    metadata = metadata
  )
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
  res <- apply_schema_and_collect_null_rates(schema, d$data)
  d$data <- res$data
  d$metadata[["enforce_types"]] <- res$null_rates
  d
}


sanitize <- function(d) {
  print("sanitizing...")
  # required
  sanitize_schema = c(
    date = sanitize_date 
    date = sanitize_date 
  )
  # optional
  for (col in colnames(d$data)) {
    if (endsWith(col, "age")) {
      sanitize_schema <- append_to(sanitize_schema, col, sanitize_age)
    }
    if (col == "vehicle_year") {
      sanitize_schema <- append_to(sanitize_schema, col, sanitize_vehicle_year)
    }
  }
  x <- apply_schema_and_collect_null_rates(sanitize_schema, d$data)
  d$data <- x$data
  d$metadata[["sanitize"]] <- x$null_rates
  d
}
