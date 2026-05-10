# install_packages.R
# Run once before knitting the final report or EDA notebook.

packages <- c(
  "tidyverse",
  "ggplot2",
  "dplyr",
  "readr",
  "tidyr",
  "purrr",
  "stringr",
  "forcats",
  "rmarkdown",
  "knitr",
  "tinytex",
  "tidymodels",
  "glmnet",
  "ranger",
  "vip",
  "yardstick",
  "scales",
  "corrplot",
  "patchwork",
  "rJava",
  "fingerprint",
  "rcdk"
)

install_if_missing <- function(pkgs) {
  for (p in pkgs) {
    if (!requireNamespace(p, quietly = TRUE)) {
      message(sprintf("Installing package: %s", p))
      install.packages(p, repos = "https://cloud.r-project.org")
    } else {
      message(sprintf("Package already installed: %s", p))
    }
  }
}

install_if_missing(packages)

if (requireNamespace("tinytex", quietly = TRUE) && !tinytex::is_tinytex()) {
  message(
    "For PDF knitting (final_report.Rmd): run tinytex::install_tinytex() once, ",
    "or install MacTeX / TeX Live if you already use LaTeX."
  )
}
