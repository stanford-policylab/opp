library(tidyverse)
library(here)
library(fs)

source("opp.R")


# original paper filters:
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
  min_stops_per_officer = 100,
  min_stops_per_officer_per_demographic_class = 20,
  over_limit = 40,
  bunching_values = c(10),
  non_lenient_bunching_percent_max = 0.02
) {

  control_colsq <- enquos(...)
  demographic_colq <- enquo(demographic_col)

  control_colnames <- quos_names(control_colsq)

  tbl <- prepare(
    tbl,
    !!demographic_colq,
    demographic_majority_class,
    min_stops_per_officer,
    min_stops_per_officer_per_demographic_class,
    over_limit
  )

  # NOTE: creates a matrix like the following:
  # V1 V2 V3 ... V<max_over>
  # 1  2  3  ... <max_over>
  # 1  2  3  ... <max_over> 
  # 1  2  3  ... <max_over> 
  # ...
  over_speeds <- as_tibble(sapply(
    seq(1:max(tbl$over)),
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
  over_indicators <- as_tibble(sapply(over_speeds, function(s) s == tbl$over))
  colnames(over_indicators) <- str_c(
    rep("over_", ncol(over_indicators)),
    seq(1:ncol(over_indicators))
  )

  fmla <- as.formula(str_c(
    "cbind(", str_c(colnames(over_indicators), collapse = ", "), ")",
    " ~ is_lenient * is_", demographic_majority_class, " + ",
    str_c(control_colnames, collapse = " + ")
  ))
  print(fmla)
  print(colnames(tbl))

  data <- bind_cols(over_indicators, tbl)

  glm(fmla, "binomial", data)
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


prepare <- function(
  tbl,
  demographic_col = subject_race,
  demographic_majority_class = "white",
  min_stops_per_officer = 100,
  min_stops_per_officer_per_demographic_class = 20,
  over_limit = 40
) {

  demographic_colq <- enquo(demographic_col)
  new_demographic_colname <- str_c("is_", demographic_majority_class)

  tbl <-
    tbl %>%
    mutate(
      over = speed - posted_speed,
      !!new_demographic_colname :=
        !!demographic_colq == demographic_majority_class
    ) %>%
    filter(
      over > 0,
      over < over_limit
    ) %>%
    drop_na(
      !!"officer_id",
      !!new_demographic_colname
    )

  officers_with_min_stops <-
    tbl %>%
    group_by(officer_id) %>%
    count() %>%
    filter(n >= min_stops_per_officer) %>%
    pull(officer_id)
  
  officers_with_min_stops_per_demographic_class <-
    tbl %>%
    # TODO(danj): should this also consider geography?
    group_by_("officer_id", new_demographic_colname) %>%
    summarize(cnt = n()) %>%
    ungroup() %>%
    filter(cnt >= min_stops_per_officer_per_demographic_class) %>%
    group_by(officer_id) %>%
    count() %>%
    # NOTE: only get officers that have given tickets to both majority/minority
    filter(
      n >= 2,
      officer_id != "UNKNWN"
    ) %>%
    pull(officer_id)

  eligible_officers <- intersect(
    officers_with_min_stops,
    officers_with_min_stops_per_demographic_class
  )

  filter(tbl, officer_id %in% eligible_officers)
}


plot_over <- function(
  tbl,
  title = NULL,
  by_col = is_white
) {

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
  ggtitle(title)
}


plot_bunching <- function(
  tbl,
  title = NULL,
  bunching_values = c(10)
) {

  over_colq <- enquo(over_col)

  tbl <-
    tbl %>%
    mutate(is_bunch = over %in% bunching_values) %>%
    group_by(officer_id) %>%
    summarize(bunch_pct = mean(is_bunch))

  ggplot(tbl, aes(x = bunch_pct, y = ..count.. / sum(..count..))) +
    geom_histogram(bins = 20, binwidth = 0.05) +
    theme(text = element_text(size = 10)) +
    ylab("proportion of officers") +
    xlab("proportion of stops at bunching point(s)") +
    ggtitle(title)
}


plot_lenient <- function(
  tbl,
  title = NULL,
  demographic_col = is_white,
  bunching_values = c(10),
  non_lenient_bunching_percent_max = 0.02
) {

  demographic_colq <- enquo(demographic_col)
  demographic_colname <- quo_name(demographic_colq)

  officer_leniency <-
    tbl %>%
    mutate(is_bunch = over %in% bunching_values) %>%
    group_by(officer_id) %>%
    summarize(bunch_pct = mean(is_bunch)) %>%
    ungroup() %>%
    mutate(is_lenient = bunch_pct > non_lenient_bunching_percent_max) %>%
    select(officer_id, is_lenient)

  new_colname <- str_c("is_lenient_", demographic_colname)

  lenient <-
    tbl %>%
    left_join(officer_leniency) %>%
    mutate(
      !!new_colname := str_c(
        "is_lenient_", is_lenient, "_",
        demographic_colname, "_", !!demographic_colq
      )
    )
   
  plot_over(lenient, title, !!sym(new_colname))
}


save <- function(p, name, width = 12, height = 6, type = "png") {
  out_dir <- dir_create(here::here("plots"))
  fname = str_c(name, ".", type)
  out_path <- path(out_dir, fname)
  ggsave(out_path, p, width = 12, height = 6, units = "in")
}
