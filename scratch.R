library(tidyverse)
library(lubridate)

# TODO(danj): figure out how to pass column names not as strings
plot_top_n_by_year <- function(tbl, top_n, date_col, .col_to_rank) {
  d <- tbl %>%
    mutate(yr = year(date_col)) %>%
    group_by(yr, col_to_rank) %>%
    count() %>%
    group_by(yr) %>%
    mutate(yr_rank = row_number(-n)) %>%
    filter(yr_rank <= top_n) %>%
    arrange(yr, yr_rank)

  ggplot(d) +
    geom_bar(aes(x = col_to_rank, y = n), stat = "identity") +
    facet_grid(yr ~ .) +
    theme(axis.text.x = element_text(angle = 90, hjust = 1))
}
