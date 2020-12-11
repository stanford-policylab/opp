source("common.R")


# VALIDATION: [YELLOW] The Houston PD's Annual Reports don't list traffic
# figures, but the stop counts don't appear unreasonable for a city of 2M
# people. 2018 only has partial data. 
# NEW DATA UPDATE: Number of stops on 2019 is roughly on par with number
# of stops in 2017. New data for 2018 is the same as old 2018 data (need to fix). 
load_raw <- function(raw_data_dir, n_max) {
  
  # old data 
  old_2014 <- load_single_file(raw_data_dir, '2014.csv', n_max = n_max)
  old_2015 <- load_single_file(raw_data_dir, '2015.csv', n_max = n_max)
  old_2016 <- load_single_file(raw_data_dir, '2016.csv', n_max = n_max)
  old_2017 <- load_single_file(raw_data_dir, '2017.csv', n_max = n_max)
  
  # new data: note that old data only had part of 2018, so we use new 
  # data for 2018, which has the full year
  new_2018 <- load_single_file(raw_data_dir, '2018.csv', n_max = n_max) 
  new_2019 <- load_single_file(raw_data_dir, '2019.csv', n_max = n_max)
  new_2020 <- load_single_file(raw_data_dir, '2020.csv', n_max = n_max)
  
  old_d <- bind_rows(
    old_2014$data,
    old_2015$data,
    old_2016$data,
    old_2017$data
  )
  
  new_d <- bind_rows(
    new_2018$data,
    new_2019$data,
    new_2020$data %>% rename("DISPOTION" = "DISPOSITION_NAME")
  ) %>%
    rename(`Case Number` = Case_Nbr,
           `Offense Date` = Offense_Dtm,
           Block = VIO_STREET_NBR,
           Street = VIO_STREET,
           `Scnd Block` = Scnd_Blk_Mile,
           `Scnd Street` = Scnd_St_Name,
           Race = RACE,
           Gender = GENDER,
           `Defendant Name` = DfndtName,
           `Citataion Num` = CITATION_NUMBER,
           Speed = Driving_Speed,
           `Posted Speed` = Posted_Speed,
           `V Color` = Veh_Color,
           `V Make` = Veh_Make,
           `V Model` = Veh_Model,
           `Violation Description` = VioDesc,
           `Officer Name` = OFFICER_NAME,
    ) %>%
    select(-VioCode, -Prim_Mile_Post_Number, -Scnd_Mile_Post_Number,
           -CaseStatus, -DISPOSITION, -DISPOTION)
  
  bundle_raw(
    bind_rows(old_d, new_d), 
    c(
      old_2014$loading_problems, 
      old_2015$loading_problems, 
      old_2016$loading_problems, 
      old_2017$loading_problems, 
      new_2018$loading_problems, 
      new_2019$loading_problems, 
      new_2020$loading_problems
    )
  )
}


clean <- function(d, helpers) {
  
  tr_race <- c(
    tr_race,
    "american indian" = "other",
    "pacific islander" = "asian/pacific islander"
  )
  
  # TODO(phoebe): can we get search/contraband fields?
  # https://app.asana.com/0/456927885748233/663043550621572
  d$data %>%
    merge_rows(
      `Defendant Name`,
      Gender,
      Race,
      Street,
      Block,
      `Scnd Street`,
      `Scnd Block`,
      `Officer Name`,
      `Offense Date`
    ) %>%
    filter(
      `Defendant Name` != "TICKET, TEST", 
      `Defendant Name` != "TEST, TICKET",
    ) %>%
    rename(
      vehicle_color = `V Color`,
      vehicle_make = `V Make`,
      vehicle_model = `V Model`,
      violation = `Violation Description`,
      speed = Speed,
      posted_speed = `Posted Speed`
    ) %>%
    separate_cols(
      `Defendant Name` = c("subject_last_name", "subject_first_middle_name"),
      sep = ", "
    ) %>%
    separate_cols(
      subject_first_middle_name = c("subject_first_name", "subject_middle_name"),
      sep = " "
    ) %>%
    separate_cols(
      `Offense Date` = c("date","time"), 
      sep=" "
    ) %>%
    mutate(
      # TODO(phoebe): can we confirm these are all vehicle related incidents?
      # https://app.asana.com/0/456927885748233/663043550621573
      type = "vehicular",
      date = parse_date(date), 
      time = parse_time(time), # time not getting processed correctly 
      # NOTE: either block and street are provided or two cross streets
      # NEW DATA NOTE: the above note is not true for the new data
      location = coalesce(
        str_c(Block, Street, sep = " "),
        str_c(Street, "AND", `Scnd Street`, sep = " "),
        Street
      ),
      subject_race = tr_race[str_to_lower(Race)],
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
    helpers$add_shapefiles_data(
    ) %>%
    rename(
      beat = Beats,
      district = District.x,
      raw_race = Race
    ) %>%
    standardize(d$metadata)
}