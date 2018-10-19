library(tidyverse)
library(here)
library(fs)

source("opp.R")


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
  min_tickets_per_officer_per_demographic_class = 10
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
      over < 100
    ) %>%
    drop_na(
      !!"officer_id",
      !!new_demographic_colname
    )

  eligibile_officers <-
    tbl %>%
    # TODO(danj): should this also consider geography?
    group_by_("officer_id", new_demographic_colname) %>%
    summarize(cnt = n()) %>%
    ungroup() %>%
    filter(cnt >= min_tickets_per_officer_per_demographic_class) %>%
    group_by(officer_id) %>%
    count() %>%
    # NOTE: only get officers that have given tickets to both majority/minority
    filter(
      n >= 2,
      officer_id != "UNKNWN"
    ) %>%
    pull(officer_id)

  filter(tbl, officer_id %in% eligibile_officers)
}


plot_over <- function(
  tbl,
  title = NULL,
  by_col = is_white,
  over_limit = 50
) {

  by_colq <- enquo(by_col)
	by_colname <- quo_name(by_colq)

  tbls <-
    tbl %>%
    filter(over <= over_limit) %>%
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

  tbl <-
    tbl %>%
    mutate(is_bunch = over %in% bunching_values) %>%
    group_by(officer_id) %>%
    summarize(bunch_pct = mean(is_bunch))

  ggplot(tbl, aes(x = bunch_pct, y =..count../sum(..count..))) +
    geom_histogram(bins=20, binwidth=0.05) +
    theme(text = element_text(size=10)) +
    ylab("proportion of officers") +
    xlab("proportion of stops at bunching point(s)") +
    ggtitle(title)
}


plot_lenient <- function(
  tbl,
  title = NULL,
  demographic_col = is_white,
  bunching_values = c(10),
  bunch_pct_threshold = 0.03
) {

  demographic_colq <- enquo(demographic_col)
  demographic_colname <- quo_name(demographic_colq)

  officer_leniency <-
    tbl %>%
    mutate(is_bunch = over %in% bunching_values) %>%
    group_by(officer_id) %>%
    summarize(bunch_pct = mean(is_bunch)) %>%
    ungroup() %>%
    mutate(is_lenient = bunch_pct > bunch_pct_threshold) %>%
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
