source("common.R")

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
    rename(
      officer_id = `Officer ID`,
      district = District,
      # TODO(phoebe): is Post like policy beat?
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
      citation_issued = !is.na(Ticket),
      # TODO(phoebe): can we get other types of outcomes? arrests/warnings?
      # https://app.asana.com/0/456927885748233/672314799705093
      outcome = first_of(
        "citation" = citation_issued
      )
    ) %>%
    # TODO(phoebe): can we get location?
    # https://app.asana.com/0/456927885748233/672314799705094
    # helpers$add_lat_lng(
    # ) %>%
    standardize(d$metadata)
}
