library("tidyverse")

ensure_contract <- function() {
  required_funcs <- c("opp_load_raw", "opp_load", "opp_clean", "opp_save")
  if (!all(map_lgl(required_funcs, exists)))
    stop("Contract not satisfied!")
}
