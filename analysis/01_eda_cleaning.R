###############################################################################
# Part 1 sections 1-2: data preparation, EDA, and cleaning.
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

log_step("Part 1 / Section 1: reproducible data audit and locked split")
sys.source(
  file.path(PROJECT_ROOT, "finals", "part1", "R", "01_p1_data_prep.R"),
  envir = environment()
)
log_step("Part 1 / Section 2: training-only EDA and cleaning diagnostics")
sys.source(
  file.path(PROJECT_ROOT, "finals", "part1", "R", "02_p2_eda_cleaning.R"),
  envir = environment()
)
