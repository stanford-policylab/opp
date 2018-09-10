create type race as enum (
  'asian/pacific islander',
  'black',
  'hispanic',
  'other/unknown',
  'white'
);

create type sex as enum (
  'male',
  'female'
);

create type stop_type as enum (
  'pedestrian',
  'vehicular'
);

create type outcome as enum (
  'warnings',
  'citation',
  'summons',
  'arrest'
);

create type search_basis as enum (
  'k9',
  'plain view',
  'consent',
  'probable cause',
  'other'
);

create type state as enum (
  'AL',
  'AK',
  'AZ',
  'AR',
  'CA',
  'CO',
  'CT',
  'DE',
  'DC',
  'FL',
  'GA',
  'HI',
  'ID',
  'IL',
  'IN',
  'IA',
  'KS',
  'KY',
  'LA',
  'ME',
  'MT',
  'NE',
  'NV',
  'NH',
  'NJ',
  'NM',
  'NY',
  'NC',
  'ND',
  'OH',
  'OK',
  'OR',
  'MD',
  'MA',
  'MI',
  'MN',
  'MS',
  'MO',
  'PA',
  'RI',
  'SC',
  'SD',
  'TN',
  'TX',
  'UT',
  'VT',
  'VA',
  'WA',
  'WV',
  'WI',
  'WY'
);


create table if not exists opp
(
  id                              serial not null,

  -- identifiers
  raw_row_number                  integer not null,
  
  -- when
  date                            date,
  time                            time,

  -- where
  location                        text,
  lat                             double precision,
  lng                             double precision,
  county_name                     text,
  neighborhood                    text,
  beat                            text,
  district                        text,
  subdistrict                     text,
  division                        text,
  subdivision                     text,
  police_grid_number              text,
  precinct                        text,
  region                          text,
  reporting_area                  text,
  sector                          text,
  subsector                       text,
  service_area                    text,
  zone                            text,

  -- who
  subject_age                     real,
  subject_dob                     date,
  subject_yob                     integer,
  subject_race                    race,
  subject_sex                     sex,
  officer_id                      text, 
  officer_age                     real,
  officer_dob                     date,
  officer_race                    race,
  officer_sex                     sex,
  officer_first_name              text,
  officer_last_name               text,
  officer_years_of_service        real,
  officer_assignment              text,
  department_id                   text,
  department_name                 text,
  unit                            text,

  -- what
  type                            stop_type,
  disposition                     text,
  violation                       text,
  arrest_made                     boolean,
  citation_issued                 boolean,
  warning_issued                  boolean,
  outcome                         outcome,
  contraband_found                boolean,
  contraband_drugs                boolean,
  contraband_weapons              boolean,
  frisk_performed                 boolean,
  search_conducted                boolean,
  search_person                   boolean,
  search_vehicle                  boolean,
  search_basis                    search_basis,

  -- why
  reason_for_arrest               text,
  reason_for_frisk                text,
  reason_for_search               text,
  reason_for_stop                 text,

  -- other
  speed                           real,
  posted_speed                    real,
  use_of_force_description        text,
  use_of_force_reason             text,
  vehicle_color                   text,
  vehicle_make                    text,
  vehicle_model                   text,
  vehicle_type                    text,
  vehicle_registration_state      state,
  vehicle_year                    integer,
  notes                           text
);
