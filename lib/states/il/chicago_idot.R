source(here::here("lib", "common.R"))

# DATA_DIR <- "~/opp/data/states/il/chicago/raw_csv/"
# 
# # ISR 2020
# isr <- read_csv("~/opp/data/states/il/chicago/raw_csv/15327-p580999-traffic-isr_sheet_2.csv")
# 
# # april 2018 to 
# tsss_1 <- read_csv("~/opp/data/states/il/chicago/raw_csv/15327-p580999-traffic-isr_sheet_3.csv")
# tsss_2 <- read_csv("~/opp/data/states/il/chicago/raw_csv/15327-p580999-traffic-isr_sheet_4.csv")

load_raw <- function(raw_data_dir, n_max) {
  # TODO incorporate isr data?
  # 1: check similarity in columns
  # 2: if similar, create method for deduplication
  
  tsss_1 <- load_single_file(
    raw_data_dir,
    "15327-p580999-traffic-isr_sheet_3.csv",
    n_max
  )
  tsss_2 <- load_single_file(
    raw_data_dir,
    "15327-p580999-traffic-isr_sheet_4.csv",
    n_max
  ) 
  
  colnames(tsss_1$data) <- make_ergonomic(colnames(tsss_1$data))
  colnames(tsss_2$data) <- make_ergonomic(colnames(tsss_2$data))
  
  union(tsss_1$data, tsss_2$data)  %>%
    bundle_raw(c(tsss_1$loading_problems, tsss_2$loading_problems))
}

clean <- function(d, helpers) {
  
  
}