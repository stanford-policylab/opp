library(tidyverse)
library(here)
library(fs)

source("analysis_common.R")


# original paper filters:
# only speeding violations
# 100 citations
# 20 whites, 20 minorities
# 0-40 over
# remove accidents
# remove tickets not on roads...1.5%
# fewer than 2% of tickets issued at bunching point are non-lenient

bunching_test <- function(
  tbl,
  ...,
  demographic_col = subject_race,
  demographic_majority_class = "white",
  officer_id_col = officer_id,
  speed_col = speed,
  posted_speed_col = posted_speed,
  min_stops_per_officer = 100,
  min_stops_per_officer_per_demographic_class = 20,
  over_limit = 40,
  bunching_points = c(10),
  non_lenient_bunching_rate_max = 0.02
) {

  control_colqs <- enquos(...)
  demographic_colq <- enquo(demographic_col)
  officer_id_colq <- enquo(officer_id_col)
  speed_colq <- enquo(speed_col)
  posted_speed_colq <- enquo(posted_speed_col)

  demographic_indicator_colname <- str_c("is_", demographic_majority_class)

  d <- prepare(
    tbl,
    !!!control_colqs,
    demographic_col = !!demographic_colq,
    demographic_majority_class = demographic_majority_class,
    demographic_indicator_colname = demographic_indicator_colname,
    officer_id_col = !!officer_id_colq,
    min_stops_per_officer = min_stops_per_officer,
    min_stops_per_officer_per_demographic_class =
      min_stops_per_officer_per_demographic_class,
    speed_col = !!speed_colq,
    posted_speed_col = !!posted_speed_colq,
    over_limit = over_limit,
    bunching_points = bunching_points,
    non_lenient_bunching_rate_max = non_lenient_bunching_rate_max
  )

  list(
    metadata = d$metadata,
    data = d$data,
    results = list(
      difference_in_difference = calculate_difference_in_difference(d$data),
      fit = train(
        d$data,
        !!!control_colqs,
        demographic_indicator_col = !!sym(demographic_indicator_colname),
        target_cols_prefix = "target_over_"
      ),
      plots = list(
        over = plot_over(d$data, !!sym(demographic_indicator_colname)),
        bunching = plot_bunching(d$data),
        lenience = plot_lenience(d$data, !!sym(demographic_indicator_colname)),
        coefficient = plot_coefficient(fit),
        difference = plot_difference_in_difference(
          d$data,
          !!sym(demographic_indicator_col),
          over,
          is_bunching,
          is_lenient
        )
      )
    )
  )
}


prepare <- function(
  tbl,
  ...,
  demographic_col = subject_race,
  demographic_majority_class = "white",
  demographic_indicator_colname = str_c("is_", demographic_majority_class),
  officer_id_col = officer_id,
  min_stops_per_officer = 100,
  min_stops_per_officer_per_demographic_class = 20,
  speed_col = speed,
  posted_speed_col = posted_speed,
  over_limit = 40,
  bunching_points = c(10),
  non_lenient_bunching_rate_max = 0.02
) {

  control_colqs <- enquos(...)
  demographic_colq <- enquo(demographic_col)
  officer_id_colq <- enquo(officer_id_col)
  speed_colq <- enquo(speed_col)
  posted_speed_colq <- enquo(posted_speed_col)

  d <- list(data = tbl, metadata = list())

  d <- select_and_filter_missing(
    d,
    !!!control_colqs,
    !!demographic_colq,
    !!officer_id_colq,
    !!speed_colq,
    !!posted_speed_colq
  )

  d$data <- add_demographic_indicator(
    d$data,
    !!demographic_colq,
    demographic_majority_class,
    demographic_indicator_colname
  )

  d <- filter_to_eligible_officers(
    d, 
    !!sym(demographic_indicator_colname),
    !!officer_id_colq,
    min_stops_per_officer,
    min_stops_per_officer_per_demographic_class
  )

  # NOTE: if an officer was at the border of being eligible, i.e. had exactly
  # <min_stops_per_officer_per_demographic_class>, after filtering out some
  # stops, the officer may have fewer than that, i.e. let's imagine an officer
  # has 20 minority stops before filtering stops, but 5 of those stops were for
  # speeds greater than <over_limit>, i.e. if <over_limit> is 40 MPH over,
  # these stops could be for 50, 60, 70, 80 over speed limit and would be
  # filtered out, so in the final dataset, this officer has only 15 minority
  # stops in the target range. The alternative is to filter the speeds and then
  # select the officers, but this may eliminate officers who ticket more at
  # extreme speeds; ultimately, it depends on whether you want to sample from
  # officers who have sufficient tickets from 0-<over_limit>, or keep all
  # officers who fit the criteria, and then sample from their tickets that fall
  # in the specified over-range. The latter is used here to keep as many
  # officers in the pool as possible. This can be readily reversed by switching
  # the order of the preceding and subsequent clauses.
  d <- add_and_filter_over(
    d,
    !!speed_colq,
    !!posted_speed_colq,
    over_limit
  )

  d$data <- add_is_bunching(
    d$data,
    bunching_points
  )

  d$data <- add_is_lenient(
    d$data,
    !!officer_id_colq,
    non_lenient_bunching_rate_max
  )

  d$data <- add_over_indicator_targets(
    d$data,
    over
  )

  d
}


