#' Check whether the user has at least three commits
#'
#' @param pattern A character string indicating the a regular string (or
#'   character string for `fixed = TRUE`) to be matched in the commit author
#'   field.
#' @param fixed A logical indicating whether the pattern should be matched as
#'   a literal (if TRUE) or a regular expression (if FALSE). Defaults to TRUE.
#' @param repo A character path to the repo to check. Defaults to the working
#'   directory.
#' @param branch A string specifying the name of the default branch used for
#'   grading.
#' @param ... Additional arguments passed to `grepl()`.
#' @return A logical which indicates whether the repo has 3 commits or not
#'
#' @import gert
#' @importFrom usethis ui_field ui_oops ui_done ui_code
#' @export
#' @examples
#' \dontrun{
#' # navigate to a Git directory for a lab, e.g.:
#' # set_wd("~/mds/lab5")
#' check_commits()
#' }
#'
check_commits <- function(pattern = NULL, fixed = TRUE, repo = ".",
                          branch = usethis::git_branch_default(), ...) {

  # Set repo path. Permissive of lab file paths.
  repo <- gert::git_find(repo)

  # fetching the repo from remote
  if (nrow(git_remote_list(repo = repo)) > 0L) {
    if (getOption("verbose", FALSE)) {
      rlang::inform("Fetching...")
    }
    git_fetch(verbose = rlang::is_interactive(), repo = repo)
  }

  # fetching git user full name and email
  signature <- pattern %||% gert::git_signature_default(repo = repo)
  usethis::ui_info("Checking commit author: {ui_code(signature)} \\
                    on branch {usethis::ui_field(branch)}")

  # fetching commits for the remote repo
  commits <- gert::git_log(ref = branch, repo = repo)
  user_commits <- sum(grepl(signature, commits$author, fixed = fixed, ...))

  if (user_commits >= 3) {
    usethis::ui_done("Repo has at least 3 commits with the user \\
                      signature {ui_field(signature)}")
  } else if (user_commits < 3 & user_commits >= 1) {
    usethis::ui_oops("Repo does not have 3 commits with the user \\
                      signature {ui_field(signature)}")
  } else {
    usethis::ui_oops("Repo has fewer than 3 commits")
  }
  return(invisible(user_commits >= 3))
}
