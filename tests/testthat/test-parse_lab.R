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
