#' Find a UBC MDS Lab Assignment
#'
#' A helper function to locate the a lab file based on its extension being Rmd
#' ipynb. The utility will search recursively up the directory. If multiple
#' candidate files are found, the user will be prompted to select which file
#' they wish.
#'
#'
#' @return The relative filepath to the lab found. Returns NULL if none found.
#' @export
#'
#' @examples
#' # Navigate to a UBC lab repo and type
#' find_assignment()
find_assignment <- function() {

  # list all candidate files
  files <- fs::dir_ls(regexp = ".*\\.(Rmd|ipynb)$", recurse = TRUE)

  if (length(files) == 1) {
    ui_done("Found {ui_field(files)}")
    return(files)
  } else if (length(files) > 1) {
    prompt <- "Multiple potential assignments found. Please select:"
    choice <- utils::menu(files, title = prompt)
    return(files[choice])
  } else {
    ui_stop("Could not find an assignment file. Are you sure you are in the \\
            right directory?")
  }
}
