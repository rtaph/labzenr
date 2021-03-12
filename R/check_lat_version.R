#' Check whether the user has pushed the latest version in his/her repository
#'
#' @return A logical which indicates whether the last pushed version is latest
#'   or not
#' @export
#' @examples
#' \dontrun{
#' check_lat_version()
#' }
check_lat_version <- function() {
    if (!gert::git_branch() %in% c("main", "master")) {
      usethis::ui_oops("Not on main/master branch. Skipping check \\
                      on upstream remote.")
      return(invisible(FALSE))
    }
    res <- purrr::safely(usethis:::check_branch_pushed)()
    if (is.null(res$error)) {
      usethis::ui_done("Remote has the latest commit")
      return(invisible(TRUE))
    } else {
      usethis::ui_oops("Remote does not have the latest commit")
      return(invisible(FALSE))
    }
}





