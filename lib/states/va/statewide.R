source("common.R")

load_raw <- function(raw_data_dir, n_max) {

  d <- load_single_file(raw_data_dir, "data.csv", n_max = n_max)

  # NOTE: Jurisdictions data file comes from a Word doc that we converted to
  # a CSV by hand. It's used for getting place names from jurisdiction codes.
  d_juris <- load_single_file(raw_data_dir, "jurisdictions.csv")

  # NOTE: Columns in raw data are codes. The documentation in the raw data
  # directory defines the codes, which these column names are derived from.
  colnames(d$data) <- c(
    'week',
    'jurisdiction_code',
    'officer_id',
    'number_of_traffic_arrests_white',
    'number_of_aerial_enforcement_arrests_white',
    'number_of_search_arrests_white',
    'number_of_search_stops_white',
    'number_of_traffic_arrests_africa/american',
    'number_of_aerial_enforcement_arrests_africa/american',
    'number_of_search_arrests_africa/american',
    'number_of_search_stops_africa/american',
    'number_of_traffic_arrests_hispanic',
    'number_of_aerial_enforcement_arrests_hispanic',
    'number_of_search_arrests_hispanic',
    'number_of_search_stops_hispanic',
    'number_of_traffic_arrests_asian',
    'number_of_aerial_enforcement_arrests_asian',
    'number_of_search_arrests_asian',
    'number_of_search_stops_asian',
    'number_of_traffic_arrests_indian',
    'number_of_aerial_enforcement_arrests_indian',
    'number_of_search_arrests_indian',
    'number_of_search_stops_indian',
    'number_of_traffic_arrests_other',
    'number_of_aerial_enforcement_arrests_other',
    'number_of_search_arrests_other',
    'number_of_search_stops_other',
    'number_of_traffic_arrests_unknown',
    'number_of_aerial_enforcement_arrests_unknown',
    'number_of_search_arrests_unknown',
    'number_of_search_stops_unknown',
    'officer_last_name',
    'officer_first_name',
    'trooper_race'
  )

  # NOTE: The source data aggregates data by week. In the following pipeline we
  # will reshape the source data to move some columns to rows, and then
  # disaggregate the weekly sums so we have one row per stop.
  d_agg <- d$data %>%
    # NOTE: There are ~4k duplicate rows in the data. Some are completely
    # identical rows, but a few identical in every way except for the
    # number of stops (which indicates one of the entries is wrong).
    group_by(
      week,
      jurisdiction_code,
      officer_id,
      officer_last_name,
      officer_first_name,
      trooper_race
    ) %>%
    # NOTE: De-duplicate by taking the last row in a group.
    slice(
      n()
    ) %>%
    ungroup(
    ) %>%
    # NOTE: Race data for each event type are given in separate columns, e.g.
    # number_of_search_stops_hispanic. We want to treat race as a variable;
    # i.e., we want to move race to its own column. To do this we will first
    # convert the wide table columns to long as rows, then extract the race
    # component, and finally move the event type back to columns.
    gather(
      key = "event_type",
      value = "count",
      starts_with("number_of")
    ) %>%
    right_separate_cols(
      event_type = c("stat", "race"),
      sep = "_"
    ) %>%
    spread(
      stat,
      count
    ) %>%
    # NOTE: Sum together granular event types to get number of searches and
    # total number of stops in a week. Note also that the granular events
    # in the data are mutually exclusive, i.e. number_of_search_arrests can be
    # non-zero while number_of_search_stops is zero.
    mutate(
      stops = as.integer(number_of_traffic_arrests)
        + as.integer(number_of_search_arrests)
        + as.integer(number_of_search_stops),
      searches = as.integer(number_of_search_arrests)
        + as.integer(number_of_search_stops)
    ) %>%
    left_join(d_juris$data)

  # NOTE: De-aggregate the data, so that one row represents one stop. Create
  # one row for each search conducted in a week, and another row for each stop
  # conducted without a search.
  n = nrow(d_agg)
  rbind(
    # For each row index, repeat that row the number of times given by the
    # stop/search fields. Use `coalesce` to guard against NA values, which
    # `rep` does not handle. Is there a more readable way to do this?
    mutate(
      d_agg[rep(1:n, coalesce(d_agg$searches, 0L)),],
      search_conducted = TRUE
    ),
    mutate(
      d_agg[rep(1:n, coalesce(d_agg$stops - d_agg$searches, 0L)),],
      search_conducted = FALSE
    )
  ) %>%
  bundle_raw(c(d$loading_problems, d_juris$loading_problems))
}


clean <- function(d, helpers) {

  # Dictionaries
  tr_race = c(
    # Trooper race column keys
    "A" = "white",
    "B" = "black",
    "b" = "black",
    "C" = "hispanic",
    "D" = "asian/pacific islander",
    "E" = "other/unknown",
    "U" = "other/unknown",
    # Subject race column keys
    "white" = "white",
    "africa/american" = "black",
    "hispanic" = "hispanic",
    "asian" = "asian/pacific islander",
    "indian" = "other/unknown",
    "other" = "other/unknown",
    "unknown" = "other/unknown"
  )

  # TODO(phoebe): can we get unaggregated data, along with more details about
  # the stop (reason_for_stop/search/contraband fields)?
  # https://app.asana.com/0/456927885748233/740254831051062
  d$data %>%
    mutate(
      # NOTE: Date is the Saturday ending a given week of data, per the
      # documentation included in the raw data directory.
      date = parse_date(week, "%Y%m%d"),
      location = str_c_na(jurisdiction_name, jurisdiction_type, sep = " "),
      county_name = if_else(jurisdiction_type == "COUNTY", jurisdiction_name, NA_character_),
      officer_race = tr_race[trooper_race],
      subject_race = tr_race[race],
      # NOTE: Source files are all traffic stops.
      type = "vehicular"
    ) %>%
    standardize(d$metadata)
}
