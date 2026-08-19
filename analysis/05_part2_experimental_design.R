###############################################################################
# Part 2: experimental-design extension.
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

ensure_dirs()
log_step("Part 2 scaffold reached; analysis is intentionally still pending")

# TODO: add the chosen dataset, hypotheses, ANOVA/factorial analysis, diagnostics,
# post-hoc analysis, practical interpretation, and limitations.
