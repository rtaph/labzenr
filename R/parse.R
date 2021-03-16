#' Parse MDS lab files to return the markdown content
#'
#' @param notebook A character indicating the path or list of paths to MDS lab
#'   files (either.ipynb or .Rmd). If left blank, the function will recursively
#'   search for all labs in the working directory based on the file extension.
#'
#' @return A character vector where each element is the content of one markdown
#'   cell.
#'
#' @importFrom rlang %||%
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
  # find_assignment if the user did not define the notebook path
  notebook <- notebook %||% find_assignment()

  # Check whether the file path is string
  if (!inherits(notebook, "character")) {
    msg <- "Error. The file path should be string "
    stop(msg)
  }

  # Check if the file extension is
  if (getExtension(notebook) != "Rmd" &
    getExtension(notebook) != "ipynb") {
    msg <-
      "Error.the file extension should be either ipynb or Rmd"
    stop(msg)
  }


  # Extracting the file extension
  file_ext <- getExtension(notebook)

  # check whether the file is jupyter notebook or Rmarkdown
  if (file_ext == "ipynb") {
    # read jupyternotebook as a json file and parse markdown contents
    py_parse <- jsonlite::read_json(notebook)
    cells <- py_parse$cells
    source <- character()
    for (cell in cells) {
      if (cell$cell_type == "markdown") {
        cell_content <- unlist(cell$source, use.names = FALSE)
        cell_content <- paste0(cell_content, collapse = "\n")
        source[length(source) + 1] <- cell_content
      }
    }
  } else if (file_ext == "Rmd") {
    # read Rmarkdown file and parse markdown contents
    rmd_f <- readLines(notebook)
    cell_content <- paste0(rmd_f, collapse = "\n")
    splitted <-
      stringr::str_split(cell_content, "```", simplify = TRUE)
    code_bool <-
      startsWith(splitted, "{python") | startsWith(splitted, "{r")
    source <- splitted[!code_bool]
  }
  return(source)
}

# helper function for extracting the file extension
getExtension <- function(file) {
  ex <- strsplit(basename(file), split = "\\.")[[1]]
  return(ex[-1])
}
