## This battery of tests sequentially builds up a fake git repo in a temp
## directory. Many of these state-based tests are complicated and must be
## run in a particular order.

suppressMessages(library(gert))
library(testthat)


# set a temp directory as a git lab file
repo <- fs::path_temp("lab0")

# initiate directory as git repo
git_init(repo)

# copy a dummy lab file into it
notebook <- system.file("extdata", "badlab.Rmd", package = "labzenr")
fs::file_copy(notebook, repo, overwrite = TRUE)

# Remove the github link
lab <- fs::dir_ls(repo)[1]
txt <- readLines(lab)
txt[20] <- "> Insert github repo link here:"
writeLines(txt, lab)

# Add a first commit
git_add(basename(lab), repo = repo)
git_commit(
  message = "Initial lab",
  author = "Instructor <info@example.com>",
  repo = repo
)


# set the main/master branch name
main_branch <- git_branch_list(repo = repo)$name


# Test repo with no student commits
state <- "Emulated state: newly-cloned repo"
pattern <- "Student"
test_that("Checking function must return FALSE in a newly cloned repo", {
  expect_false(
    check_commits(pattern, repo = repo, branch = main_branch),
    info = state
  )
  expect_false(
    check_repo_link(lab),
    info = state
  )
  expect_false(
    check_lat_version(repo = repo),
    info = state
  )
})


state <- "Emulated state: first student commit added with link"
txt[20] <- paste0(
  "> The Github repo for this lab can be found at ",
  "[MDS-2021-22/DSCI_999_lab2_johnsmith]",
  "(https://github.ubc.ca/MDS-2020-21/",
  "DSCI_999_lab2_johnsmith)."
)
writeLines(txt, lab)
git_commit_all(
  message = "Add Github repo link",
  author = "Student <student@example.com>",
  repo = repo
)

test_that("Checks must return FALSE in a repo with fewer than 3 commits", {
  expect_false(
    check_commits(pattern, repo = repo, branch = main_branch),
    info = state
  )
  expect_true(
    check_repo_link(lab),
    info = state
  )
  expect_false(
    check_lat_version(repo = repo),
    info = state
  )
})

state <- "Emulated state: Second student commit added"
txt[35] <- "> Student solution"
writeLines(txt, lab)
git_commit_all(
  message = "Complete Exercise 1",
  author = "Student <student@example.com>",
  repo = repo
)
test_that("check_commits() must fail if 3 commits are not from the student", {
  expect_false(
    check_commits(pattern, repo = repo, branch = main_branch),
    info = state
  )
})


state <- "Emulated state: Third student commit added"
pattern <- "Student|Pupil"
txt[36] <- "> A longer answer."
writeLines(txt, lab)
git_commit_all(
  message = "Modify Exercise 1",
  author = "Pupil <student@example.com>",
  repo = repo
)
test_that("Regex must work if 3 commits are from the student", {
  expect_true(
    check_commits(pattern, fixed = FALSE, repo = repo, branch = main_branch),
    info = state
  )
  expect_false(
    check_commits("Student", fixed = TRUE, repo = repo, branch = main_branch),
    info = state
  )
})




test_that("Checking functions must return an invisible result", {
  expect_invisible(
    check_commits(pattern, repo = repo, branch = main_branch)
  )
  expect_invisible(
    check_repo_link(lab)
  )

  expect_invisible(
    check_lat_version(repo = repo)
  )

  expect_invisible(
    check_mechanics(
      notebook = lab, repo = repo,
      pattern = "Student", branch = main_branch
    )
  )
})




## SWITCH BRANCH
test_that("check_lat_version() must error if not on master/main branch", {
  withr::local_options(usethis.quiet = FALSE)

  git_branch_create("feature", repo = repo, checkout = TRUE)
  expect_message(
    check_lat_version(repo = repo),
    regexp = "Not on main/master branch"
  )

  git_branch_checkout(main_branch, repo = repo)
})


## CLONE LOCALLY
remote <- fs::path_temp("clonedrepo")
git_clone(repo, remote, verbose = FALSE)
test_that("check_lat_version() must work if upstream up to date", {
  withr::local_options(usethis.quiet = FALSE)
  expect_message(
    check_lat_version(repo = remote),
    regexp = "Remote has the latest commit"
  )
})


test_that("check_commits() must attempt a fetch if a remote exists", {
  withr::local_options(verbose = TRUE, usethis.quiet = TRUE)
  expect_message(
    check_commits(pattern, repo = remote, branch = main_branch),
    regexp = "Fetching"
  )
})


## MAKE A CHANGE IN CLONE
txt[36] <- "> An even longer answer."
lab2 <- fs::dir_ls(remote)
writeLines(txt, lab2)
git_commit_all(
  message = "Modify Exercise 1 again",
  author = "Student <student@example.com>",
  repo = remote
)
test_that("check_lat_version() must message if upstream not up to date", {
  withr::local_options(usethis.quiet = FALSE)
  expect_message(
    check_lat_version(repo = remote),
    regexp = "Remote does not have the latest commit"
  )
})
