source("common.R")

load_raw <- function(raw_data_dir, n_max) {
  d <- load_years(raw_data_dir, n_max)
  colnames(d$data) <- make_ergonomic(colnames(d$data))
  bundle_raw(d$data, d$loading_problems)
}


clean <- function(d, helpers) {

  tr_race <- c(
    "A" = "asian/pacific islander",
    "B" = "black",
    "I" = "other/unknown",
    "U" = "other/unknown",
    "W" = "white",
    "H" = "hispanic"
  )

  # TODO(phoebe): can we get reason_for_stop/search/contraband fields?
  # https://app.asana.com/0/456927885748233/595493946182532
  d$data %>%
    filter(
      # NOTE: filter out PARKING related charges
      !str_detect(charge_description, "PARKING")
    ) %>%
    rename(
      subject_age = defendant_age,
      # TODO(ravi): is this acceptable? should we filter out anything else?
      # https://app.asana.com/0/456927885748233/595493946182533
      violation = charge_description,
      disposition = charge_disposition
    ) %>%
    right_separate_cols(
      officer_name = c("officer_first_name", "officer_last_name")
    ) %>%
    mutate(
      # NOTE: all charge descriptions appear to be vehicle related
      type = "vehicular",
      datetime = coalesce(
        parse_datetime(citation_date_time, locale = locale(tz = "US/Central")),
        parse_datetime(citation_date_time, "%Y/%m/%d %H:%M:%S"),
        parse_datetime(citation_date_time, "%Y/%m/%d")
      ),
      date = as.Date(datetime),
      time = format(datetime, "%H:%M:%S"),
      # NOTE: all the files are named citations_<year>.csv
      citation_issued = TRUE,
      # TODO(phoebe): can we get other outcomes (warnings, arrests)?
      # https://app.asana.com/0/456927885748233/595493946182534
      location = str_c_na(
        citation_location,
        citation_city,
        citation_state,
        citation_zip,
        sep = ", "
      ),
      outcome = "citation",
      subject_race = tr_race[if_else_na(
        defendant_ethnicity == "H",
        "H",
        defendant_race
      )],
      subject_sex = tr_sex[defendant_sex]
    ) %>%
    helpers$add_lat_lng(
    ) %>%
    standardize(d$metadata)
}
