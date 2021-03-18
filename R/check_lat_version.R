#' Check whether the user has pushed the latest version in his/her repository
#'
#' @param repo A character path specifying the repo to check.
#' @return A logical which indicates whether the last pushed version is latest
#'   or not
#' @export
#' @examples
#' \dontrun{
#' check_lat_version()
#' }
check_lat_version <- function(repo = ".") {
  if (!gert::git_branch(repo = repo) %in% c("main", "master")) {
    usethis::ui_oops("Not on main/master branch. Skipping check \\
                      on upstream remote.")
    return(invisible(FALSE))
  }

  if (nrow(gert::git_remote_list(repo = repo)) == 0) {
    ui_oops("There is no remote set on this repository")
    return(invisible(FALSE))
  }

  check_push <- get("check_branch_pushed", envir = asNamespace("usethis"))

  withr::with_dir(
    repo,
    withr::with_message_sink(
      new = fs::file_temp(),
      withr::with_options(
        list(usethis.quiet = FALSE),
        res <- purrr::safely(check_push)()
      )
    )
  )

  # Test the error messages
  if (is.null(res$error)) {
    usethis::ui_done("Remote has the latest commit")
    return(invisible(TRUE))
  } else {
    usethis::ui_oops("Remote does not have the latest commit.
                     {res$error$message}")
    return(invisible(FALSE))
  }
}
