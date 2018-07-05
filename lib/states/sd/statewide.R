source("common.R")

load_raw <- function(raw_data_dir, n_max) {
  warnings <- load_regex(raw_data_dir, "warn")
  citations <- load_regex(raw_data_dir, "cit")
  bind_rows(
      warnings$data %>% mutate(warning_issued = TRUE, citation_issued = FALSE),
      citations$data %>% mutate(warning_issued = FALSE, citation_issued = TRUE)
    ) %>%
    # NOTE: there are about 1k rows which contain asterisks and no info; drop them.
    filter(
      County != "********"
    ) %>%
    bundle_raw(c(warnings$loading_problems, citations$loading_problems))
}


clean <- function(d, helpers) {

  # TODO(phoebe): can we get reason_for_stop/search/contraband/race/etc fields?
  # https://app.asana.com/0/456927885748233/733449078894622
  d$data %>%
    rename(
      county_name = `County Freeform`,
      location = Address
    ) %>%
    separate_cols(
      `Issued Date/Time` = c("date", "time")
    ) %>%
    mutate(
      date = parse_date(date, "%Y/%m/%d"),
      time = parse_time(time, "%H:%M:%S"),
      subject_sex = tr_sex[Sex],
      violation = `Statutes/Charges`,
      outcome = first_of(
        citation = citation_issued,
        warning = warning_issued
      ),
      vehicle_color = `Color 1`,
      vehicle_make = Make,
      vehicle_model = Model,
      vehicle_year = Year,
      vehicle_registration_state = `Plate State`
    ) %>%
    standardize(d$metadata)
}
