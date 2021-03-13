# Units tests for count_points()

# check the file extension is either Rmd or ipynb
test_that("The file extension should be either Rmd or ipynb", {
  file_csv <- "extdata/dummylab.csv"
  file_txt <- "extdata/dummylab.txt"

  expect_error(parse_lab(file_csv))
  expect_error(parse_lab(file_txt))
})

# check the return datatype is boolean
test_that("The function output  should be boolean", {
  # Set paths to dummy lab files
  py_file <- system.file("extdata", "dummylab.ipynb", package = "labzenr")
  r_file <- system.file("extdata", "dummylab.Rmd", package = "labzenr")

  expect_equal(check_repo_link(r_file), TRUE)
  expect_equal(check_repo_link(py_file), FALSE)
})
