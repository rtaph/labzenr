#' List Known Git Signatures from the User Cache
#' @param repo A path to a github repository. Defaults to the working
#'    directory.
#' @return A tibble containing three columns:
#'    1. The the `signature` column contains character strings of the
#'    exact Git signatures (e.g. "John Smith <jsmith@example.com>") or
#'    regular expressions (e.g. "^John S(mith|\\.)").
#'
#'    2. The `is_user` column indicates whether the signature/pattern belongs
#'    to the student (FALSE would denote a Git user of MDS faculty).
#'
#'    3. The `is_regexp` column denotes if the signature column is a fixed
#'    literal or a regular expression.
#'
#' @export
#' @md
#'
#' @param repo A path to a github repository. Defaults to the working
#'    directory.
#'
#' @examples
#' # navigate to a Git repo and run:
#' signature_ls()
signature_ls <- function(repo = ".") {
  # set up the signatures cache file if necessary
  sigfile <- find_sigfile()

  # update the signatures
  if (rlang::is_interactive()) {
    signature_update(repo = repo)
  }

  # Read-in the known signatures
  dat <- readr::read_csv(sigfile, col_types = "cll")
  dat <- dplyr::distinct(dat)

  dat
}

#' Find Candidate Signatures (Internal Function)
#'
#' @inheritParams signature_update
#'
#' @return A logical indicating whether there are candidate Git signatures
#'   that are not in the labzenr signature cache.
#' @noRd
find_candidate_signatures <- function(repo = ".", max_commits = 100L) {
  repo <- git_find(repo)
  authors_in_log <- unique(git_log(repo = repo, max = max_commits)$author)

  sigs <- rlang::with_interactive(signature_ls(repo = repo), FALSE)
  sigs <- sigs[!sigs$is_regexp, , drop = FALSE]

  unrecognized <- setdiff(authors_in_log, sigs$signature)

  unrecognized
}



#' Interactively Update
#'
#'
#' This function is intended to be run interactively from within an R session.
#'
#' @param repo A path to a github repository. Defaults to the working
#'    directory.
#' @param max_commits An integer indicating the maximum commits to search in
#'   in the git log.
#' @return NULL
#'
#' @importFrom usethis ui_todo ui_code_block ui_value
#' @export
#'
#' @examples
#' \dontrun{
#' # navigate to a lab directory and run:
#' signature_update()
#' }
signature_update <- function(repo = ".", max_commits = 100L) {
  repo <- git_find(repo)
  unrecognized <- find_candidate_signatures(repo, max_commits)

  if (length(unrecognized) == 0L) {
    ui_done("No unrecognized Git signatures found. To add signatures \\
            manually, use {ui_code('labzenr::signature_add()')}.")
    ui_info("To see the list of currently registered signatures, run \\
            {ui_code('labzenr::signature_ls()')}.")
  } else if (rlang::is_interactive()) {
    for (sig in unrecognized) {
      type <- c("Student", "Instructor", "I don't know! (escape)")
      prompt <- glue::glue("{usethis::ui_value(sig)} is a")
      choice <- utils::menu(type, title = prompt)
      if (choice %in% c(1L, 2L)) {
        signature_add(sig, is_user = choice == 1L, is_regexp = FALSE)
      } else if (choice == 3L) {
        break()
      }
    }
  } else {
    ui_todo("{length(unrecognized)} unknown Git signatures found. In R, run:")
    ui_code_block("labzenr::signature_update(repo = '{getwd()}'")
  }
}


#' Add a Git Signature to the User Cache
#'
#' @param x A character string.
#' @param is_regexp A logical
#' @param is_user A logical.
#'
#' @return NULL
#' @export
#'
#' @examples
#' \dontrun{
#' # adds a regular expression that matches a student username pattern
#' signature_add("John S(\\.|mith)", is_regexp = TRUE, is_user = TRUE)
#' }
signature_add <- function(x, is_regexp = TRUE, is_user = TRUE) {
  sigfile <- find_sigfile()
  newrows <- tibble::tibble(
    signature = x,
    is_user = is_user,
    is_regexp = is_regexp
  )
  readr::write_csv(newrows, sigfile, append = TRUE)
}


#' Return a List of Known Student Signatures
#'
#' @inheritParams signature_update
#' @return A logical indicating whether there are candidate Git signatures
#'   that are not in the labzenr signature cache.
#' @export
signature_student <- function(repo = ".") {
  withr::local_dir(repo)
  sigs <- rlang::with_interactive(signature_ls(repo), FALSE)
  sigs <- sigs[sigs$is_user, , drop = FALSE]
  sigs
}




#' Ensure a Signature Config File Exists
#'
#' @return Silently returns true
#' @noRd
find_sigfile <- function() {

  # For development testing purposes
  filename <- getOption("labzenr.sigfile", "signatures.csv")

  # determine the location of the labzenr cache
  config_dir <- rappdirs::user_config_dir("labzenr")

  # Create config directory if none exists
  if (!fs::dir_exists(config_dir)) {
    fs::dir_create(config_dir)
  }

  # define the name of the signature cache file (sigfile)
  sigfile <- fs::path(config_dir, filename)

  # Create a sigfile if none exists
  if (!fs::file_exists(sigfile)) {
    sigs <- tibble::tibble(
      signature = character(0),
      is_user = logical(0),
      is_regexp = logical(0)
    )
    readr::write_csv(sigs, file = sigfile)
  } else {
    # check that the first row is a header
    header <- readr::read_lines(sigfile, n_max = 1L)
    if (header != "signature,is_user,is_regexp") {
      rlang::abort("The signature cache file lacks a header row")
    }
  }

  sigfile
}


#' Clear the labzen Cache of Known Git Signatures
#'
#' @return NULL
#' @importFrom usethis ui_yeah
#' @export
#'
#' @examples
#' \dontrun{
#' signatures_clear()
#' }
#'
signature_clear <- function() {
  sigfile <- find_sigfile()

  confirmed <- ui_yeah("Are you sure you want to delete your labzenr \\
                        cache of known Git signatures?")

  if (confirmed) {
    fs::file_delete(sigfile)
  }
}
