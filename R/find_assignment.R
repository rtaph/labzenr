#' Find a UBC MDS Lab Assignment
#'
#' A helper function to validate and locate the a lab file based on its
#' extension being Rmd ipynb. The utility will search recursively up the
#' directory. If multiple candidate files are found, the user will be prompted
#' to select which file they wish.
#'
#'
#' @param notebook A character string specifying the path to the lab. If left
#'   blank, labzenr will attempt to find the lab in the current directory
#'   recursively.
#' @return The relative filepath to the lab found. Returns NULL if none found.
#' @importFrom usethis ui_path ui_stop ui_done ui_info ui_field ui_warn
#' @export
#'
#' @examples
#' \dontrun{
#' # Navigate to a UBC-MDS lab repo and type
#' find_assignment()
#' }
find_assignment <- function(notebook = NULL) {
  if (is.null(notebook)) {
    # list all candidate files
    files <- fs::dir_ls(regexp = ".*\\.(Rmd|ipynb)$", recurse = TRUE)

    if (length(files) == 1) {
      ui_info("Using {ui_field(files)}")
      return(files)
    } else if (length(files) > 1) {
      if (rlang::is_interactive()) {
        # menu() selection only works in interactive mode
        prompt <- "Multiple potential assignments found. Please select:"
        choice <- utils::menu(files, title = prompt)
        return(files[choice])
      } else {
        # use regex to attempt to select the most likely desired match
        files <- sort(files, decreasing = TRUE)
        i <- grep("lab\\d+\\.(Rmd|ipynb)$", files)
        files <- unique(c(files[i], files))
        ui_warn("Multiple possible files found: {ui_path(files)}")
        ui_info("Using {ui_field(files[1])}")
        return(files[1])
      }
    } else {
      ui_stop("Could not find an assignment file. Are you \\
               in the right directory?")
    }
  } else {
    if (fs::file_exists(notebook)) {
      return(notebook)
    } else {
      rlang::abort(glue::glue("Could not find file {ui_path(notebook)}"))
    }
  }
}
