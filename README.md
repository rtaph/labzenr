
# labzenr

<!-- badges: start -->
[![Project Status: WIP – Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)
[![R-CMD-check](https://github.com/UBC-MDS/labzenr/workflows/R-CMD-check/badge.svg)](https://github.com/UBC-MDS/labzenr/actions)
[![Codecov test coverage](https://codecov.io/gh/UBC-MDS/labzenr/branch/master/graph/badge.svg)](https://codecov.io/gh/UBC-MDS/labzenr?branch=master)
<!-- badges: end -->

`labzenr` is a R package that adds more [zen](https://en.wikipedia.org/wiki/Zen) to the student experience of working on [UBC Master of Data Science](https://masterdatascience.ubc.ca/) labs. It lets students manage common tasks such as counting total marks in an assignment, and performs common mechanics checks for iPython notebooks and R markdown assignments.

The project is a port of python [labzen package](https://github.com/UBC-MDS/labzen) written by the same authors.

## Installation

You can install the released version of labzenr from [Github](https://github.com/UBC-MDS/labzenr) with:

``` r
install.packages("devtools")
devtools::install_github("UBC-MDS/labzenr")
```

## Usage

To check the mechanics of your MDS labs, navigate to the root of your MDS lab Git repository and run the following code. 

```r
labzenr::check_mechanics()
```
```
#> ℹ Using lab2.Rmd
#> ✓ You included the repo link https://github.ubc.ca/MDS-2020-21/DSCI_998_lab1_johnsmith
#> ✓ Remote has the latest commit
#> Trying to authenticate 'git' using ssh-agent...
#> ✓ No unrecognized Git signatures found. To add signatures manually, use `labzenr::signature_add()`.
#> ℹ To see the list of currently registered signatures, run `labzenr::signature_ls()`.
#> ✓ Repo has at least 3 commits with users listed in `labzenr::signature_student()`
```

The printout shows that:

- you have successfully included a Github repo link;
- you have pushed the latest version to Github Enterprise; and
- you have at least three student commits.

You can also get an overview of the number of points attainable in the lab by running:

```r
labzenr::count_points()
```
|type         | total|      prop|
|:------------|-----:|---------:|
|Non-Optional |    14| 0.9500000|
|Optional     |     6| 0.4071429|
|Total        |    20| 1.3571429|

For a full introduction to all the features, please see the [introductory vignette](https://ubc-mds.github.io/labzenr/articles/intro-to-labzenr.html).


## Dependencies

- fs
- stringi
- usethis
- gert
- magrittr
- janitor
- dplyr
- tibble
- tidyr
- jsonlite
- stringr
- rlang
- purrr
- glue
- withr
- readr
- rappdirs


## Code of Conduct

Please note that the labzenr project is released with a [Contributor Code of Conduct](https://contributor-covenant.org/version/2/0/CODE_OF_CONDUCT.html). By contributing to this project, you agree to abide by its terms.

## Contributors

This package is authored by Sukhdeep Kaur, Kamal Moravej Jahromi, and Rafael Pilliard-Hellwig as part of an academic assignment in the UBC MDS program. For a full list of contributors, please see the [contributors tab](https://github.com/UBC-MDS/labzen/graphs/contributors).

We warmly welcome and recognize contributions from the community at large. If you wish to participate, please review our [contributing guidelines](CONTRIBUTING.rst) and familiarize yourself with [Github Flow](https://blog.programster.org/git-workflows).
