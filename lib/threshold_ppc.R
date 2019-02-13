
rate_ppc <- function(
  rate_to_plot, obs, post, 
  title, truncate_prob = 1, 
  ylim = 0.03
) {
  
  rate <- str_remove(rate_to_plot, "_rate") 
  # obs$pred_rate = colMeans(post$rate_to_plot)
  #obs$pred_search_rate = colMeans(post$search_rate)
  obs <- obs %>% 
    mutate(
      pred_rate = colMeans(post[[rate_to_plot]]),
      pred_error = pull(obs, rate_to_plot) - pred_rate
    ) %>% 
    filter(pred_rate <= quantile(.$pred_rate, probs = 0.95)[[1]])
  
  print(with(obs,
      sprintf('Weighted RMS prediction error: %.2f%%',
      # 100*sqrt(weighted.mean((search_rate-pred_search_rate)^2, num_stops)))
      100*sqrt(weighted.mean((pred_error)^2, num_stops)))
  ))
  
  plt <- obs %>% 
    sample_n(nrow(obs)) %>% 
    ggplot(aes(x=pred_rate, y=pred_error)) +
    geom_point(aes(size=num_stops, color=race), alpha = 0.8) + 
    scale_size_area(max_size=10) +
    scale_x_continuous(str_c('\nPredicted ', rate, ' rate'), #search rate', 
      labels = scales::percent#, expand = c(0, 0)
    ) + 
    scale_y_continuous(str_c(str_to_title(rate), ' rate prediction error\n'), 
      labels = scales::percent, limits = c(-ylim, ylim)
    ) +
    geom_abline(slope=0, intercept=0, linetype='dashed') +
    theme_bw() +
    theme(legend.position=c(1.0,0),
          legend.justification=c(1,0),
          legend.title = element_blank(),
          legend.background = element_rect(fill = 'transparent')) +
    scale_color_manual(values=c('black','red','blue')) +
    guides(size=FALSE) +
    labs(title = title)
  plt
}

d <- read_rds(here::here("cache", "disparity_results.rds"))
state_obs <- d$state$threshold$results$thresholds %>% 
  select(-race) %>% 
  mutate(
    search_rate = n_action / n,
    hit_rate = n_outcome / n_action,
    race = str_to_title(subject_race)
  ) %>% 
  rename(num_stops = n)
state_post <- rstan::extract(d$state$threshold$metadata$fit)  
city_obs <- d$city$threshold$results$thresholds %>% 
  select(-race) %>% 
  mutate(
    search_rate = n_action / n,
    hit_rate = n_outcome / n_action,
    race = str_to_title(subject_race)
  ) %>% 
  rename(num_stops = n)
city_post <- rstan::extract(d$city$threshold$metadata$fit) 

rate_ppc(
  "search_rate", state_obs, state_post, 
  "State threshold ppc - search rates"
)
rate_ppc(
  "search_rate", city_obs, city_post, 
  "City threshold ppc - search rates", truncate_prob = 0.95
)

rate_ppc(
  "hit_rate", state_obs, state_post, 
  "State threshold ppc - hit rates", ylim = 0.4
)
rate_ppc(
  "hit_rate", city_obs, city_post, ylim = 0.25,
  "City threshold ppc - hit rates"#, truncate_prob = 0.95
)
