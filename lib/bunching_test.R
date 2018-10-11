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
      speed_and_posted_and_officer_not_na = speed_and_posted_not_na & speed_and_officer_not_na
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

  # TODO(danj):
  # check rates by month-year by beat/division/sector
  # plot rates by officer for over 
  # think about filtering criteria below
  ok <-
    tbl %>%
    filter(
      city == "Oklahoma City",
      speed >= 15,
      speed <= 130
    )
  valid_ok_officers <-
    ok %>%
    group_by(officer_id) %>%
    count() %>%
    ungroup() %>%
    filter(n > 20) %>%
    pull(officer_id)
  okf <-
    ok %>%
    filter(officer_id %in% valid_ok_officers) %>%
    mutate(over = speed - posted_speed) %>%
    group_by(over) %>%
    count() %>%
    ungroup() %>%
    filter(
      over > 0,
      over < 50
    )
  p <-
    ggplot(okf, aes(x=over, y=n)) +
    geom_line() +
    scale_x_continuous(
      breaks = round(seq(0, max(okf$over), by=1), 1)
    ) +
    theme(legend.position="none")
  ggsave("~/ok_officer.png", p, width=12, height=8, units="in")
}
