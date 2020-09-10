source(here::here("lib", "common.R"))

# DATA_DIR <- "~/opp/data/states/il/chicago/raw_csv/"
# emails <- read_csv("~/opp/data/states/il/chicago/raw_csv/15327-p580999-traffic-isr_sheet_1.csv")
# # ISR 2020
# isr <- read_csv("~/opp/data/states/il/chicago/raw_csv/15327-p580999-traffic-isr_sheet_2.csv")
# 
# # april 2018 to april 2020
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
  # these functions are taking forever
  #colnames(tsss_1$data) <- make_ergonomic_colnames(tsss_1$data)
  #colnames(tsss_2$data) <- make_ergonomic_colnames(tsss_2$data)
  
  # error message when you try to bind csvs directly: 
  # Error: Column `VEH_DRUG_FOUND` can't be converted from logical to numeric
  bind_rows(tsss_1$data, tsss_2$data)  %>%
    distinct() %>%
    bundle_raw(c(tsss_1$loading_problems, tsss_2$loading_problems))
}

# need to process the search and contraband variables 
clean <- function(d, helpers) {
  tr_race = c(
    "AMER INDIAN / ALASKAN NATIVE" = "other",
    "ASIAN" = "asian/pacific islander",
    "HAWAIIAN/PACIFIC ISLANDER" = "asian/pacific islander",
    "BLACK" = "black",
    "HISPANIC" = "hispanic",
    "UNKNOWN" = "unknown",
    "WHITE" = "white"
  )
  
  d$data %>%
    separate(CONTACTDATE, into=c("date","time"), sep=" ") %>%
    unite(location, STREET_NO, DIR, STREET_NME, sep=" ") %>%
    rename(
      beat = BEAT,
      district = DISTRICT,
      unit = CPD_UNIT_NO,
      violation = STATUTE
    ) %>%
    mutate(
      date = date(dmy(date)),
      time = parse_time(time),
      county = "Cook County",
      subject_age = year(date) - YEAR_OF_BIRTH,
      subject_race = fast_tr(RACE, tr_race),
      subject_sex = case_when(
        SEX == "F" ~ "female",
        SEX == "M" ~ "male",
        T ~ "other"
      ),
      type = "vehicular") %>%
    standardize(d$metadata)
}
