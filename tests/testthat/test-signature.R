
suppressMessages(library(gert))
library(testthat)
options(usethis.quiet = TRUE)

# helper function to delete files
trydelete <- purrr::possibly(fs::file_delete, NULL)

# set up devfile for test
config_dir <- rappdirs::user_config_dir("labzen")
devfile <- fs::path(config_dir, "dev.csv")

# set a temp directory as a git lab file
repo <- fs::path_temp("lab2")

# initiate directory as git repo
trydelete(fs::path(repo, ".git"))
git_init(repo)

# set local config
gert::git_config_set("user.name", "Garfield", repo = repo)
gert::git_config_set("user.email", "garfield@email.com", repo = repo)

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
  author = "Dr. Dolittle <info@example.com>",
  repo = repo
)

test_that("Cache file must exist after call to signature_ls()", {
  withr::local_options(list(labzenr.sigfile = "dev.csv"))
  rlang::local_interactive(FALSE)

  # delete the dev config file, if it exists
  trydelete(devfile)

  # dev config file must exist after calling signature_ls()
  dat <- signature_ls()
  checkmate::expect_file_exists(devfile,
    access = "w",
    extension = "csv"
  )
})

test_that("find_sigfile() must error if sigfile csv has no headers", {
  withr::local_options(list(labzenr.sigfile = "dev.csv"))

  # overwrite the headers
  writeLines("", devfile)
  expect_error(
    find_sigfile(),
    regexp = "The signature cache file lacks a header row"
  )
  trydelete(devfile)
})

test_that("signature_ls() must return a tibble", {
  withr::local_options(list(labzenr.sigfile = "dev.csv"))
  checkmate::expect_tibble(signature_ls())
})


test_that("signature_ls() must return a tibble", {
  withr::local_options(list(labzenr.sigfile = "dev.csv"))
  checkmate::expect_tibble(signature_ls())
})


test_that("signature_add() must add an item to the cache", {
  withr::local_options(list(labzenr.sigfile = "dev.csv"))

  # add a user
  signature_add("Jane Doe", is_user = TRUE)
  tab <- signature_student()
  checkmate::expect_tibble(tab, nrows = 1, ncols = 3)
})




test_that("signature_ls() must return a tibble with one student", {
  withr::local_options(list(labzenr.sigfile = "dev.csv"))
  withr::local_dir(repo)
  rlang::local_interactive()
  mockery::stub(signature_update, "utils::menu", 2)

  signature_update(repo = repo)

  rlang::local_interactive(FALSE)
  tab <- signature_ls()
  checkmate::expect_tibble(tab, nrows = 2)
  expect_equal(tab$is_user, c(TRUE, FALSE))
})

test_that("signature_update() must message when there are no updates", {
  withr::local_options(list(
    labzenr.sigfile = "dev.csv",
    usethis.quiet = FALSE
  ))
  withr::local_dir(repo)
  res <- purrr::quietly(signature_update)()
  msg1 <- "No unrecognized Git signatures"
  msg2 <- "To see the list of currently registered signatures"
  expect_true(grepl(msg1, res$messages[1]))
  expect_true(grepl(msg2, res$messages[2]))
})


# add a commit
txt[35] <- "> An answer to a question."
writeLines(txt, lab)
git_add(basename(lab), repo = repo)
git_commit(
  message = "Make a small change",
  author = "Stuart Little <slitte@example.com>",
  repo = repo
)
test_that("signature_update() must message in non-interactive mode if \\
           candidates found", {
  withr::local_options(list(
    labzenr.sigfile = "dev.csv",
    usethis.quiet = FALSE
  ))
  withr::local_dir(repo)
  rlang::local_interactive(FALSE)

  res <- purrr::quietly(signature_update)()
  msg1 <- "unknown Git signatures found"
  msg2 <- "labzenr::signature_update\\(repo"
  expect_true(grepl(msg1, res$messages[1]))
  expect_true(grepl(msg2, res$messages[2]))
})






test_that("signature_clear() must return a tibble with 0 rows", {
  withr::local_options(list(labzenr.sigfile = "dev.csv"))

  # clear the cache
  rlang::local_interactive()
  mockery::stub(signature_clear, "ui_yeah", TRUE)
  signature_clear()

  # re-initialize the cache
  rlang::local_interactive(FALSE)
  checkmate::expect_tibble(signature_ls(), nrows = 0)
})

# cleanup
trydelete(devfile)
