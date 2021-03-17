#' Check whether the user has included the github repo link in his/her
#' repository
#'
#' @inheritParams parse_lab
#' @return A logical which indicates whether the repo link exists or not
#'
#'
#' @examples
#' \dontrun{
#' # Python notebook example should work as it DOES not have a link
#' notebook <- system.file("extdata", "dummylab.ipynb", package = "labzenr")
#' check_repo_link(notebook)
#'
#' # R markdown example should fail as it does NOT have a link
#' notebook <- system.file("extdata", "dummylab.Rmd", package = "labzenr")
#' check_repo_link(notebook)
#' }
check_repo_link <- function(notebook = NULL) {
  # parse lab using parse_lab function
  parsed_lab <- parse_lab(notebook)

  # regex for github link
  site <- "(https://)?(www.)?github\\.ubc\\.ca"
  regex <- paste0(site, "\\/MDS-\\d{4}-\\d{2}\\/DSCI_\\d{3}_lab\\d_[a-z]+")

  # Check whether each element contains the link
  link_ind <- stringr::str_detect(parsed_lab, regex)

  # Extract the link
  link_cell <- parsed_lab[link_ind]
  link <- stringr::str_extract(link_cell, regex)

  if (length(link) >= 1) {
    usethis::ui_done("You included the repo link {ui_field(link)}")
    return(invisible(TRUE))
  } else {
    usethis::ui_oops("No Github repo link found")
    return(invisible(FALSE))
  }
}


#' Performs Mechanics Checks on a MDS Lab This function check that you have a
#' Github repo link, that you have pushed your latest commit, and that you have
#' at least three commit messages authored by you in your history.
#'
#' @inheritParams parse_lab
#' @return The function prints the results of the mechanics checks to screen.
#'  Silently returns TRUE if all the checks are passed.
#' @importFrom rlang %||%
#' @export
#'
#' @examples
#' \dontrun{
#' check_mechanics()
#' }
check_mechanics <- function(notebook = NULL) {
  lab <- notebook %||% find_assignment()
  check_repo_link(lab) & check_lat_version() & check_commits()
}
