
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
check_repo_link <- function(notebook) {

}

#' Check whether the user has pushed the latest version in his/her repository
#'
#' @inheritParams parse_lab
#' @return A logical which indicates whether the last pushed version is latest
#'   or not
#'
#'
#' @examples
#' \dontrun{
#' check_lat_version()
#' }
check_lat_version <- function(notebook) {

}

#' Check whether the user has at least three commits
#' @inheritParams parse_lab
#' @return A logical which indicates whether the repo has 3 commits or not
#'
#'
#' @examples
#' \dontrun{
#' check_commits()
#' }
check_commits <- function(notebook) {

}

#' Performs Mechanics Checks on a MDS Lab This function check that you have a
#' Github repo link, that you have pushed your latest commit, and that you have
#' at least three commit messages authored by you in your history.
#'
#' @inheritParams parse_lab
#' @return The function prints the results of the mechanics checks to screen.
#'  Silently returns TRUE if all the checks are passed.
#' @export
#'
#' @examples
#' \dontrun{
#' check_mechanics()
#' }
check_mechanics <- function(notebook) {

}
