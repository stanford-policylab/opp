#!/usr/bin/env Rscript
source("opp.R")


marijuana_legalization <- function() {
  results <- policy_change_test(
    test_tbl = tribble(
      ~state, ~city, ~change_date, ~violation_regex,
      "CO", "Statewide", "2012-12-10", "marijuana",
      # TODO(danj): WA also has Drugs Paraphernalia - Misdemeanor
      "WA", "Statewide", "2012-12-09", "drugs - misdemeanor"
    ),
    # TODO(danj): ensure all of these have correctly classified search bases
    control_tbl = tribble(
      ~state, ~city,
      "AZ", "Statewide",
      "CA", "Statewide",
      "FL", "Statewide",
      "MA", "Statewide",
      "MT", "Statewide",
      "NC", "Statewide",
      "OH", "Statewide",
      "RI", "Statewide",
      "SC", "Statewide",
      "TX", "Statewide",
      "VT", "Statewide",
      "WI", "Statewide"
    ),
    eligible_search_bases = c("k9", "plain view", "probable cause")
  )
}

# test_tbl: <state, city, change_date, violation_regex>
# control_tbl: <state, city>
# eligible_searches: c("<type_1>", "<type_2>", ...) [see standards.R]
policy_change_test <- function(
  test_tbl,
  control_tbl,
  eligible_searches
) {

  tbl <-
    bind_rows(select(test_tbl, state, city), control_tbl) %>%
    opp_load_all_data() %>%
    add_violation_indicator(test_tbl) %>%
    mutate(search_is_eligible = search_basis %in% eligible_search_bases) %>%
    group_by(state, city, date, subject_race) %>%
    summarize(
      n = n(),
      n_target_violation = sum(violation_indicator),
      n_violation = sum(!is.na(violation)),
      n_eligible_searches = sum(search_is_eligible),
      n_searches = sum(search_conducted, na.rm = T)
    ) %>%
    ungroup()

  # TODO(danj): compute trendlines
}


add_violation_indicator <- function(tbl, test_tbl) {
  tbl <- mutate(tbl, violation_indicator = F)
  for (i in 1:nrow(test_tbl)) {
    tbl <- mutate(tbl, violation_indicator = if_else(
      state == test_tbl[i, "state"]
      & city == test_tbl[i, "city"]
      & str_detect(str_c_to_lower(violation), test_tbl[i, "violation_regex"]),
      T,
      violation_indicator
    ))
  }
}


if (!interactive()) {
  marijuana_legalization_analysis()
}

# This script produces time series plots 5a, 5b, 5c in the paper,
# representing the effect of marijuana legalization in Colorado and Washington.
# We have separate functions to aggregate all the marijuana data + do the analysis 
# since aggregating the data takes a while but analysis is very fast on aggregate data. 

# small helper method to get legalization date for a state. 
# the two legalization dates for CO + WA are essentially the same (2012-12-10 vs 2012-12-09). 
# for control states, which of course have no legalization date, we return Washington's by default. 
# use dplyr's if_else so date doesn't get cast to numeric. 
get_legalization_date_for_state = function(state){
  return(dplyr::if_else(state == 'CO', COLORADO_LEGALIZATION_DATE, WASHINGTON_LEGALIZATION_DATE))
}

# function to annotate with excluded search types. 
# search types to exclude because they have nothing to do with drug searches, so would not expect to change. 
marijuana_excluded_search_types = c('Incident to Arrest', 'Inventory', 'Protective Frisk', 
                          'Stop and Frisk', 'Warrant', 'Other',  'Impound',
                          'Reasonable Suspicion', 'Consent Search - Reasonable Suspicion',# we exclude reasonable suspicion searches because can only be conducted for officer safety
                          'Exigent Circumstances', 'Parole/Probation', 
                          'Pat Down/Frisk', 'Vehicle Inventory', 'Search Warrant')
marijuana_excluded_search_types = tolower(marijuana_excluded_search_types)  # avoid capitalization issues.

