library(tidyverse)


setClass(
  "Pipeline",
  representation(
    data = "tbl_df",
    metadata = "tbl_df"
  ),
  prototype(
    data = tibble(),
    metadata = tribble(
      ~action,
      ~reason,
      ~result,
      ~details,
      ~nrows,
      ~prop,
      ~prop_prev
    )
  )
)


setGeneric(
  "add_decision",
  function(
    pipeline,
    action,
    reason,
    result,
    details = list()
  ) {
    standardGeneric("add_decision")
  }
)


setGeneric("init", function(pipeline, data) { standardGeneric("init") }) 


setMethod(
  "add_decision",
  signature("Pipeline"),
  function(
    pipeline,
    action,
    reason,
    result,
    details = list()
  ) {

    nrows <- nrow(pipeline@data)
    prop <- 1
    prop_prev <- 1
    n <- nrow(pipeline@metadata)
    if (n > 1) {
      prop <- nrows / (slice(pipeline@metadata, 1) %>% pull(nrows))
      prop_prev <- nrows / (slice(pipeline@metadata, n) %>% pull(nrows))
    }

    # NOTE: add_row doesn't work with list entries; it only takes the last key
    pipeline@metadata %<>%
      bind_rows(tribble(
        ~action, ~reason, ~result, ~details, ~nrows, ~prop, ~prop_prev,
        action, reason, result, details, nrows, prop, prop_prev
      ))

    pipeline
  }
)


setMethod(
  "init",
  signature("Pipeline"),
  function(pipeline, data) {
    pipeline@data <- data
    add_decision(pipeline, "initialize", "none", "no change")
  }
)


# Example
# p <- init(new("Pipeline"), as_tibble(iris))
# p@data <- select(p@data, -Species)
# p <-
#   add_decision(
#     p,
#     "remove Species",
#     "because that feature is poorly recorded",
#     "resulting in 1 fewer predictor",
#     list(
#       remaining_columns = colnames(p@data),
#       dropped_column = "Species",
#       other = "for fun"
#     )
#   )
# library(knitr)
# library(kableExtra)
# kable(p@metadata, "latex") %>% column_spec(1:4, width = "10em")
