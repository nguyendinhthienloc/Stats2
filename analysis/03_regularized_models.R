###############################################################################
# Part 1 section 4: Ridge, Lasso, and Elastic Net on shared training folds.
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

log_step("Part 1 / Section 4: regularized models and pre-holdout lock")
sys.source(
  file.path(PROJECT_ROOT, "finals", "part1", "R",
            "04_p4_regularized_models.R"),
  envir = environment()
)
