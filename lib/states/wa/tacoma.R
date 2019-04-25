source("common.R")


# VALIDATION: [YELLOW] The Tacoma PD hosts a crime map on their website, but
# doesn't appear to produce annual reports or traffic statistics. 2007 and 2017
# only have partial data. That said, that data looks relatively reasonable.
# TODO(phoebe): Why does the number of stops decrease so dramatically from 2009
# to 2017?
# https://app.asana.com/0/456927885748233/955159586009898
load_raw <- function(raw_data_dir, n_max) {
  d <- load_single_file(raw_data_dir, "pdr100317tpdstops_sheet_1.csv", n_max)
  bundle_raw(d$data, d$loading_problems)
}


clean <- function(d, helpers) {
  # NOTE: reason for stop not recorded
  # NOTE: search/contraband not in database, only in written reports
  # NOTE: subject race is not recorded
  d$data %>%
  rename(
    location = Location,
    officer_id = Unit,
    # NOTE: this is actually closer to outcome, but doesn't seem to have
    # rigid categories, so passing through as reason_for_stop and providing
    # the more standardized classification in `outcome`
    disposition = Disposition
  ) %>%
  mutate(
    # NOTE: T = "Traffic Stop", SS = "Subject Stop"
    type = if_else(Type == "T", "vehicular", "pedestrian"),
    d1 = parse_date(Date, "%Y/%m/%d"),
    t1 = parse_time(Time, "%H:%M:%S"),
    dt = parse_date(Date, "%Y/%m/%d %H:%M:%S"),
    d2 = as.Date(dt),
    t2 = parse_time(format(dt, "%H:%M:%S")),
    date = coalesce(d1, d2),
    time = coalesce(t1, t2),
    warning_issued = str_detect(disposition, "Warning"),
    citation_issued = str_detect(disposition, "Citation"),
    arrest_made = str_detect(disposition, "Arrest"),
    # TODO(ravi): do we want to filter out outcomes we don't care about?
    # https://app.asana.com/0/456927885748233/590576541432184
    outcome = first_of(
      arrest = arrest_made,
      citation = citation_issued,
      warning = warning_issued
    )
  ) %>%
  helpers$add_lat_lng(
  ) %>%
  helpers$add_shapefiles_data(
  ) %>%
  rename(
    sector = SECTOR,
    subsector = SUBSECTOR
  ) %>%
  standardize(d$metadata)
}
