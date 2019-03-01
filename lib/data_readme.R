library(knitr)
library(here)
source(here::here("lib", "opp.R"))


data_readme <- function() {
  opp_apply(data_readme_for) %>%
  bind_rows() %>%
  arrange(state, city) %>%
  write_csv("/tmp/data_readme.csv")
}


data_readme_for <- function(state, city) {
  tbl <- opp_load_clean_data(state, city)
  # NOTE: mark redacted columns for public release
  rename_mp <- str_replace(redact_for_public_release, "$", "*")
  names(rename_mp) <- redact_for_public_release
  dr <- range(tbl$date, na.rm = T)
  date_range <- str_c(
    format(dr[[1]], "%Y-%m-%d"),
    " to ",
    format(dr[[2]], "%Y-%m-%d")
  )
  tribble(
    ~state, ~city, ~date_range, ~predicated_null_rates,
    state, city, date_range, as.character(kable(
      predicated_coverage_rates(tbl, reporting_predicated_columns) %>%
        mutate(`coverage rate` = pretty_percent(`coverage rate`, 1)) %>%
        rename_cols(rename_mp) %>%
        filter(feature != "raw_row_number"),
      format='html'
    ))
  )
}

if (!interactive()) {
  data_readme()
}
