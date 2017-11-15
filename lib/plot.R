plot_cols <- function(tbl, output_filename = "plots.pdf") {
  plots <- lapply(colnames(tbl), function (col) { plot_col(tbl, col) })
  pdf(output_filename, onefile = TRUE)
  lapply(plots, print)
  dev.off()
}


plot_col <- function(tbl, col) {
  print(str_c(col, get_primary_class(tbl[[col]]), sep=", "))
  plot_map <- c(
    "logical"   = plot_factor,
    "integer"   = plot_numeric,
    "numeric"   = plot_numeric,
    "factor"    = plot_factor,
    "character" = plot_character,
    "Date"      = plot_date,
    "POSIXct"   = plot_date,
    "POSIXlt"   = plot_date,
    "hms"       = plot_time
  )
  plot_map[[get_primary_class(tbl[[col]])]](tbl, col)
}


plot_numeric <- function (tbl, col) {
  ggplot(tbl) + geom_histogram(aes(tbl[[col]])) + xlab(col)
}


plot_factor <- function (tbl, col) {
  ggplot(tbl) +
    geom_bar(aes(tbl[[col]])) +
    xlab(col) +
    theme(axis.text.x = element_text(angle = 90, hjust = 1))
}


plot_character <- function (tbl, col) {
  n <- n_distinct(tbl[[col]])
  if (n <= 100) {
    plot_factor(tbl, col)
  } else {
    ggplot(tbl) +
      geom_bar(aes(sapply(tbl[[col]], function (v) { v == "" || is.na(v) }))) +
      xlab(paste(col, "is empty"))
  }
}


plot_date <- function(tbl, col) {
  ggplot(tbl) +
    geom_histogram(aes(as.POSIXct(tbl[[col]]))) +
    xlab(col) +
    theme(axis.text.x = element_text(angle = 90, hjust = 1))
}


plot_time <- function(tbl, col) {
  plot_date(tbl, col) +
    scale_x_datetime(date_breaks="2 hours", date_labels="%H:%M")
}
