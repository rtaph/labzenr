test_that("Dummy test files must be readable", {
  # Set paths to dummy lab files
  py_file <- system.file("extdata", "dummylab.ipynb", package = "labzenr")
  r_file <- system.file("extdata", "dummylab.Rmd", package = "labzenr")

  # check they are accessible
  expect(fs::file_exists(py_file),
    failure_message = "dummylab.ipynb not found"
  )
  expect(fs::file_exists(py_file),
    failure_message = "dummylab.Rmd not found"
  )
})

test_that("The file path should be string", {
  expect_error(parse_lab(2))
})

# check the file extension is either Rmd or ipynb
test_that("The file extension should be either Rmd or ipynb", {
  file_csv <- "extdata/dummylab.csv"
  file_txt <- "extdata/dummylab.txt"

  expect_error(parse_lab(file_csv))
  expect_error(parse_lab(file_txt))
})

# check the file parsed correctly
test_that("Check the accuracy of function", {
  # Set paths to dummy lab files
  py_file <-
    system.file("extdata", "dummylab.ipynb", package = "labzenr")
  r_file <-
    system.file("extdata", "dummylab.Rmd", package = "labzenr")

  expect_equal(length(parse_lab(py_file)), 24)
  expect_equal(length(parse_lab(r_file)), 4)
})
