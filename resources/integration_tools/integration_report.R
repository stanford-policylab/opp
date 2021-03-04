library(here)
source(here::here("lib", "opp.R"))

# replace as appropriate, e.g., 
# /share/data/opp/data/states/{state}/{city}/raw_csv
path_to_file <- ""

path_to_clean_rds <- ""

# HELPERS

# takes in city name, data frame with new data locations
# returns list of raw files for that city 
get_all_raw_files <- function(state, city) {
  
  # replace this with a path to the file 
  list.files(glue(path_to_file), 
             full.names=TRUE)
}

# use to tag the date variable for each one
get_csv_colnames <- function(file_name) {
  col_names <- read_csv(file_name) %>% colnames()
  tribble(
    ~filename, ~colnames,
    file_name, col_names
  )
}

# use to automatically tag the date variable for each one
get_datecols <- function(file, column_names, pattern_ = 'date|dtm') {
  date_colname <- ""
  
  date_col_index <- column_names %>%
    grep(pattern = pattern_, ignore.case = TRUE)
  
  if (length(date_col_index) > 0) {
    date_colname <- column_names[date_col_index] 
  }
  
  tribble(
    ~filename, ~date_str_name,
    file, date_colname[1]
  )
}

load_info <- function(tbl) {
  file <- tbl['filename']
  date_var <- tbl['date_str_name']
  
  df <- read_csv(file) 
  
  if(date_var != "") {
    names(df)[names(df)==date_var] <- "date"
    
    df <- df %>%
      mutate(date = str_replace(date, " .*", "") %>% lubridate::ymd())
    
    tribble(
      ~data, ~date_min, ~date_max, ~nrow, ~ncol,
      file, 
      min(df$date, na.rm=T) %>% as.character(), 
      max(df$date, na.rm=T) %>% as.character(), 
      nrow(df), ncol(df)
    )
  } else {
    tribble(
      ~data, ~date_min, ~date_max, ~nrow, ~ncol,
      file, "date var not detected", "Unknown", nrow(df), ncol(df)
    )
  }
}

get_info_clean_data <- function(state, city) {
  state <- str_to_lower(state)
  clean_file_path <- glue(
    path_to_clean_rds
    )
  df <- readRDS(clean_file_path)
  
  tribble(
    ~data, ~date_min, ~date_max, ~nrow, ~ncol,
    "clean", 
    min(df$data$date, na.rm=T) %>% as.character(), 
    max(df$data$date, na.rm=T) %>% as.character(), 
    nrow(df$data), ncol(df$data)
  )
}


# REPORT VARIABLES
state <- normalize_state(state)
city <- normalize_city(city)

title <- create_title(state, city)

# Date range for each file
files <- get_all_raw_files(state, city)
file_cols <- map(files, get_csv_colnames) %>% bind_rows()
date_var_tbl <- map2(file_cols$filename, 
                     file_cols$colnames, 
                     get_datecols) %>% bind_rows()
date_info <- apply(date_var_tbl, 1, load_info) %>% 
  bind_rows(get_info_clean_data(state, city)) %>% 
  kable()

# Colname comparison
file_cols_cleaned <- file_cols %>%
  mutate(filename = str_replace(filename, "^.*raw_csv/", ""))
file_cols_cleaned$colnames <- lapply(file_cols$colnames, make_ergonomic)

make_colname_df <- function(filename, col_list) {
  tbl <- col_list %>% 
    as.data.frame() %>%
    mutate(file = 1)
  colnames(tbl) <- c("col_name", filename) 
  tbl
}

colnames_tbl <- 
  map2(file_cols_cleaned$filename, 
     file_cols_cleaned$colnames, 
     make_colname_df) %>% 
  reduce(full_join) %>% 
  mutate_all(~replace(., is.na(.), 0))

## heat map with presence of variables across data sources

colname_heatmap <- colnames_tbl %>%
  pivot_longer(cols = -col_name, 
               names_to = "dataset", 
               values_to = "present") %>%
  ggplot(aes(dataset, col_name, fill= as.factor(present))) +
  scale_x_discrete(position="top") + 
  theme(axis.text.x = element_text(angle = 90)) + 
  geom_tile() + 
  scale_fill_brewer(palette=1)


## similar colnames table 
cols <- colnames_tbl %>% pull(col_name)

column_sim_matrix <- 
  adist(colnames_tbl$col_name) %>%
  as.data.frame() %>%
  setNames(., cols) 

column_sim_matrix[lower.tri(column_sim_matrix)] <- NA

column_similarities <- column_sim_matrix %>% 
  mutate(col_name_1 = cols) %>%
  pivot_longer(cols = -col_name_1, 
               names_to = "col_name_2", 
               values_to = "l_dist")

similar_cols <- column_similarities %>%
  filter(l_dist > 0, l_dist < 5) %>%
  arrange(l_dist) %>%
  kable()

