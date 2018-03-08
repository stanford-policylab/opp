source("common.R")

load_raw <- function(raw_data_dir, n_max) {
  # TODO(phoebe): what are FI CARDS?
  # https://app.asana.com/0/456927885748233/585575759775409 

  # NOTE: there is a list_of_officers.csv as well as the excel spreadsheet
  # (preferable given the formatting) that have more officer information.
  loading_problems <- list()
  r <- function(fname) {
    tbl <- read_csv(file.path(raw_data_dir, fname),
                    col_types = cols(.default = "c"))
    loading_problems[[fname]] <<- problems(tbl)
    tbl
  }

  data <- tibble()
  for (fname_prefix in c("2015-2016_traffic_", "2017_traffic_")) {
    tbl <- r(
        str_c(fname_prefix, "citations.csv")
      ) %>%
      left_join(
        r(str_c(fname_prefix, "location.csv")),
        by = "CONTROL NUMBER"
      ) %>%
      left_join(
        r(str_c(fname_prefix, "offender.csv")),
        by = "CONTROL NUMBER"
      )
    data <- bind_rows(data, tbl)
  }

  if (nrow(data) > n_max) {
    data <- data[1:n_max,]
  }

  violations <- r("violation_codes_sheet_1.csv") %>%
    rename(code = `Viol. Code`) %>%
    mutate(code = str_pad(code, width = 5, pad = "0"))
  violations_colnames <- colnames(violations)
  for (i in seq(1:9)) {
    colnames(violations) <- str_c(violations_colnames, " ", i)
    join_by <- c(str_c("code ", i))
    names(join_by) <- str_c("VIOLATION CODE ", i)
    data <- left_join(
      data,
      violations,
      by = join_by
    )
  }

  bundle_raw(data, loading_problems)
}


clean <- function(d, calculated_features_path) {

  d$data %>%
    standardize(d$metadata)
}
