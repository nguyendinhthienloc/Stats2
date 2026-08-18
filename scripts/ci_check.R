script_arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
script_file <- normalizePath(sub("^--file=", "", script_arg[[1L]]),
                             winslash = "/", mustWork = TRUE)
source(file.path(dirname(script_file), "..", "R", "setup.R"))

log_step("Checking required repository structure")
required_paths <- c(
  "TODO.md",
  "README.md",
  "DESCRIPTION",
  "renv.lock",
  "analysis/00_run_all.R",
  "analysis/04_holdout_evaluation.R",
  "report/final-report.Rmd",
  ".github/workflows/ci.yml",
  ".github/workflows/release.yml",
  "data/raw/source/wine-quality.zip",
  "data/raw/wine_quality/winequality-red.csv"
)
missing_paths <- required_paths[!file.exists(file.path(PROJECT_ROOT, required_paths))]
if (length(missing_paths)) {
  stop("Missing required paths: ", paste(missing_paths, collapse = ", "),
       call. = FALSE)
}

log_step("Validating the supplied red-wine dataset")
wine <- read_wine_red()
expected_columns <- c(
  "fixed acidity", "volatile acidity", "citric acid", "residual sugar",
  "chlorides", "free sulfur dioxide", "total sulfur dioxide", "density",
  "pH", "sulphates", "alcohol", "quality"
)
stopifnot(
  nrow(wine) == 1599L,
  ncol(wine) == 12L,
  identical(names(wine), expected_columns),
  all(vapply(wine, is.numeric, logical(1))),
  !anyNA(wine),
  all(wine$quality >= 0 & wine$quality <= 10)
)

log_step("Parsing active R source files")
r_files <- c(
  list.files(file.path(PROJECT_ROOT, "R"), pattern = "[.]R$",
             recursive = TRUE, full.names = TRUE),
  list.files(file.path(PROJECT_ROOT, "analysis"), pattern = "[.]R$",
             recursive = TRUE, full.names = TRUE),
  list.files(file.path(PROJECT_ROOT, "scripts"), pattern = "[.]R$",
             recursive = TRUE, full.names = TRUE)
)
invisible(lapply(r_files, parse, keep.source = TRUE))

log_step("Checking active files for machine-specific project paths")
text_files <- c(r_files,
                file.path(PROJECT_ROOT, c("README.md", "TODO.md", "Makefile")))
hardcoded <- vapply(text_files, function(path) {
  any(grepl("[A-Za-z]:[/\\\\]Stats2", readLines(path, warn = FALSE),
            ignore.case = TRUE))
}, logical(1))
if (any(hardcoded)) {
  stop("Machine-specific project path found in: ",
       paste(text_files[hardcoded], collapse = ", "), call. = FALSE)
}

log_step("All repository checks passed")
