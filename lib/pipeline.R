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
      ~proportion
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
    proportion <- 1
    if (nrow(pipeline@metadata) > 1)
      proportion <- nrows / (slice(pipeline@metadata, 1) %>% pull(nrows))

    pipeline@metadata %<>%
      bind_rows(tribble(
        ~action, ~reason, ~result, ~details, ~nrows, ~proportion,
        action, reason, result, details, nrows, proportion
      ))

    pipeline
  }
)


# Example
# p <- new("Pipeline", data = as_tibble(iris))
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
