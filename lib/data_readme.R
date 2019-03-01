library(knitr)
library(here)
source(here::here("lib", "opp.R"))


data_readme <- function() {
  f <- function(state, city) {
    tbl <- opp_load_clean_data(state, city)
    tribble(
      ~state, ~city, ~predicated_null_rates,
      state, city, as.character(kable(
        predicated_null_rates(tbl, reporting_predicated_columns),
        format='html'
      ))
    )
  }
  opp_apply(f) %>%
  bind_rows() %>%
  arrange(state, city) %>%
  write_csv("/tmp/data_readme.csv")
}

if (!interactive()) {
  data_readme()
}