# small helper function to exclude a search if any of the excluded search types are in the search. 
# if search type is NA, we do not exclude. 
search_is_excluded_from_marijuana_analysis = function(x, marijuana_excluded_search_types){return(grepl(paste0(marijuana_excluded_search_types, collapse = '|'), tolower(x)))}


# Helper function to group the data by quarter so we can plot time series. 
aggregate_marijuana_data <- function(df){
  message(sprintf("Generating aggregate marijuana data (grouped by date and race) for %s", df$state[1]))
  
  df = df %>% 
    mutate(search_eligible = !search_is_excluded_from_marijuana_analysis(search_type, marijuana_excluded_search_types), 
           eligible_search_conducted = search_eligible & search_conducted)
  
  # print these out to make sure the proper search types are excluded / included. 
  
  all_search_types_included = df %>% filter(search_eligible, search_conducted) %>% 
    group_by(search_type) %>% 
    summarise(included_search_type = n()) %>% 
    arrange(-included_search_type) %>% 
    head(50) %>% 
    as.data.frame()
  all_search_types_excluded = df %>% 
    filter(!search_eligible, search_conducted) %>% 
    group_by(search_type) %>% 
    summarise(excluded_search_type = n()) %>% 
    arrange(-excluded_search_type) %>% 
    head(50) %>% 
    as.data.frame()
  message("Search types included")
  print(all_search_types_included)
  message("Search types excluded")
  print(all_search_types_excluded) 
  
  # if marijuana is not in the column names (ie, a control state) set to false. 
  # we have already defined marijuana column for Colorado and Washington. 
  if(!('marijuana' %in% colnames(df))){df$marijuana = FALSE}
  df = df %>%
    group_by(state, driver_race, stop_date) %>%
    summarize(n_stops = n(),
              n_marijuana_stops = sum(marijuana, na.rm=T),
              n_stops_with_violation_data = sum(!is.na(violation_raw)),
              # exclude stops for which we lack violation data in computing the marijuana violation rate. 
              # (because we don't know what happened in that stop)
              # this is most consistent with how we compute other rates in the paper (and does not significantly affect results).
              n_eligible_searches = sum(eligible_search_conducted, na.rm=T),
              n_stops_with_search_data = sum(!is.na(search_conducted))
              # similarly, exclude stops for which we lack data on whether a search occurred in computing the search rate
              # this is most consistent with how we compute the search rate in other places in the paper (although, again, a small fraction of stops). 
    ) %>% 
    ungroup()
  return(df)
}

# first save the necessary aggregate data for convenience and reproducibility. 
save_aggregate_marijuana_data = function(aggregate_marijuana_data_filename){
  # Aggregate and combine the data. First loop over control states. 
  control_states_timeseries = NULL
  for(state in MARIJUANA_CONTROL_STATES){
    d = read_state(state)
    control_states_timeseries = rbind(control_states_timeseries, aggregate_marijuana_data(d))
  }
  
  # Now do the marijuana states. We have to compute an extra field here -- whether there was a drug offense. 
  d.co <- read_state('CO') %>%
    mutate(marijuana = grepl('Possession of 1 oz or Less of Marijuana', violation_raw))
  
  d.wa <- read_state('WA') %>%
    mutate(marijuana = grepl('Drugs - Misdemeanor', violation_raw))
  
  marijuana_legalization_states_timeseries  <- rbind(aggregate_marijuana_data(d.co), aggregate_marijuana_data(d.wa))
  
  save(marijuana_legalization_states_timeseries, control_states_timeseries, file = aggregate_marijuana_data_filename)
}

