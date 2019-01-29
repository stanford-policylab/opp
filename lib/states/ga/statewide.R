source(here::here("lib", "common.R"))

load_raw <- function(raw_data_dir, n_max) {
  d <- load_years(raw_data_dir, n_max = n_max, col_names = FALSE) 
  bundle_raw(d$data, d$loading_problems)
}

clean <- function(d, helpers) {
  # Value dictionaries
  race_keys <- c("A","B","H","I","O","W","")
  race_vals <- c("Asian","Black","Hispanic","Native American","Other","White",NA)
  race_vals_clean <- c("Asian","Black","Hispanic","Other","Other","White",NA)
  # Dictionaries
  tr_race = c(
    # Race column keys
    "A" = "asian/pacific islander",
    "B" = "black",
    "H" = "hispanic",
    "I" = "other/unknown",
    "O" = "other/unknown",
    "W" = "white"
  )
  tr_sex = c(
    "M" = "male", 
    "F" = "female"
  )
  
  d$data %>%
    # separate date and time
    separate(X4, c("date","time"), " ") %>% 
    # Group same stop rows to account for multiple violations
    merge_rows(date,time,X9,X11,X13,X29,X30,X31,X33,X39,X48,X49,X52,X53,X56) %>% 
    rename(dob = X14, sex = X17, race = X15, loc = X42, violation = X103) %>% 
    mutate(
      # NOTE: loc is usually highway numbers or main roads, X11 is usually city
      location = str_c(loc, ", ", X11), 
      county_name = str_c(str_to_title(as.character(X9)), " County"),
      department_name = X13,
      subject_race = tr_race[race],
      subject_sex = tr_sex[sex],
      outcome = "warning",
      lat = if_else(X48 == "0", NA_real_, as.double(X48)),
      lng = if_else(X49 == "0", NA_real_, as.double(X49)),
      officer_id = str_pad(X56, 4, pad='0'),
      officer_troop = X52,
      officer_rank = X53,
      out_of_state = X39 != 'GA',
      vehicle_make = X30,
      vehicle_model = X31,
      vehicle_color = X33,
      vehicle_year = X29,
      type = "vehicular"
    ) %>% 
    standardize(d$metadata)
}
