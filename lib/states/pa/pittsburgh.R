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
    subject_race = coalesce(race, stoppersonrace),
    subject_sex = coalesce(sex, stoppersonsex),
    person_id = coalesce(person_id, stoppersonid)
  ) %>%
  select(
    -officerid,
    -officeryearsonjob,
    -officeryrsonjob,
    -fulladdress,
    -race,
    -stoppersonrace,
    -sex,
    -stoppersonsex,
    -stoppersonid
  ) %>%
  rename(
    officer_age = officerage,
    officer_race = officerrace,
    officer_sex = officersex,
    contraband_found = contrabandfound
  ) %>%
  bundle_raw(c(s$loading_problems, t$loading_problems))
}


clean <- function(d, helpers) {

  tr_race <- c(
    "Asian" = "asian/pacific islander",
    "Black" = "black",
    "Hispanic" = "hispanic",
    "Hispanic/Latino" = "hispanic",
    "Other" = "other/unknown",
    "Unknown" = "other/unknown",
    "White" = "white",
    "Black or African-American" = "black",
    "Hispanic or Latino",
    "American Indian/Alaskan Native" = "other/unknown"
  )

  d$data %>%
    filter(city == "Pittsburgh") %>%
    rename(
      subject_age = age,
      reason_for_stop = reason,
      violation = crimedescription,
      location = address
    ) %>%
    # TODO(phoebe): what is the difference between zone, zone_division,
    # policezone, and officerzone?
    # 
    mutate(
      # NOTE: vehicular data contains stopend as well
      datetime = parse_datetime(coalesce(stop_date, stopstart)),
      date = as.Date(datetime),
      time = format(datetime, "%H:%M:%S"),
      # TODO(phoebe): why are sex and gender mismatched 73% of the time?
      subject_sex = tr_sex[if_else_na(
        subject_sex != gender,
        NA_character_,
        subject_sex
      )],
      subject_race = tr_race[subject_race],
      ethnicity = tr_race[ethnicity],
      # TODO(phoebe): ethnicity and race are mismatched quite often, what's
      # going on?
      #
      subject_race = if_else_na(
        subject_race != ethnicity,
        NA_character_,
        coalesce(subject_race, ethnicity)
      ),
      # TODO(phoebe); what does evidencefound refer to, and how is it
      # different from contraband? And is there any way to tell when
      # weaponsfound means weapons that are contraband?
      # 
      contraband_found = coalesce(
        tr_yn[contraband_found],
        !tr_yn[nothingfound]
      ),
      # NOTE: vehicular stops don't indicate whether a search occurred, so we
      # infer it from whether contraband was found
      search_conducted = !is.na(objectsearched)
        | !is.na(contraband_found)
        | !is.na(evidencefound)
        | !is.na(weaponsfound),
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
    # helpers$add_lat_lng(
    # ) %>%
    standardize(d$metadata)
}
