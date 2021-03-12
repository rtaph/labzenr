# Units tests for count_points()

library(checkmate)

bad <- system.file("extdata", "badlab.Rmd", package = "labzenr")
py <- system.file("extdata", "dummylab.ipynb", package = "labzenr")
rmd <- system.file("extdata", "dummylab.Rmd", package = "labzenr")

test_that("count_points() must return a data frame", {
  tab1 <- count_points(rmd, margins = TRUE)
  tab2 <- count_points(rmd, margins = FALSE)
  types <- c("integer", "character", "double")
  expect_tibble(tab1,
    types = types, any.missing = FALSE,
    min.rows = 3, min.cols = 3
  )
  expect_tibble(tab2,
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
  types <- c("integer", "character", "double", "logical", "list")
  expect_tibble(dat1,
    types = types, any.missing = FALSE,
    min.cols = 7
  )
})
