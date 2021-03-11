#' Tally Available Points in Lab
#'
#'
#' @param margins A scalar logical which indicates whether to add a row for the
#'   total number of points. Defaults to TRUE.
#' @inheritParams parse_lab
#'
#'
#' @return A dataframe indicating total optional and required number of points.
#' @export
#'
#' @examples
#' # R markdown
#' notebook <- system.file("extdata", "dummylab.Rmd", package = "labzenr")
#' count_points(notebook)
#'
#' # Python notebook
#' notebook <- system.file("extdata", "dummylab.ipynb", package = "labzenr")
#' count_points(notebook)
count_points <- function(notebook, margins = TRUE) {

}
