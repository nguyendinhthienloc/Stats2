###############################################################################
# Part 1 section 3: multicollinearity audit and feature-selection sensitivity.
###############################################################################

source_candidates <- c(file.path("R", "setup.R"), file.path("..", "R", "setup.R"))
script_arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
if (length(script_arg)) {
  script_file <- normalizePath(sub("^--file=", "", script_arg[[1L]]),
                               winslash = "/", mustWork = TRUE)
  source_candidates <- c(file.path(dirname(script_file), "..", "R", "setup.R"),
                         source_candidates)
}
source(source_candidates[file.exists(source_candidates)][[1L]])

log_step("Part 1 / Section 3: feature selection and OLS baseline")
sys.source(
  file.path(PROJECT_ROOT, "finals", "part1", "R", "03_p3_feature_selection.R"),
  envir = environment()
)
