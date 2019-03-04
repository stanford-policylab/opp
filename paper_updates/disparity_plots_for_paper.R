source(here::here("lib", "disparity_plot.R"))

disparity <- read_rds(here::here("cache", "disparity_results.rds"))
# this one has updated city data (with correct date ranges)
cities <- read_rds(here::here("cache", "disparity_results_cities.rds"))
state_axis_max <- 0.7
city_axis_max <- 0.45

our_theme <- function(keep_title = F) {
  if(keep_title) {
    theme(
      # Make the background white
      panel.background=element_rect(fill='white', colour='white'),
      panel.grid.major=element_blank(),
      panel.grid.minor=element_blank(),
      # Minimize margins
      plot.margin=unit(c(0.2, 0.2, 0.2, 0.2), "cm"),
      # panel.margin=unit(0.25, "lines"),
      panel.spacing = unit(1.0, "lines"),
      # Tiny space between axis labels and tick labels
      axis.title.x=element_text(margin=ggplot2::margin(t=6.0)),
      axis.title.y=element_text(margin=ggplot2::margin(r=6.0)),
      axis.text = element_text(color = "black"),
      # plot.title=element_blank(),
      legend.position = 'none'
    ) 
  } else {
    theme(
      # Make the background white
      panel.background=element_rect(fill='white', colour='white'),
      panel.grid.major=element_blank(),
      panel.grid.minor=element_blank(),
      # Minimize margins
      plot.margin=unit(c(0.2, 0.2, 0.2, 0.2), "cm"),
      # panel.margin=unit(0.25, "lines"),
      panel.spacing = unit(1.0, "lines"),
      # Tiny space between axis labels and tick labels
      axis.title.x=element_text(margin=ggplot2::margin(t=6.0)),
      axis.title.y=element_text(margin=ggplot2::margin(r=6.0)),
      axis.text = element_text(color = "black"),
      plot.title=element_blank(),
      legend.position = 'none'
    ) 
  }
}


disparity_plot(
  disparity$state$outcome$results, 
  geography, sub_geography, axis_max = state_axis_max
) + 
  theme_bw(base_size = 28) + 
  our_theme() 

disparity_plot(
  cities$city$outcome$results, 
  # disparity$city$outcome$results, 
  geography, sub_geography, axis_max = city_axis_max
) + 
  theme_bw(base_size = 28) + 
  our_theme()

disparity_plot(
  disparity$state$threshold$results$thresholds, 
  geography, sub_geography, axis_max = state_axis_max,
  rate_col = threshold, size_col = n_action, axis_title = "threshold"
) + 
  theme_bw(base_size = 28) + 
  our_theme()

disparity_plot(
  # disparity$city$threshold$results$thresholds, 
  cities$city$threshold$results$thresholds, 
  geography, sub_geography, axis_max = city_axis_max,
  rate_col = threshold, size_col = n_action, axis_title = "threshold"
) + 
  theme_bw(base_size = 28) + 
  our_theme()
  