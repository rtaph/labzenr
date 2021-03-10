#' Parse MDS lab files to return the markdown content
#'
#' @param notebook A character indicating the path or list of paths to MDS lab
#'   files (either.ipynb or .Rmd). If left blank, the function will recursively
#'   search for all labs in the working directory based on the file extension.
#'
#' @return A character vector where each element is the content of one markdown
#'   cell.
#' @export
#'
#' @examples
#' # R markdown
#' notebook <- system.file("extdata", "dummylab.Rmd", package = "labzenr")
#' parse_lab(notebook)
#'
#' # Python notebook
#' notebook <- system.file("extdata", "dummylab.ipynb", package = "labzenr")
#' parse_lab(notebook)
parse_lab <- function(notebook = NULL) {
}
