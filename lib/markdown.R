library(knitr)
library(here)
source(here::here("lib", "opp.R"))


markdown <- function() {
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
  opp_run_for_all(f) %>% write_csv("/tmp/markdown.csv")
}

if (!interactive()) {
  markdown()
}
