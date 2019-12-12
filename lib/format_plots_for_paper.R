library(ggplot2)
library(patchwork)

format_mj <- function(mj) {
  sr <- mj$plots$search_rates
  md <- mj$plots$misdemeanor_rates

  label <- theme(axis.title.y=element_text(
    angle=90,
    margin=margin(t=0,r=20,b=0,l=0)
  ))
  legend <- theme(
    legend.title=element_blank(),
    legend.background=element_rect(fill="transparent"),
    legend.position=c(0.75, 0.85)
  )
  keys <- scale_color_manual(
    labels=c("White", "Black", "Hispanic"),
    values=c("blue", "black", "red")
  )
  
  srt <- (
    sr$CO$plot + label + ylab("Search Rate")
    | sr$WA$plot + legend + keys
  )
  mdt <- (
    md$CO$plot + label + ylab("Drug & Misdemeanor Rate")
    | md$WA$plot + legend + keys
  )

  noX <- theme(axis.text.x=element_blank(), axis.ticks.x=element_blank())
  legend <- theme(
    legend.title=element_blank(),
    legend.background=element_rect(fill="transparent"),
    legend.position=c(0.825, 0.84)
  )
  truncate <- coord_cartesian(ylim=c(0, 0.025))
  scale <- scale_y_continuous(
    labels=scales::percent_format(accuracy=0.1),
    breaks=c(0.00, 0.01, 0.02)
  )

  src <- (
    sr$AZ$plot + noX
    | sr$CA$plot + noX
    | sr$FL$plot + noX
    | sr$MA$plot + noX + legend + keys
  ) / (
    sr$MT$plot + noX + truncate + scale + label + ylab("Search Rate")
    | sr$NC$plot + noX
    | sr$OH$plot + noX
    | sr$RI$plot + noX
  ) / (
    sr$SC$plot
    | sr$TX$plot
    | sr$VT$plot
    | sr$WI$plot
  )
  
  list(
    treatment_search_rates = srt,
    treatment_misdemeanor_rates = mdt,
    control_search_rates = src
  )
}
