library(tidyverse)
library(lubridate)

# TODO(danj): figure out how to pass column names not as strings
plot_top_n_by_year <- function(tbl, date_col, col_to_rank, top_n = 10) {
  stopifnot(is.data.frame(tbl) || is.list(tbl) || is.environment(tbl))

  d <- tbl %>%
    mutate(yr = year(substitute(date_col))) %>%
    group_by(yr, substitute(col_to_rank)) %>%
    count() %>%
    group_by(yr) %>%
    mutate(yr_rank = row_number(-n)) %>%
    filter(yr_rank <= top_n) %>%
    arrange(yr, yr_rank)

  ggplot(d) +
    geom_bar(aes(x = substitute(col_to_rank), y = n), stat = "identity") +
    facet_grid(yr ~ .) +
    theme(axis.text.x = element_text(angle = 90, hjust = 1))
}
