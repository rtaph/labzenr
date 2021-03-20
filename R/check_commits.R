#' Check whether the user has at least three commits
#'
#' @param repo A character path to the repo to check. Defaults to the working
#'   directory.
#' @param branch A string specifying the name of the default branch used for
#'   grading.
#' @return A logical which indicates whether the repo has 3 commits or not
#'
#' @import gert
#' @importFrom usethis ui_field ui_oops ui_done ui_code
#' @importFrom stringr str_detect
#' @importFrom purrr map_lgl
#' @importFrom stats setNames
#' @export
#' @examples
#' \dontrun{
#' # navigate to a Git directory for a lab, e.g.:
#' # set_wd("~/mds/lab5")
#' check_commits()
#' }
#'
check_commits <- function(repo = ".",
                          branch = usethis::git_branch_default()) {

  # Set repo path. Permissive of lab file paths.
  repo <- gert::git_find(repo)

  # fetching the repo from remote
  if (nrow(git_remote_list(repo = repo)) > 0L) {
    if (getOption("verbose", FALSE)) {
      rlang::inform("Fetching...")
    }
    git_fetch(verbose = rlang::is_interactive(), repo = repo)
  }

  # Update signatures
  if (rlang::is_interactive()) {
    signature_update(repo = repo)
  }
  sigs <- signature_student(repo = repo)
  sigs$type <- factor(if_else(sigs$is_regexp, "pattern", "literal"))
  levels(sigs$type) <- c("pattern", "literal")
  sigs <- split(sigs$signature, sigs$type)


  # check for matches
  commits <- gert::git_log(ref = branch, repo = repo)
  rex_matches <- map_lgl(commits$author, ~ any(str_detect(., sigs$pattern)))
  lit_matches <- commits$author %in% sigs$literal
  student_matches <- setNames(lit_matches | rex_matches, commits$author)

  user_commits <- sum(student_matches)

  if (user_commits >= 3) {
    usethis::ui_done("Repo has at least 3 commits with users \\
                      listed in {ui_code('labzenr::signature_student()')}")
  } else if (user_commits < 3 & user_commits >= 1) {
    usethis::ui_oops("Repo does not have 3 commits with users \\
                      listed in {ui_code('labzenr::signature_student()')}")
  } else {
    usethis::ui_oops("Repo has fewer than 3 commits")
  }
  return(invisible(user_commits >= 3))
}
