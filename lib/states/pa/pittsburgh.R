source("common.R")

load_raw <- function(raw_data_dir, n_max) {
  s <- load_regex(raw_data_dir, "subject")
  t <- load_regex(raw_data_dir, "traffic")
  bind_rows(
    make_ergonomic_colnames(s$data) %>%
      mutate(type = "pedestrian"),
    make_ergonomic_colnames(t$data) %>%
      mutate(type = "vehicular", city = "Pittsburgh")
  ) %>%
  mutate(
    officer_id = coalesce(officer_id, officerid),
    officer_years_on_job = coalesce(officeryearsonjob, officeryrsonjob),
    address = coalesce(fulladdress, address),
    race = coalesce(race, stoppersonrace),
    sex = coalesce(sex, stoppersonsex),
    person_id = coalesce(person_id, stoppersonid)
  ) %>%
  select(
    -officerid,
    -officeryearsonjob,
    -officeryrsonjob,
    -fulladdress,
    -stoppersonrace,
    -stoppersonsex,
    -stoppersonid
  ) %>%
  rename(
    officer_age = officerage,
    contraband_found = contrabandfound
  ) %>%
  bundle_raw(c(s$loading_problems, t$loading_problems))
}


clean <- function(d, helpers) {

  tr_race <- c(
    tr_race,
    "hispanic/latino" = "hispanic",
    "black or african-american" = "black",
    "hispanic or latino",
    "american indian/alaskan native" = "other"
  )

  d$data %>%
  filter(city == "Pittsburgh") %>%
  merge_rows(
    stop_date,
    stopstart,
    stopend,
    address,
    officer_id,
    person_id
  ) %>%
  rename(
    subject_age = age,
    reason_for_stop = reason,
    violation = crimedescription,
    location = address
  ) %>%
  # TODO(phoebe): what is the difference between zone, zone_division,
  # policezone, and officerzone?
  # https://app.asana.com/0/456927885748233/1115427454091545 
  mutate(
    # NOTE: stop_date is for pedestrian stops, stopstart is for vehicular
    # vehicular data contains stopend as well
    datetime = parse_datetime(
      coalesce(stop_date, stopstart),
      "%Y/%m/%d %H:%M:%S"
    ),
    date = as.Date(datetime),
    time = format(datetime, "%H:%M:%S"),
    # TODO(phoebe): why are sex and gender mismatched 73% of the time?
    # https://app.asana.com/0/456927885748233/1115427454091546
    subject_sex = if_else_na(
      sex != gender,
      NA_character_,
      tr_sex[coalesce(sex, gender)]
    ),
    # TODO(phoebe): why are ethnicity and race are mismatched so often?
    # https://app.asana.com/0/456927885748233/1115427454091546
    subject_race = if_else_na(
      race != ethnicity,
      NA_character_,
      tr_race[str_to_lower(coalesce(race, ethnicity))]
    ),
    officer_race = tr_race[str_to_lower(officerrace)],
    officer_sex = tr_sex[officersex],
    # NOTE: vehicular stops don't indicate whether a search occurred, so we
    # infer it from search outcome fields; objectsearched is from pedestrian
    # stops, the others are from vehicular data
    search_conducted =
      !is.na(objectsearched)
      | !is.na(contraband_found)
      | !is.na(evidencefound)
      | !is.na(weaponsfound)
      | !is.na(nothingfound),
    # TODO(phoebe); what does evidencefound refer to, and how is it
    # different from contraband? And is there any way to tell when
    # weaponsfound means weapons that are contraband?
    # https://app.asana.com/0/456927885748233/1115427454091547
    contraband_found = if_else_na(
      search_conducted & type == "vehicular" & is.na(contraband_found),
      FALSE,
      tr_yn[contraband_found]
    ),
    # NOTE: don't replace_na here since occupfrisked isn't defined for
    # pedestrian stops
    frisk_performed = tr_yn[occupfrisked],
    tmp_outcome = str_to_lower(coalesce(results, outcome)),
    arrest_made = str_detect(tmp_outcome, "arrest"),
    citation_issued = str_detect(tmp_outcome, "cited"),
    warning_issued = str_detect(tmp_outcome, "warned"),
    outcome = first_of(
      arrest = arrest_made,
      citation = citation_issued,
      warning = warning_issued
    )
  ) %>%
  helpers$add_lat_lng(
  ) %>%
  rename(
    raw_race = race,
    raw_ethnicity = ethnicity,
    raw_officer_race = officerrace,
    raw_object_searched = objectsearched,
    raw_evidence_found = evidencefound,
    raw_weapons_found = weaponsfound,
    raw_nothing_found = nothingfound,
    raw_zone = zone,
    raw_zone_division = zone_division,
    raw_police_zone = policezone,
    raw_officer_zone = officerzone
  ) %>%
  standardize(d$metadata)
}
