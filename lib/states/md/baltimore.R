source("common.R")


# VALIDATION: [RED] A lot of key features are missing here, and the annual
# report for 2016 only has one statistic that can really be used for evaluating
# the likelihood that this data is valid: the number of total calls for
# service, which was 992k. 2016 had 127k stops in this dataset, which is
# probably reasonable. See TODOs for oustanding tasks
load_raw <- function(raw_data_dir, n_max) {
  d <- load_years(raw_data_dir, n_max = n_max)
  bundle_raw(d$data, d$loading_problems)
}


clean <- function(d, helpers) {

  # TODO(phoebe): can we get reason_for_stop/search/contraband fields?
  # https://app.asana.com/0/456927885748233/672314799705085
  # TODO(phoebe): can we get subject race?
  # https://app.asana.com/0/456927885748233/672314799705086
  d$data %>%
    # NOTE: For some reason, the primary key seems to be a combination of
    # Ticket and Citation Number; when Ticket is null, Citation Number isn't
    # and vice versa; both are duplicated across rows, so we deduplicate on
    # those two IDs coalesced
    mutate(
      tmp_id = coalesce(`Citation Number`, Ticket)
    ) %>%
    merge_rows(
      tmp_id
    ) %>%
    rename(
      officer_id = `Officer ID`,
      district = District,
      # TODO(phoebe): is Post like police beat?
      # https://app.asana.com/0/456927885748233/672314799705092<Paste>
      beat = Post
    ) %>%
    mutate(
      datetime = coalesce(
        parse_datetime(`Ticket Date`, "%Y/%m/%d %H:%M:%S"),
				parse_datetime(`Ticket Date`, "%Y/%m/%d")
      ),
      date = as.Date(datetime),
      time = format(datetime, "%H:%M:%S"),
      time = if_else(time == parse_time("00:00:00"), NA, time),
      # TODO(phoebe): can we get `Ordinance Code` translations?
      # https://app.asana.com/0/456927885748233/672314799705088
      # TODO(phoebe): what are the `Enforcement Type` translations? And why are
      # they 99% null?
      # https://app.asana.com/0/456927885748233/672314799705089
      # TODO(phoebe): can we get `Citation Type` translations?
      # https://app.asana.com/0/456927885748233/672314799705095
      # TODO(phoebe): Violation is almost all null? Why is this data all
      # so bad / not present?
      # https://app.asana.com/0/456927885748233/672314799705090
      # TODO(phoebe): is "Watch" incident type -- i.e. vehicular/pedestrian?
      # https://app.asana.com/0/456927885748233/672314799705091
      type = ifelse(
        Watch == "V",
        "vehicular",
        ifelse(
          Watch == "P",
          "pedestrian",
          NA
        )
      ),
      # NOTE:  primary key is Citation Number
      citation_issued = TRUE,
      # TODO(phoebe): can we get other types of outcomes? arrests/warnings?
      # https://app.asana.com/0/456927885748233/672314799705093
      outcome = "citation"
    ) %>%
    # TODO(phoebe): can we get location?
    # https://app.asana.com/0/456927885748233/672314799705094
    # helpers$add_lat_lng(
    # ) %>%
    standardize(d$metadata)
}
