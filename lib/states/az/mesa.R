source("common.R")

# VALIDATION: [GREEN] The Mesa Police Department's "2017 Annual Report
# indicates that they had between 115k and 144k traffic stops each year from
# 2014 to 2017, since our numbers are around 30k each year (except 2017 where
# we only have part of the year), it appears as though we only have those stops
# that resulted in actions taken, i.e. arrests, citations, warnings; it's also
# a little unclear as to which charges are specifically pedestrian vs.
# vehicular, so our categorization here is weak; see outstanding TODO
load_raw <- function(raw_data_dir, n_max) {
  d <- load_single_file(
    raw_data_dir,
    "2014-03-17_citations_data_prr.csv",
    n_max
  )
  bundle_raw(d$data, d$loading_problems)
}


clean <- function(d, helpers) {

  tr_race <- c(
    A = "asian/pacific islander",
    B = "black",
    H = "hispanic",
    I = "other/unknown",
    U = "other/unknown",
    W = "white"
  )

  tr_yn = c(
    YES = TRUE,
    NO = FALSE
  )

  colnames(d$data) <- tolower(colnames(d$data))

  d$data %>%
    mutate(
      location = str_trim(str_c(block, city, sep = ", "))
    ) %>%
    helpers$add_lat_lng(
    ) %>%
    rename(
      subject_age = age,
      officer_id = ofcr_id,
      officer_last_name = ofcr_lnme,
      violation = charge_desc
    ) %>%
    mutate(
      time = parse_time_int(time),
      charge_prefix = str_extract(charge, "[0-9]+"),
      # TODO(phoebe): can we get clearer definitions of ped vs veh?
      # https://app.asana.com/0/456927885748233/571408593843006
      type = if_else(
        charge_prefix == "28" & !str_detect(violation, "BICYC|PARK"),
        "vehicular",
        if_else(
          charge_prefix == "10" & !str_detect(violation, "SPEED LIMIT|PARK"),
          "pedestrian",
          NA_character_
        )
      ),
      arrest_made = !is.na(arrest_no),
      citation_issued = !is.na(cite_no),
      warning_issued = tr_yn[warning],
      outcome = first_of(
        arrest = arrest_made,
        citation = citation_issued,
        warning = warning_issued
      ),
      subject_sex = tr_sex[sex],
      subject_race = tr_race[if_else(ethnicity_fixed == "H", "H", race_fixed)]
    ) %>%
    standardize(d$metadata)
}