add_demographic_indicator <- function(
  tbl,
  demographic_col = subject_race,
  demographic_majority_class = "white",
  demographic_indicator_colname = str_c("is_", demographic_majority_class)
) {

  demographic_colq <- enquo(demographic_col)

  tbl %>%
  mutate(
    !!demographic_indicator_colname :=
      !!demographic_colq == demographic_majority_class
  )
}


filter_to_eligible_officers <- function(
  d, 
  demographic_indicator_col = is_white,
  officer_id_col = officer_id,
  min_stops_per_officer = 100,
  min_stops_per_officer_per_demographic_class = 20
) {

  demographic_indicator_colq <- enquo(demographic_indicator_col)
  officer_id_colq <- enquo(officer_id_col)

  tbl <- d$data
  metadata <- d$metadata

  officers_with_min_stops <-
    tbl %>%
    group_by(!!officer_id_colq) %>%
    count() %>%
    filter(n >= min_stops_per_officer) %>%
    pull(!!officer_id_colq)
  
  officers_with_min_stops_per_demographic_class <-
    tbl %>%
    group_by(!!officer_id_colq, !!demographic_indicator_colq) %>%
    summarize(cnt = n()) %>%
    ungroup() %>%
    filter(cnt >= min_stops_per_officer_per_demographic_class) %>%
    group_by(!!officer_id_colq) %>%
    count() %>%
    # NOTE: only get officers that have given tickets to both majority/minority
    filter(
      n >= 2,
      !!officer_id_colq != "UNKNWN|UNKNOWN|NA"
    ) %>%
    pull(!!officer_id_colq)

  eligible_officers <- intersect(
    officers_with_min_stops,
    officers_with_min_stops_per_demographic_class
  )

  n_officers_before <- select(tbl, !!officer_id_colq) %>% n_distinct
  n_stops_before <- nrow(tbl)
  tbl <- filter(tbl, officer_id %in% eligible_officers)
  n_officers_after <- select(tbl, !!officer_id_colq) %>% n_distinct
  n_stops_after <- nrow(tbl)

  proportion_officers_removed <-
    (n_officers_before / n_officers_after) / n_officers_before
  metadata["n_officers_removed"] <- n_officers_before - n_officers_after
  metadata["proportion_officers_removed"] <- proportion_officers_removed
  if (proportion_officers_removed > 0) {
    pct_warning(
      proportion_officers_removed,
      "of officers removed due to not meeting eligibility requirements"
    )
  }

  proportion_stops_removed <- 
    (n_stops_before - n_stops_after) / n_stops_before
  metadata["proportion_stops_removed"] <- proportion_stops_removed
  if (proportion_stops_removed > 0) {
    pct_warning(
      proportion_stops_removed,
      "of stops removed since they were conducted by ineligible officers"
    )
  }

  list(data = tbl, metadata = metadata)
}


