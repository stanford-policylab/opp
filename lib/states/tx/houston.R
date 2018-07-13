source("common.R")

load_raw <- function(raw_data_dir, n_max) {
  d <- load_years(raw_data_dir, n_max = n_max)
  bundle_raw(d$data, d$loading_problems)
}


clean <- function(d, helpers) {

  tr_race <- c(
    "White" = "white",
    "Black" = "black",
    "Unknown" = "other/unknown",
    "Asian" = "asian/pacific islander",
    "American Indian" = "other/unknown",
    "Pacific Islander" = "asian/pacific islander"
  )

  # TODO(phoebe): can we get search/contraband fields?
  # https://app.asana.com/0/456927885748233/663043550621572
  d$data %>%
    rename(
      vehicle_color = `V Color`,
      vehicle_make = `V Make`,
      vehicle_model = `V Model`,
      violation = `Violation Description`,
      speed = Speed,
      posted_speed = `Posted Speed`
    ) %>%
    mutate(
      # TODO(phoebe): can we confirm these are all vehicle related incidents?
      # https://app.asana.com/0/456927885748233/663043550621573
      type = "vehicular",
      date = parse_date(`Offense Date`),
      location = coalesce(
        str_c(Block, Street, sep = " "),
        str_c(Street, "AND", `Scnd Street`, sep = " "),
        Street
      ),
      subject_race = tr_race[Race],
      subject_sex = tr_sex[Gender],
      citation_issued = !is.na(`Citataion Num`),
      # TODO(phoebe): can we get other outcomes? arrests/warnings?
      # https://app.asana.com/0/456927885748233/663043550621574
      outcome = first_of(
        "citation" = citation_issued
      )
    ) %>%
    helpers$add_lat_lng(
    ) %>%
    # TODO(danj)
    helpers$add_shapefiles_data(
    ) %>%
    rename(
      beat = Beats,
      district = District.x,
    ) %>%
    standardize(d$metadata)
}
