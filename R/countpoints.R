#' Summarize Available Points in Lab by Section
#'
#'
#' @param margins A scalar logical which indicates whether to add a row for the
#'   total number of points. Defaults to TRUE.
#' @inheritParams parse_lab
#'
#'
#' @return A dataframe indicating total optional and required number of points.
#' @export
#'
#' @examples
#' # R markdown
#' notebook <- system.file("extdata", "dummylab.Rmd", package = "labzenr")
#' extract_points(notebook)
#'
#' # Python notebook
#' notebook <- system.file("extdata", "dummylab.ipynb", package = "labzenr")
#' extract_points(notebook)
extract_points <- function(notebook, margins = TRUE) {
  # Read-in notebook
  nb <- parse_lab(notebook)

  # # tidy the data
  dat <- tibble::tibble(line = seq_along(nb), text = nb)
  dat <- tidyr::separate_rows(dat, text, sep = "<hr>")
  dat <- tidyr::separate_rows(dat, text, sep = "<br>")
  dat <- tidyr::separate_rows(dat, text, sep = "\n")
  dat$text <- stringi::stri_trim_both(dat$text)
  dat <- dat[dat$text != "", ]

  dat$header <- dplyr::lag(dat$text)
  dat$is_rubric <- grepl("^rubric\\=\\{", dat$text)
  dat$below_header <- grepl("^#{1,6}\\s+", dat$header)
  dat$optional <- grepl("optional|bonus", dat$header, ignore.case = TRUE)
  dat <- dat[dat$is_rubric, ]
  pts <- stringi::stri_extract_all(dat$text, regex = "\\d+")
  dat$pts <- purrr::map(pts, as.integer)
  dat$total <- vapply(dat$pts, sum, 1L)

  # determine point worth
  one_pt_worth <- 0.95 / sum(dat$total[!dat$optional])
  dat$prop <- dat$total * one_pt_worth

  # defensive check
  if (!all(dat$below_header)) {
    rlang::abort("All rubrics should be below a markdown header. Aborting.")
  }
  if (any(is.na(dat$pts))) {
    rlang::abort("No rubric should be missing points. Aborting.")
  }

  # tidy up columns
  dat$header <- gsub("^#{1,6}\\s+", "", dat$header)
  dat$rubric <- gsub("^rubric\\=", "", dat$text, ignore.case = TRUE)
  dat <- dat[, c(
    "line", "rubric", "header", "optional", "pts",
    "total", "prop"
  )]
  dat
}

#' Tally Available Points in Lab
#'
#'
#' @inheritParams extract_points
#' @inheritParams parse_lab
#'
#' @importFrom dplyr group_by if_else filter summarise mutate across
#'
#' @return A dataframe indicating total optional and required number of points.
#' @export
#'
#' @examples
#' # R markdown
#' notebook <- system.file("extdata", "dummylab.Rmd", package = "labzenr")
#' count_points(notebook)
#'
#' # Python notebook
#' notebook <- system.file("extdata", "dummylab.ipynb", package = "labzenr")
#' count_points(notebook)
count_points <- function(notebook, margins = TRUE) {
  dat <- extract_points(notebook, margins = margins)
  tab <- dat %>%
    mutate(type = if_else(dat$optional, "Optional", "Non-Optional")) %>%
    group_by(type) %>%
    summarise(across(c(total, prop), sum), .groups = "drop")

  if (margins) {
    tab <- janitor::adorn_totals(tab, "row")
  }

  tab
}