add_and_filter_over <- function(
  d,
  speed_col = speed,
  posted_speed_col = posted_speed,
  over_limit = 40
) {

  speed_colq <- enquo(speed_col)
  posted_speed_colq <- enquo(posted_speed_col)

  tbl <- d$data
  metadata <- d$metadata

  n_stops_before <- nrow(tbl)

  tbl <-
    tbl %>%
    mutate(
      over = !!speed_colq - !!posted_speed_colq
    ) %>%
    filter(
      over > 0,
      over <= over_limit
    )

  n_stops_after <- nrow(tbl)
  n_over_limit_stops_removed <- n_stops_before - n_stops_after
  proportion_over_limit_stops_removed <-
    n_over_limit_stops_removed / n_stops_before
  metadata["n_over_limit_stops_removed"] <- n_over_limit_stops_removed
  metadata["proportion_over_limit_stops_removed"] <-
    proportion_over_limit_stops_removed
  if (proportion_over_limit_stops_removed > 0) {
    pct_warning(
      proportion_over_limit_stops_removed,
      str_c(
        "of stops removed due to being less than 1 MPH over or more than ",
        over_limit,
        " MPH over the speed limit"
      )
    )
  }

  list(data = tbl, metadata = metadata)
}


add_is_bunching <- function(
  tbl,
  bunching_points = c(10)
) {
  mutate(tbl, is_bunching = over %in% bunching_points)
}


add_is_lenient <- function(
  tbl,
  officer_id_col = officer_id,
  non_lenient_bunching_rate_max = 0.02
) {

  officer_id_colq <- enquo(officer_id_col)

  officer_leniency <-
    tbl %>%
    group_by(!!officer_id_colq) %>%
    summarize(bunching_rate = mean(is_bunching)) %>%
    ungroup() %>%
    mutate(is_lenient = bunching_rate > non_lenient_bunching_rate_max) %>%
    select(!!officer_id_colq, is_lenient)

  left_join(tbl, officer_leniency)
}


add_over_indicator_targets <- function(
  tbl,
  over_col = over
) {

  over_colq <- enquo(over_col)

  # NOTE: creates a matrix like the following:
  # V1 V2 V3 ... V<max_over>
  # 1  2  3  ... <max_over>
  # 1  2  3  ... <max_over> 
  # 1  2  3  ... <max_over> 
  # ...
  over_speeds <- as_tibble(sapply(
    seq(1:max(pull(tbl, !!over_colq))),
    rep,
    nrow(tbl)
  ))

  # NOTE: creates a matrix like the following:
  # V1 V2 V3 ... V<max_over>
  # T  F  F  ... <max_over>
  # F  T  F  ... <max_over> 
  # F  T  F  ... <max_over> 
  # ...
  # i.e. each column is a target variable indicating whether
  # the current record is speed <S> over
  over_indicators <- as_tibble(sapply(
    over_speeds,
    function(s) s == pull(tbl, !!over_colq)
  ))
  colnames(over_indicators) <- str_c(
    rep("target_over_", ncol(over_indicators)),
    seq(1:ncol(over_indicators))
  )

  bind_cols(tbl, over_indicators)
}


train <- function(
  tbl,
  ...,
  demographic_indicator_col = is_white,
  target_cols_prefix = "target_over_"
) {

  control_colqs <- enquos(...)
  demographic_indicator_colq <- enquo(demographic_indicator_col)

  control_colnames <- quos_names(control_colqs)
  demographic_indicator_colname <- quo_name(demographic_indicator_colq)

  targets <- colnames(tbl)[str_detect(colnames(tbl), target_cols_prefix)]


  fmla <- as.formula(str_c(
    "cbind(",
    str_c(targets, collapse = ", "),
    ")",
    " ~ is_lenient * ",
    demographic_indicator_colname,
    " + ",
    str_c(control_colnames, collapse = " + ")
  ))

  lm(fmla, tbl)
}


plot_difference_in_difference <- function(
  tbl,
  demographic_indicator_col = is_white,
  over_col = over,
  bunching_col = is_bunching,
  lenience_col = is_lenient
) {

  demographic_indicator_colq <- enquo(demographic_indicator_col)
  over_colq <- enquo(over_col)
  bunching_colq <- enquo(bunching_col)
  lenience_colq <- enquo(lenience_col)

  tbld <-
    tbl %>%
    group_by(!!demographic_indicator_colq, !!lenience_colq) %>%
    mutate(subtotal = n()) %>%
    group_by(!!demographic_indicator_colq, !!lenience_colq, !!over_colq) %>%
    mutate(proportion = n() / subtotal) %>%
    select(
      !!demographic_indicator_colq,
      !!over_colq,
      !!lenience_colq,
      proportion
    ) %>%
    distinct() %>%
    arrange()

  ff <- as.formula(str_c(". ~ ", quo_name(demographic_indicator_colq)))
  ggplot(tbld, aes(x = !!over_colq, y = proportion, color = !!lenience_colq)) +
    geom_line() +
    theme(text = element_text(size=10)) +
    facet_grid(ff) +
    ylab("proportion") +
    xlab("MPH over speed limit") +
    ggtitle("Proportion of Stops by MPH Over, Lenience, and Demographic")
}