# Fit trendlines to pre and post legalization data (these are dotted lines in the figures)
compute_marijuana_trendlines = function(d, leg_date){
  d$pre = d$stop_date < as.Date(leg_date)
  # Fit pre and post legalization trendlines.  
  # we regress on stop date; this works because R treats stop date as a numeric and fits a single linear trendline. 
  # returns both the fitted models and the grouped data. 
  
  pre_model  = glm(cbind(n_eligible_searches, n_stops_with_search_data - n_eligible_searches) ~ stop_date + driver_race, data = filter(d, pre), family = binomial)
  post_model = glm(cbind(n_eligible_searches, n_stops_with_search_data - n_eligible_searches) ~ stop_date + driver_race, data = filter(d, !pre), family = binomial)
  
  trendlines_for_state = d %>% 
    group_by(driver_race, pre) %>%
    summarise(min_date = min(stop_date),
              max_date = max(stop_date)) %>%
    ungroup() %>% # use logistic model to predict pre and post search rates. 
    mutate(search_rate_beginning = ifelse(pre, predict(pre_model, 
                                                       data.frame(stop_date = min_date, driver_race = driver_race), 
                                                       type = 'response'),
                                          predict(post_model, 
                                                  data.frame(stop_date = min_date, driver_race = driver_race), 
                                                  type = 'response')),
           search_rate_end = ifelse(pre, predict(pre_model, 
                                                 data.frame(stop_date = max_date, driver_race = driver_race), 
                                                 type = 'response'),
                                    predict(post_model, 
                                            data.frame(stop_date = max_date, driver_race = driver_race), 
                                            type = 'response')))
  
  return(trendlines_for_state)
}


# general function for making the rate over time plots. 
plot_rate_over_time = function(df, pos_count_col, tot_count_col, yaxis_label){
  # timeseries is the dataframe of rates over time. 
  # pos_count_col is the column name which gives the count of positives -- the numerator on the rate
  # tot_count_col is the column name which gives the total count -- the denominator on the rate
  # eg, for search rate, pos_count_col = "n_eligible_searches", and tot_count_col = "n_stops_with_search_data"
  # yaxis_label is the yaxis label. 
  
  states = unique(df$state)
  leg_date = data.frame(state = states) %>% 
    mutate(ds = get_legalization_date_for_state(state))
  
  # fit trendlines for each state if we're looking at search rate. (We do not show trendlines for marijuana violation rate because it's too obvious)
  if(pos_count_col == 'n_eligible_searches'){
    all_trendlines = NULL
    for(state_name in states){
      state_trendline = compute_marijuana_trendlines(df %>% filter(state == state_name), leg_date = get_legalization_date_for_state(state_name))
      all_trendlines = rbind(all_trendlines, state_trendline %>% mutate(state = state_name))
    }
    all_trendlines$race_and_legalization = paste(all_trendlines$driver_race, all_trendlines$pre)
  }
  
  # Now group time series into quarter (because plotting day by day is very noisy). Map each date to the middle of the quarter. 
  get_mid_quarter_date = function(stop_date){ # small helper method to get middle of quarter. 
    stop_quarter = quarter(stop_date)
    quarters_to_dates = c('02-15', '05-15', '08-15', '11-15')
    return(quarters_to_dates[stop_quarter])
  }
  timeseries = as.data.frame(df) %>% 
    mutate(yq = as.Date(paste(year(stop_date), get_mid_quarter_date(stop_date), sep = '-')))
  timeseries$pos_count = timeseries[,pos_count_col]
  timeseries$tot_count = timeseries[,tot_count_col]
  timeseries = timeseries %>% 
    group_by(state, driver_race, yq) %>%
    summarise(pos_count = sum(pos_count), 
              tot_count = sum(tot_count), 
              rate_col = pos_count / tot_count)
  
  # remove quarter right around legalization because it's misleading (containing both pre and post data)
  timeseries = filter(timeseries, yq != as.Date('2012-11-15')) 
  timeseries$pre = timeseries$yq < as.Date('2012-11-15')
  
  # we create a new column race_and_legalization to allow us to draw two groups of lines for pre and post legalization. 
  timeseries$race_and_legalization = paste(timeseries$driver_race, timeseries$pre)
  
  # adjust legend for control states. 
  if('CO' %in% states){
    legend_position = c(0.88, 0.88)
  }else{
    legend_position = c(0.96, 0.95)
  }
  
  # make line plot. 
  p <- ggplot(timeseries) +
    geom_line(aes(x=yq, y=rate_col, color=driver_race, group = race_and_legalization)) +
    scale_colour_manual(values=c("blue", "black", "red"), labels=c("White","Black","Hispanic")) +
    scale_y_continuous(yaxis_label, labels=scales::percent, expand=c(0,0)) +
    expand_limits(y = -.0001) +
    facet_wrap(~state, scales='free_y') +
    geom_vline(data=leg_date, aes(xintercept=as.numeric(ds)), linetype='longdash') +
    our_theme() +
    theme(legend.position=legend_position,
          axis.title.x=element_blank(),
          panel.margin=unit(0.5, "lines"), 
          plot.margin=unit(c(.1, .2, .1, .1), units = 'in'))
  if(pos_count_col == 'n_eligible_searches'){ # add trendlines for searches. 
    p = p + geom_segment(data=all_trendlines, aes(x=min_date, y=search_rate_beginning, xend=max_date, yend=search_rate_end, color=driver_race), 
                         linetype='dashed', size=0.8)
  }
  
  print(p)
  p
}

