library(tidyverse)
library(here)
library(fs)

main <- function() {
  tbl <- opp_load_all_data()
  cvg <-
    tbl %>%
    filter(city != "Statewide") %>%
    mutate(
      speed_not_na = !is.na(speed),
      speed_and_posted_not_na = speed_not_na & !is.na(posted_speed),
      speed_and_officer_not_na = speed_not_na & !is.na(officer_id),
      speed_and_posted_and_officer_not_na =
        speed_and_posted_not_na & speed_and_officer_not_na
    ) %>%
    group_by(state, city) %>%
    summarize(
      speed_cvg = mean(speed_not_na),
      speed_and_posted_cvg = mean(speed_and_posted_not_na),
      speed_and_officer_cvg = mean(speed_and_officer_not_na),
      speed_and_posted_and_officer_cvg = mean(speed_and_posted_and_officer_not_na)
    ) %>%
    ungroup() %>%
    arrange(
      desc(speed_cvg),
      desc(speed_and_posted_cvg),
      desc(speed_and_officer_cvg),
      desc(speed_and_posted_and_officer_cvg)
    )
  plot_dist(prepare(opp_load_data("ok", "oklahoma city"), save="ok"))
  plot_dist(prepare(opp_load_data("tx", "dallas"), save="dallas"))
  plot_dist(prepare(opp_load_data("tx", "plano"), save="plano"))
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


# TODO(danj): plot by age/gender
plot_dist <- function(
  tbl,
  demographic_col = is_white,
  over_max = 50,
  save_name = NULL
) {

  demographic_colq <- enquo(demographic_col)

  tblg <-
    tbl %>%
    filter(over <= over_max) %>%
    group_by(!!demographic_colq, over) %>%
    count() %>%
    ungroup() %>%
    group_by(!!demographic_colq) %>%
    mutate(total = sum(n), pct = n / total) %>%
    ungroup()

  p <-
    ggplot(tblg, aes(x=over, y=pct, color=!!demographic_colq)) +
    geom_line() +
    scale_x_continuous(
      breaks = round(seq(0, max(tblg$over), by=1), 1)
    ) +

  if (!is.null(save_name)) {
    out_dir <- dir_create(here::here("plots"))
    fname <- str_c("officer_", save_name, ".png")
    out_path <- path(here::here("plots"), fname)
    ggsave(out_path, p, width = 12, height = 6, units = "in")
  }

  p
}
