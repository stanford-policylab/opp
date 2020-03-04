library(ggplot2)
library(patchwork)

format_mj <- function(mj) {
  sr <- mj$plots$search_rates
  md <- mj$plots$misdemeanor_rates

  y0 <- scale_y_continuous(
    expand=c(0, 0),
    labels=scales::percent_format(accuracy=0.1),
    breaks=scales::pretty_breaks(4)
  )
  label <- theme(axis.title.y=element_text(
    angle=90,
    margin=margin(t=0,r=20,b=0,l=0)
  ))
  legend <- theme(
    legend.title=element_blank(),
    legend.background=element_rect(fill="transparent"),
    legend.position=c(0.70, 0.85)
  )
  keys <- scale_color_manual(
    labels=c("White drivers", "Black drivers", "Hispanic drivers"),
    values=c("blue", "black", "red")
  )
  
  srt <- (
    sr$CO$plot + y0 + label + ylab("Search Rate")
    | sr$WA$plot + y0 + legend + keys 
  )
  mdt <- (
    md$CO$plot + y0 + label + ylab("Drug & Misdemeanor Rate")
    | md$WA$plot + y0 + legend + keys
  )

  noX <- theme(axis.text.x=element_blank(), axis.ticks.x=element_blank())
  legend <- theme(
    legend.title=element_blank(),
    legend.background=element_rect(fill="transparent"),
    legend.position=c(0.75, 0.87)
  )
  truncate <- coord_cartesian(ylim=c(0, 0.025))

  src <- (
    sr$AZ$plot + noX + y0
    | sr$CA$plot + noX + y0
    | sr$FL$plot + noX + y0
    | sr$MA$plot + noX + y0 + legend + keys
  ) / (
    sr$MT$plot + noX + truncate + y0 + label + ylab("Search Rate")
    | sr$NC$plot + noX + y0
    | sr$OH$plot + noX + y0
    | sr$RI$plot + noX + y0
  ) / (
    sr$SC$plot + y0
    | sr$TX$plot + y0
    | sr$VT$plot + y0
    | sr$WI$plot + y0
  )
  
  list(
    treatment_search_rates = srt,
    treatment_misdemeanor_rates = mdt,
    control_search_rates = src
  )
}
