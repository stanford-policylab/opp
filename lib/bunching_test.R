library(tidyverse)

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
  plot_dist("ok", "oklahoma city")
  plot_dist("tx", "dallas")
  plot_dist("tx", "plano")
}


# TODO(danj): plot by age/gender
plot_dist <- function(state, city) {
  min_tickets_per_officer_per_race <- 10
  tbl <-
    opp_load_data(state, city) %>%
    mutate(
      over = speed - posted_speed,
      is_white = subject_race == "white"
    ) %>%
    filter(
      !is.na(over),
      over > 0,
      over < 100,
      !is.na(is_white),
      !is.na(officer_id)
    )
  eligibile_officers <-
    tbl %>%
    group_by(officer_id, is_white) %>%
    summarize(cnt = n()) %>%
    ungroup() %>%
    filter(cnt > min_tickets_per_officer_per_race) %>%
    group_by(officer_id) %>%
    count() %>%
    # NOTE: only get officers that have given tickets to both majority/minority
    filter(
      n >= 2,
      officer_id != "UNKNWN"
    ) %>%
    pull(officer_id)
  tbl <- filter(tbl, officer_id %in% eligibile_officers)
  tblg <-
    tbl %>%
    group_by(is_white, over) %>%
    count() %>%
    ungroup() %>%
    group_by(is_white) %>%
    mutate(total = sum(n), pct = n / total) %>%
    filter(over < 50)
  p <-
    ggplot(tblg, aes(x=over, y=pct, color=is_white)) +
    geom_line() +
    scale_x_continuous(
      breaks = round(seq(0, max(tblg$over), by=1), 1)
    )
  fname <- str_c("~/officer_", str_replace(city, " ", "_"), ".png")
  ggsave(fname, p, width=12, height=8, units="in")
}
