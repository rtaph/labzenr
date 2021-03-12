#' Check whether the user has at least three commits
#'
#' @param ... Arguments passed to `gert`, such as the `repo` name or `ref`.
#' @return A logical which indicates whether the repo has 3 commits or not
#' @import gert
#' @export
#' @examples
#' \dontrun{
#' myrepo <- "/Users/sukhdeepkaur/MDS/Block5/lab/DSCI_563_lab1_sukh2929"
#' check_commits(repo = myrepo)
#' check_commits()
#' }
#'
check_commits <- function(...) {

  # fetching git user full name and email
  signature <- gert::git_signature_default()
  usethis::ui_info("username: {usethis::ui_field(signature)}")

  # fetching the repo from remote
  git_fetch(verbose = interactive(), ...)

  # fetching commits for the remote repo
  commits <- gert::git_log(...)
  user_commits <- sum(commits$author == signature)

  if (user_commits >= 3) {
    usethis::ui_done("Repository has at least 3 commits with the student username")
  } else if (user_commits < 3 & user_commits >= 1) {
    usethis::ui_oops("Repository does not have 3 commits with the student username")
  } else {
    usethis::ui_oops("Repo has less than 3 commits")
  }
  return(invisible(user_commits >= 3))
}
