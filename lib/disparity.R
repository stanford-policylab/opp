source("opp.R")

main <- function() {
  d <- load_data()
  # par_pmap run outcome test
  # par_pmap run threshold test
  # par_pmap run disparity_plot
}


load_data <- function() {
  data <- list()
  data['ca_san_diego'] <- opp_load_data_for_disparity("ca", "san_diego") %>%
    filter(
      # NOTE: data doesn't meet threshold for 2014
      year(date) != 2014,
      # NOTE: these service areas have insufficient and/or unusable data
      !(service_area %in% c("530", "630", "840", "unknown") 
    )
}
