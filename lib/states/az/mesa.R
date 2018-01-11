source("common.R")

load_raw <- function(raw_data_dir, geocodes_path) {
	loading_problems <- list()
  fname <- "2014-03-17_citations_data_prr_sheet_1.csv"
  data <- read_csv_with_types(
    file.path(raw_data_dir, fname),
    c(
      incident_no       = "n",
      arrest_no         = "n",
      cite_no           = "n",
      sex               = "c",
      race              = "c",
      race_fixed        = "c",
      ehtnic            = "c",
      ethnicty_fixed    = "c",
      age               = "i",
      date              = "D",
      time              = "i",
      block             = "i",
      city              = "c",
      ofcr_lnme         = "c",
      ofcr_id           = "i",
      charge_seq        = "i",
      charge            = "c",
      charge_desc       = "c",
      warning           = "c"
    )
  )
  loading_problems[[fname]] <- problems(data)

	list(data = data, metadata = list(loading_problems = loading_problems))
}


clean <- function(d) {
  d$data %>%
    rename(
      incident_id = indicent_no
    ) %>%
    standardize(d$metadata)
}