plot_over <- function(tbl, by_col = is_white) {

  by_colq <- enquo(by_col)
	by_colname <- quo_name(by_colq)

  tbls <-
    tbl %>%
    group_by(!!by_colq, over) %>%
    count() %>%
    ungroup() %>%
    group_by(!!by_colq) %>%
    mutate(total = sum(n), pct = n / total) %>%
		ungroup()

	labels <-
		tbls %>%
		select(!!by_colq, total) %>%
		distinct() %>%
		unite(label, sep = "  N=") %>%
		pull(label)

  ggplot(tbls, aes(x=over, y=pct, color=!!by_colq)) +
    geom_line() +
    scale_x_continuous(breaks = round(seq(0, max(tbls$over), by=5), 1)) +
    scale_colour_discrete(labels = labels) +
    theme(text = element_text(size=10)) +
    ylab("proportion") +
    xlab("MPH over speed limit") +
    ggtitle("Proportion of Stops by MPH Over")
}


plot_bunching <- function(tbl) {
  tbl <-
    tbl %>%
    group_by(officer_id) %>%
    summarize(bunching_rate = mean(is_bunching))

  ggplot(tbl, aes(x = bunching_rate, y = ..count.. / sum(..count..))) +
    geom_histogram(bins = 20, binwidth = 0.05) +
    theme(text = element_text(size = 10)) +
    ylab("proportion of officers") +
    xlab("proportion of stops at bunching point(s)") +
    ggtitle("Bunching")
}


plot_lenience <- function(tbl, by_col = is_white) {

  by_colq <- enquo(by_col)
  by_colname <- quo_name(by_colq)

  plot_colname <- str_c("is_lenient_", by_colname)

  tbl <- 
    tbl %>%
    mutate(
      !!plot_colname := str_c(
        "is_lenient_",
        is_lenient,
        "_",
        by_colname,
        "_",
        !!by_colq
      )
    )
   
  plot_over(tbl, !!sym(plot_colname))
}


plot_coefficient <- function(fit) {
  # NOTE: this represents the interaction of is_lenient with whatever
  # demographic it is interacted with
  s <- summary(fit)
  coefficient_pattern <- "is_lenient.*:.*"
  coefficient_names <- dimnames(s[[1]]$coefficients)[[1]]
  idx <- which(str_detect(coefficient_names, coefficient_pattern))
  mtx <- t(sapply(s, function(m) { t(m$coefficients[idx, 1:2]) }))
  tbl <- as_tibble(mtx)
  tbl$over <- parse_number(rownames(mtx))
  colnames(tbl) <- c("estimate", "std_error", "over")
  tbl <-
    tbl %>%
    mutate(lower = estimate - 2 * std_error, upper = estimate + 2 * std_error)

  title <- str_c("Coefficient of ", coefficient_names[idx], " (95% CI)")
  ggplot(tbl, aes(x=over, y=estimate)) +
    geom_point() +
    geom_line() +
    xlab("MPH over") +
    ylab("estimate") +
    geom_errorbar(aes(ymin=lower, ymax=upper)) +
    ggtitle(title)
}


coverage <- function(tbl) {
  tbl %>%
  mutate(
    speed = !is.na(speed),
    posted_speed = !is.na(posted_speed),
    officer_id = !is.na(officer_id),
    race = !is.na(subject_race),
    sex = !is.na(subject_sex),
    age = !is.na(subject_age),
    requirements = speed & posted_speed & officer_id,
    race_requirements = race & requirements,
    sex_requirements = sex & requirements,
    age_requirements = age & requirements
  ) %>%
  group_by(
    state,
    city
  ) %>%
  summarize(
    race_coverage = mean(race_requirements),
    sex_coverage = mean(sex_requirements),
    age_coverage = mean(age_requirements)
  ) %>%
  arrange(
    desc(race_coverage),
    desc(sex_coverage),
    desc(age_coverage)
  ) %>%
  ungroup()
}


save <- function(p, name, width = 12, height = 6, type = "png") {
  out_dir <- dir_create(here::here("plots"))
  fname = str_c(name, ".", type)
  out_path <- path(out_dir, fname)
  ggsave(out_path, p, width = 12, height = 6, units = "in")
}
