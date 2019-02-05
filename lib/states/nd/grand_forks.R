source("common.R")


# VALIDATION: [YELLOW] The Grand Forks PD's 2016 Annual Report cites figures
# that don't totally correspond to our classification here, but are not far
# off. It's not clear what is considered a traffic stop by the PD (i.e. a
# pedestrian stop but as it relates to traffic law?). There are also some
# peculiar spikes, usually at least 1 day a year, that is a clear outlier.

# TODO(phoebe): why are there always spikes around may/june? The following days
# have massive spikes, relatively speaking:
# 2010-05-08 (147)
# 2011-06-02 (157)
# 2012-05-05 (173)
# 2013-05-04 (185)
# 2014-05-10 (138)
# 2015-05-09 (112)
# 2016-05-20 (78)
# https://app.asana.com/0/456927885748233/953848354811707 
load_raw <- function(raw_data_dir, n_max) {
  cit <- load_regex(
    raw_data_dir,
    "Citations",
    n_max = n_max,
    col_names = c(
      "agency",
      "citation_number",
      "date",
      "time",
      "sex",
      "race",
      "age",
      "viol_code",
      "desc",
      "house",
      "street",
      "ht_ft",
      "ht_in",
      "weight"
    ),
    skip = 1
  )
  warn <- load_regex(
    raw_data_dir,
    "Warnings",
    n_max = n_max,
    col_names = c(
      "contact",
      "date",
      "time",
      "house",
      "street",
      "sex",
      "race",
      "desc"
    ),
    skip = 1
  )
  bundle_raw(
    bind_rows(cit$data, warn$data),
    c(cit$loading_problems, warn$loading_problems)
  )
}


clean <- function(d, helpers) {

  tr_race <- c(
    A = "asian/pacific islander",
    B = "black",
    I = "other/unknown",
    U = "other/unknown",
    W = "white"
  )
  
  # NOTE: search and contraband-related fields are not recorded by the PD
  d$data %>%
    helpers$add_type(
      "desc"
    ) %>%
    rename(
      reason_for_stop = desc
    ) %>%
    mutate(
      date = parse_date(date, "%Y%m%d"),
      time = coalesce(
        parse_time_int(time),
        parse_time_int(time, fmt = "%H%M%S")
      ),
      location = str_c_na(house, street, sep = " "),
      warning_issued = !is.na(contact),
      citation_issued = !is.na(citation_number),
      # NOTE: PD says they cannot give arrests as they are not recorded with
      # traffic stops
      outcome = first_of(
        warning = warning_issued,
        citation = citation_issued
      ),
      subject_race = tr_race[race],
      subject_sex = tr_sex[sex]
    ) %>%
    helpers$add_lat_lng(
    ) %>%
    standardize(d$metadata)
}
