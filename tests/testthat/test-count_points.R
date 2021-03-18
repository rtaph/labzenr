# Units tests for count_points()

bad <- system.file("extdata", "badlab.Rmd", package = "labzenr")
py <- system.file("extdata", "dummylab.ipynb", package = "labzenr")
rmd <- system.file("extdata", "dummylab.Rmd", package = "labzenr")

test_that("count_points() must return a data frame", {
  tab1 <- count_points(rmd, margins = TRUE)
  tab2 <- count_points(rmd, margins = FALSE)
  types <- c("integer", "factor", "double", "character")
  checkmate::expect_tibble(tab1,
    types = types, any.missing = FALSE,
    min.rows = 3, min.cols = 3
  )
  checkmate::expect_tibble(tab2,
    types = types, any.missing = FALSE,
    min.rows = 2, min.cols = 3
  )
})

test_that("count_points() must fail if no points in rubric", {
  msg <- "No rubric should be missing points"
  expect_error(count_points(bad), regexp = msg)
})

test_that("count_points() must return known outputs for dummy files", {
  tab1 <- count_points(rmd, margins = TRUE)
  tab2 <- count_points(rmd, margins = FALSE)
  expect_equal(tab1$total, c(14L, 6L, 20L))
  expect_equal(round(tab2$prop, 2), c(0.95, 0.41))
})

test_that("Required points must sum to 95%", {
  tab1 <- count_points(rmd, margins = TRUE)
  expect_equal(tab1[tab1$type == "Non-Optional", ]$prop, 0.95)
})

test_that("extract_points() must return a data frame", {
  dat1 <- extract_points(rmd)
  types <- c("integer", "factor", "double", "character", "list", "logical")
  checkmate::expect_tibble(dat1,
    types = types, any.missing = FALSE,
    min.cols = 7
  )
})

test_that("extract_points() must error if a bath filepath is given", {
  expect_error(
    extract_points("fakepath/fakefile.Rmd"),
    regexp = "Path to notebook does not exist"
  )
})

test_that("extract_points() must error if rubrics are not below headers", {

  # create a dummy file where the 69th line is not a markdown header
  txt <- readLines(rmd)
  txt[69] <- "Not a header"
  withr::with_file(list("bad.Rmd" = writeLines(txt, "bad.Rmd")), {
    expect_error(
      extract_points("bad.Rmd"),
      regexp = "All rubrics should be below a markdown header"
    )
  })
})
