library(tidyverse)

#' Disparity plot: plot rates across demographic groups to identify disparities
#'
#' @param tbl a tibble containing the following data
#' @param ... additional attributes controlled for when rates were computed
#' @param demographic_col contains a population division of interest, i.e. race,
#'        age group, sex, etc...
#' @param majority_demographic identifies the demographic to compare all others to
#' @param rate_col contains the rates to be compared between groups
#' @param size_col contains the denominator of \code{rate_col}
#' @param title plot title
#' @param axis_title x-axis = \code{majority_demographic} \code{axis_title},
#'        y-axis = "Minority" \code{axis_title}
#' @param size_title title for point-size legend
#' @param epsilon_rate sets margins on the min and max rate to expand axes
#' 
#' @return ggplot scatterplot of rates faceted by minority demographics
#'
#' @examples
#' disparity_plot(
#'   tbl, 
#'   precinct, 
#'   demographic_col = subject_race, 
#'   majority_demographic = "white", 
#'   rate_col = `contraband_found where search_conducted`,
#'   size_col = n_search_conducted
#'  )
disparity_plot <- function(
  tbl,
  ...,
  demographic_col = subject_race, 
  majority_demographic = "white", 
  rate_col = `contraband_found where search_conducted`,
  size_col = n_search_conducted,
  title = "Contraband recovery rates by sub-geography",
  axis_title = "hit rate",
  size_title = "Num searches\nconducted",
  epsilon_rate = 0.05,
  axis_max = NULL
) {
  
  control_colqs <- enquos(...)
  demographic_colq <- enquo(demographic_col)
  rate_colq <- enquo(rate_col)
  size_colq <- enquo(size_col)
  control_colnames <- colnames(select(tbl, !!!control_colqs)) 
  size_colname <- quo_name(size_colq)
  minority_demographics_colnames <- setdiff(
    pull(tbl, !!demographic_colq),
    majority_demographic
  )
  
  tbl <- 
    tbl %>% 
    select(
      !!!control_colqs, 
      !!demographic_colq,
      !!size_colq,
      !!rate_colq
    )
  majority_and_minority_rates <-
    tbl %>%
    select(-!!size_colq) %>%
    spread(!!demographic_colq, !!rate_colq) %>%
    rename(majority_rate = majority_demographic) %>%
    gather(minority_demographic, minority_rate, minority_demographics_colnames)
  
  majority_plus_minority_sizes <-
    tbl %>%
    select(-!!rate_colq) %>% 
    spread(!!demographic_colq, !!size_colq) %>%
    rename(majority_size = majority_demographic) %>% 
    gather(minority_demographic, minority_size, minority_demographics_colnames) %>% 
    group_by(!!!control_colqs, minority_demographic) %>% 
    mutate(!!size_colname := majority_size + minority_size) %>% 
    ungroup() %>% 
    select(!!size_colq, !!!control_colqs, minority_demographic)
  
  data <- left_join(
    majority_and_minority_rates,
    majority_plus_minority_sizes,
    by = c(control_colnames, "minority_demographic")
  ) %>% 
    mutate(minority_demographic = 
             str_c(str_to_title(minority_demographic), " drivers")
    )
  
  if(is.null(axis_max)) {
    axis_limits <- c(
      max(min(pull(tbl, !!rate_colq)) - epsilon_rate, 0),
      max(pull(tbl, !!rate_colq)) + epsilon_rate
    )
  } else {
    axis_limits <- c(0, axis_max)
  }

  data %>%
    ggplot(aes_string("majority_rate", "minority_rate")) +
    geom_point(aes_string(size = size_colname), alpha = 0.8, shape = 1) +
    geom_abline(linetype = "dashed") +
    facet_grid(cols = vars(minority_demographic)) +
    scale_x_continuous(
      labels = scales::percent, 
      limits = axis_limits, 
      expand = c(0,0)
    ) +
    scale_y_continuous(
      labels = scales::percent, 
      limits = axis_limits,
      expand = c(0,0)
    ) +
    scale_size_area(labels = scales::comma, max_size = 15) +
    coord_fixed() +
    labs(
      x = str_c(str_to_title(majority_demographic), " ", axis_title),
      y = str_c("Minority ", axis_title),
      size = size_title,
      title = title
    ) +
    theme_bw(base_size=15) +
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
      # Simplify the legend
      legend.key=element_blank(),
      legend.background=element_rect(fill='transparent')
      # legend.title=element_blank()
    )
    
}


