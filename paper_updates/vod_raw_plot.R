source(here::here("lib", "opp.R"))
source(here::here("lib", "veil_of_darkness.R"))

time_to_minute <- function(time) {
  hour(hms(time)) * 60 + minute(hms(time))
}
# data <- read_rds(here::here("cache", "vod_state_data.rds"))
# 
# print("Data loaded")
# 
# data <- prepare_vod_data(
#     data,
#     state,
#     lat_col = center_lat,
#     lng_col = center_lng
#   )$data

# write_rds(data, here::here("cache", "vod_state_data_prepped.rds"))
# print("Data prepped")

# data %>%
read_rds(here::here("cache", "vod_state_data_prepped.rds")) %>%
  # filter(time >= hm("17:30"), time <= hm("17:45")) %>%
  mutate(
    minutes_since_sunset = minute - sunset_minute,
    binned_minutes_since_sunset = cut(
      minutes_since_sunset,
      breaks = seq(-95, 65, 10),
      labels = seq(-90, 60, 10)
    )
  ) %>%
  filter(!is.na(binned_minutes_since_sunset)) %>%
  group_by(binned_minutes_since_sunset, minute, state) %>%
  summarise(
    n = n(),
    n_black = sum(subject_race == "black")
  ) %>%
  mutate(
    minutes_since_dark = as.integer(as.character(binned_minutes_since_sunset))
  ) %>%
  ungroup() %>%
  write_rds(here::here("cache", "vod_state_aggs_for_plot-all_times-by_state.rds"))

print("Data saved")
data <- read_rds(here::here("cache", "vod_state_aggs_for_plot-all_times-by_state.rds"))

generate_plot <- function(
  data, s,
  start_minute, window_size = 15,
  y_min = 0.1, y_max = 0.4,
  save_to = NULL, keep_title = T
) {
  end_minute = start_minute + window_size
  d <- data %>%
    filter(
      state == s,
      minute >= start_minute, minute <= end_minute,
      minutes_since_dark != -20
    ) %>%
    group_by(minutes_since_dark) %>%
    summarise(
      proportion_black = sum(n_black) / sum(n),
      n = sum(n)
    ) %>%
    mutate(is_dark = minutes_since_dark >= 0) %>%
    group_by(is_dark) %>%
    mutate(
      avg_p_black = weighted.mean(proportion_black, w = n),
      se = 2*sqrt(avg_p_black * (1 - avg_p_black) / sum(n))
    ) %>%
    ungroup()

  p <- d %>%
    ggplot(aes(
      minutes_since_dark,
      proportion_black)
    ) +
    geom_point(aes(size = n)) +
    geom_smooth(
      aes(y = avg_p_black, color = is_dark),
      method = "lm", se = F, linetype = "dashed"
    ) +
    geom_vline(xintercept = -25, linetype = "dotted") +
    geom_vline(xintercept = 0, linetype = "dotted") +
    geom_ribbon(
      data = filter(d, is_dark),
      aes(ymin = avg_p_black - se, ymax = avg_p_black + se),
      alpha=0.3
    ) +
    geom_ribbon(
      data = filter(d, !is_dark),
      aes(ymin = avg_p_black - se, ymax = avg_p_black + se),
      alpha=0.3
    ) +
    scale_x_continuous(
      "Minutes since dark",
      limits = c(-90, 60),
      breaks = seq(-90, 60, 15)
    ) +
    scale_y_continuous(
      "Proportion black",
      limits = c(y_min, y_max),
      breaks = seq(0.0, 1.0, 0.02)
    ) +
    scale_color_manual(values = c("blue", "blue")) +
    labs(title = str_c(
      s, ", ",
      minute_to_time(start_minute), " to ",
      minute_to_time(end_minute))
    ) +
    theme_bw(base_size = 18) +
    theme(legend.position = "none") +
    our_theme(keep_title = keep_title)
  if(!is.null(save_to)) {
    dir <- dir_create(path(save_to, s))
    ggsave(p,
      filename = path(dir, str_c(minute_to_time(start_minute), "_to_",
                  minute_to_time(end_minute), ".pdf")),
      width = 8, height = 8, units = "in"
    )
  } else {
    p
  }
}

minute_to_time <- function(minute) {
  str_c(
    as.character(minute %/% 60 - 12),
    ":",
    str_pad(as.character(minute %% 60), 2, pad = "0"),
    "pm"
  )
}

plot_wrapper <- function(state, start_minute) {
  generate_plot(
    data, s = state, start_minute = start_minute, y_min = 0,
    save_to = here::here("plots", "vod_raw", "vod_plots_by_state")
  )
}

expand.grid(
  state = unique(data$state), 
  start_minute = seq(1050, 1230, 15)
) %>% 
  mutate(state = as.character(state)) %>% 
  pmap(.f = plot_wrapper)




###### TX panels ######


start_minute <- 1140
start_minute2 <- start_minute + 15
start_minute3 <- start_minute2 + 15
end_minute <- start_minute3 + 15

d <- data %>%
  filter(
    state == "TX",
    minute >= start_minute, minute <= end_minute,
    minutes_since_dark != -20
  ) %>%
  mutate(panel = case_when(
    minute < start_minute2 ~ "7:00pm to 7:15pm",
    minute < start_minute3 ~ "7:15pm to 7:30pm",
    minute <= end_minute ~ "7:30pm to 7:45pm"
  )) %>% 
  group_by(minutes_since_dark, panel) %>%
  summarise(
    proportion_black = sum(n_black) / sum(n),
    n = sum(n)
  ) %>%
  mutate(is_dark = minutes_since_dark >= 0) %>%
  group_by(is_dark, panel) %>%
  mutate(
    avg_p_black = weighted.mean(proportion_black, w = n),
    se = 2*sqrt(avg_p_black * (1 - avg_p_black) / sum(n))
  ) %>%
  ungroup()

d %>%
  ggplot(aes(
    minutes_since_dark,
    proportion_black)
  ) +
  geom_point(aes(size = n)) +
  geom_smooth(
    aes(y = avg_p_black, color = is_dark),
    method = "lm", se = F, linetype = "dashed"
  ) +
  geom_vline(xintercept = -25, linetype = "dotted") +
  geom_vline(xintercept = 0, linetype = "dotted") +
  geom_ribbon(
    data = filter(d, is_dark),
    aes(ymin = avg_p_black - se, ymax = avg_p_black + se),
    alpha=0.3
  ) +
  geom_ribbon(
    data = filter(d, !is_dark),
    aes(ymin = avg_p_black - se, ymax = avg_p_black + se),
    alpha=0.3
  ) +
  scale_x_continuous(
    "Minutes since dark",
    limits = c(-90, 60),
    breaks = seq(-90, 60, 30)
  ) +
  scale_y_continuous(
    "Percent black",
    limits = c(0.15, 0.35),
    breaks = seq(0.0, 1.0, 0.05),
    labels = scales::percent
  ) +
  scale_color_manual(values = c("blue", "blue")) +
  labs(title = str_c(
    "TX, ",
    minute_to_time(start_minute), " to ",
    minute_to_time(end_minute))
  ) +
  facet_grid(cols = vars(panel)) +
  theme_bw(base_size = 18) +
  theme(legend.position = "none") +
  our_theme(keep_title = F)
