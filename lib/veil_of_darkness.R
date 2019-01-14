source("opp.R")
source("veil_of_darkness_test.R")


veil_of_darkness <- function() {
  tbl <- tribble(
    ~state, ~city, ~center_lat, ~center_lng,
    "AZ", "Mesa", 33.4151843, -111.8314724,
    "CA", "San Francisco", 37.7749295, -122.4194155,
    "CA", "San Jose", 37.3382082, -121.8863286,
    "CO", "Aurora", 39.7294319, -104.8319195,
    "KS", "Wichita", 37.68717609999999, -97.33005299999999,
    "LA", "New Orleans", 29.95106579999999, -90.0715323,
    "MN", "Saint Paul", 44.9537029, -93.0899578,
    "ND", "Grand Forks", 47.9252568, -97.0328547,
    "OH", "Columbus", 39.9611755, -82.99879419999999,
    "OK", "Oklahoma City", 35.4675602, -97.5164276,
    "OK", "Tulsa", 36.1539816, -95.99277500000001,
    "PA", "Philadelphia", 39.9525839, -75.1652215,
    "TN", "Nashville", 36.1626638, -86.7816016,
    "TX", "Arlington", 32.735687, -97.10806559999999,
    "TX", "San Antonio", 29.4241219, -98.49362819999999,
    "VT", "Burlington", 44.4758825, -73.21207199999999,
    "WI", "Madison", 43.0730517, -89.4012302
  )

  select(tbl, state, city) %>%
  opp_load_all_data() %>%
  # TODO(danj): why is this bad?
  filter(!(city == "Madison" & year(date) %in% c(2007, 2008))) %>%
  left_join(tbl) %>%
  veil_of_darkness_test(lat_col=center_lat, lng_col=center_lng)
}