# actually make plots 5a, b, c. 
make_marijuana_plots = function(aggregate_marijuana_data_filename){
  message("\nMaking marijuana figure.")
  load(aggregate_marijuana_data_filename)

  # Make the misdemeanor rate plot for Colorado and Washington
  fn = 'fig5a_marijuana_stops'
  p = plot_rate_over_time(marijuana_legalization_states_timeseries, 
                          pos_count = 'n_marijuana_stops', 
                          tot_count = 'n_stops_with_violation_data',
                          'Misdemeanor rate')
  ggsave(paste0(figures_folder, fn, '.pdf'), p, height=4, width=9, dpi=500)
  
  # Make the search rate plot for Colorado and Washington
  fn = 'fig5b_marijuana_search_rate'
  p = plot_rate_over_time(marijuana_legalization_states_timeseries,
                          pos_count = 'n_eligible_searches',
                          tot_count = 'n_stops_with_search_data',
                          'Search rate')
  ggsave(paste0(figures_folder, fn, '.pdf'), p, height=4, width=9, dpi=500)
  
  # Make the search rate plot for control states
  fn = 'fig6_control_states_search_rate'
  p = plot_rate_over_time(control_states_timeseries, 
                          pos_count = 'n_eligible_searches',
                          tot_count = 'n_stops_with_search_data',
                          'Search rate')
  ggsave(paste0(figures_folder, fn, '.pdf'), p, height=8, width=15, dpi=500)
}

# Function which performs the diff-in-diff regression.  
diff_in_diff_analysis = function(aggregate_marijuana_data_filename, output_fn){
  load(aggregate_marijuana_data_filename)
  # combine marijuana & control states and set treatment flag. 
  # treatment = 1 if and only if we're in a legalization state and the date is after legalization. 
  control_states_timeseries$treatment = 0
  marijuana_legalization_states_timeseries = marijuana_legalization_states_timeseries %>% 
    mutate(treatment = stop_date > get_legalization_date_for_state(state)) 
  d = rbind(control_states_timeseries, marijuana_legalization_states_timeseries)
  # rescale stop date so it's in years. 
  d$stop_date_in_years = as.numeric(as.Date(d$stop_date) - as.Date('2011-01-01')) / 365
  message(sprintf("Fitting diff in diff model for pre / post"))
  model = glm(cbind(n_eligible_searches, n_stops_with_search_data - n_eligible_searches) ~ state + stop_date_in_years + driver_race + treatment:driver_race, 
              data = d, 
              family = binomial)
  print(summary(model))
  coefs = summary(model)$coefficients[,c('Estimate', 'Std. Error')]
  coefs = coefs[!grepl('state', rownames(coefs)),] %>% as.data.frame()
  coefs$effect = sprintf('%2.2f (%2.2f)', coefs$`Estimate`, coefs$`Std. Error`)
  coefs = coefs %>% select(effect)
  print(xtable(coefs), file = output_fn)
}


