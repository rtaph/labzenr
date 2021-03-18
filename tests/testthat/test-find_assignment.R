options(usethis.quiet = TRUE)


test_that("find_assignment() must find the dummy lab", {
  notebook <- system.file("extdata", "dummylab.Rmd", package = "labzenr")
  fullpath <- find_assignment(notebook)
  expect_true(fs::is_file(fullpath))
})

test_that("find_assignment() must error if an invalid path is given", {
  fake <- "fakepath/fakelab.ipynd"
  expect_error(find_assignment(fake),
    regexp = "Could not find file"
  )
})

test_that("find_assignment() must messge if no file in the directory", {

  # set an empty temporary directory
  tmp <- withr::local_tempdir()
  withr::local_dir(tmp)

  expect_error(find_assignment(), regexp = "in the right directory?")
})

test_that("find_assignment() must find the dummy lab if no arguments passed", {

  # set temporary directory
  tmp <- withr::local_tempdir()
  withr::local_dir(tmp)

  # single file
  fs::file_touch("file1.Rmd")
  expect_true(fs::is_file(find_assignment()))

  # multiple files, interactive
  fs::file_touch("file2.Rmd")
  rlang::local_interactive()
  mockery::stub(find_assignment, "utils::menu", 1)
  expect_true(find_assignment() == "file1.Rmd")
  mockery::stub(find_assignment, "utils::menu", 2)
  expect_true(find_assignment() == "file2.Rmd")

  # multiple files, NOT interactive
  rlang::local_interactive(FALSE)
  expect_warning(find_assignment(), regexp = "Multiple possible files found")
})
