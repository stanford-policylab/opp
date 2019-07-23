source(here::here("lib", "opp.R"))
source(here::here("lib", "e.R"))
source(here::here("lib", "outcome_test.R"))
source(here::here("lib", "threshold_test.R"))
source(here::here("lib", "disparity_plot.R"))

disparity <- function(from_cache = F) {
  datasets <- list()
  output = here::here("cache", "disparity.rds")
  print("Preparing data...")
  if (from_cache)
    d <- read_rds(output)
  else {
    d <- load("disparity")
    sprintf("Saving data to %s", output)
    write_rds(d, output)
  }
  datasets$state <- filter(d$data, city == "Statewide") %>% 
    mutate(geography = state)
  datasets$city <- filter(d$data, city != "Statewide") %>% 
    unite(geography, c(city, state), sep = ", ", remove = F)
 
  results <- list()
  for (dataset_name in names(datasets)) {
    sprintf("Using %s data...", dataset_name)
    v <- list()
    print("Running outcome test...")
    v$outcome <- outcome_test(
      datasets[[dataset_name]],
      subgeography,
      geography_col = geography
    )
    print("Composing outcome plots...")
    v$outcome$plots <- plt_all(v$outcome$results$hit_rates, "outcome")
    v$outcome$plots$aggregate <- 
      plt(
        v$outcome$results$hit_rates, 
        str_c("outcome aggregate: ", dataset_name)
      )
  
    print("Running threshold test...")
    v$threshold <- threshold_test(
      datasets[[dataset_name]],
      subgeography,
      geography_col = geography,
      n_iter = 5000
    )
    print("Composing threshold plots...")
    v$threshold$plots <- plt_all(v$threshold$results$thresholds, "threshold")
    v$threshold$plots$aggregate <- 
      plt(
        v$threshold$results$thresholds, 
        str_c("threshold aggregate: ", dataset_name)
      )
    print("Running threshold posterior predictive checks...")
    v$threshold$ppc <- list()
    v$threshold$ppc$search_rate <- plt_ppc_rates(
      v$threshold$results$thresholds,
      v$threshold$metadata$posteriors,
      "search_rate", 
      numerator_col = n_action,
      denominator_col = n,
      title = str_c(dataset_name, " threshold ppc - search rates")
    )
    v$threshold$ppc$hit_rate <- plt_ppc_rates(
      v$threshold$results$thresholds,
      v$threshold$metadata$posteriors,
      "hit_rate", 
      numerator_col = n_outcome,
      denominator_col = n_action,
      title = str_c(dataset_name, " threshold ppc - hit rates")
    )
    
    v$threshold$metadata$posteriors <- NULL
    
    # plot_path = opp_results_path(path("plots", dataset_name, "outcome"))
    # dir_create(plot_path)
    # for(loc in names(v$outcome$plots)) {
    #   ggsave(
    #     filename = path(plot_path, str_c(loc, ".pdf")),
    #     plot = v$outcome$plots[[loc]],
    #     device = "pdf"
    #   )
    # }
    # v$outcome$plots <- NULL
    # 
    # plot_path = opp_results_path(path("plots", dataset_name, "threshold"))
    # dir_create(plot_path)
    # for(loc in names(v$threshold$plots)) {
    #   ggsave(
    #     filename = path(plot_path, str_c(loc, ".pdf")),
    #     plot = v$threshold$plots[[loc]],
    #     device = "pdf"
    #   )
    # }
    # v$threshold$plots <- NULL
    # 
    # plot_path = opp_results_path(path("plots", dataset_name, "threshold", "ppc"))
    # dir_create(plot_path)
    # for(ppc_type in names(v$threshold$ppc)) {
    #   ggsave(
    #     filename = path(plot_path, str_c(ppc_type, ".pdf")),
    #     plot = v$threshold$ppc[[loc]],
    #     device = "pdf"
    #   )
    # }
    # v$threshold$ppc <- NULL
    
    results[[dataset_name]] <- v
  }
  results  
}

plt <- function(d, prefix) {
  if (str_detect(prefix, "outcome")) {
    p <- disparity_plot(d, geography, subgeography, title = prefix)
  } else {
    p <- disparity_plot(
      d, geography, subgeography,
      rate_col = threshold,
      size_col = n_action,
      title = prefix,
      axis_title = "threshold"
    )
  }
  p
}

plt_all <- function(tbl, prefix) {
  f <- function(grp) {
    str_geo <- unique(grp$geography)
    title <- str_c(prefix, ": ", str_geo)
    if (str_detect(prefix, "outcome")) {
      p <- disparity_plot(
        grp, geography, subgeography, 
        title = str_c(str_geo, " hit rates")
      )
    } else {
      p <- disparity_plot(
        grp,
        geography, subgeography,
        demographic_col = subject_race,
        rate_col = threshold,
        size_col = n_action,
        title = str_c(str_geo, " thresholds"),
        axis_title = "threshold"
      )
    }
    p
  }
  tbl %>% 
    group_by(geography) %>% 
    do(plot = f(.)) %>% 
    ungroup() %>% 
    translator_from_tbl(
      "geography",
      "plot"
    )
}

plt_ppc_rates <- function(
  obs, 
  post,
  rate_to_plot,
  numerator_col,
  denominator_col,
  demographic_col = subject_race,
  title, 
  truncate_prob = 0.99
) {
  numerator_colq <- enquo(numerator_col)
  denominator_colq <- enquo(denominator_col)
  demographic_colq <- enquo(demographic_col)
  
  rate_name <- str_remove(rate_to_plot, "_rate") 
  obs <- obs %>% 
    mutate(
      rate = !!numerator_colq / !!denominator_colq,
      num_stops = !!size_colq,
      pred_rate = colMeans(post[[rate_to_plot]]),
      pred_error = rate - pred_rate,
      demographic = str_to_title(!!demographic_colq)
    ) 
  
  print(with(
    obs,
    sprintf(
      'Weighted RMS prediction error: %.2f%%',
      100*sqrt(weighted.mean((pred_error)^2, num_stops))
    )
  ))
  
  obs <- obs %>% 
    filter(pred_rate <= quantile(.$pred_rate, probs = truncate_prob)[[1]])

  ylim <- obs$pred_error %>% range() %>% abs() %>% max()

  generate_ppc_plot(obs, ylim, title, rate_name)
}

generate_ppc_plot <- function(obs, ylim, title, rate_name) {
  
  obs %>% 
    # NOTE: shuffle so that the plot points are not layered by race
    sample_n(nrow(obs), replace = FALSE) %>% 
    ggplot(aes(x=pred_rate, y=pred_error)) +
    geom_point(
      aes(size=n, color=demographic), 
      alpha = 0.8
    ) + 
    scale_size_area(max_size=10) +
    scale_x_continuous(
      str_c('\nPredicted ', rate_name, ' rate'),  
      labels = scales::percent
    ) + 
    scale_y_continuous(
      str_c(str_to_title(rate_name), ' rate prediction error\n'), 
      labels = scales::percent, limits = c(-2*ylim, 2*ylim)
    ) +
    geom_abline(slope=0, intercept=0, linetype='dashed') +
    theme_bw(base_size = 20) +
    theme(
      legend.position=c(1.0,0),
      legend.justification=c(1,0),
      legend.title = element_blank(),
      legend.background = element_rect(fill = 'transparent')
    ) +
    scale_color_manual(values=c('black','red','blue')) +
    guides(size=FALSE) +
    labs(title = title)
}
