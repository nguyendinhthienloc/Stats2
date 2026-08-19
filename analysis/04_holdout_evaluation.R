script_arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
script_file <- if (length(script_arg)) sub("^--file=", "", script_arg[[1L]]) else "analysis/04_holdout_evaluation.R"
source(file.path(dirname(normalizePath(script_file, winslash = "/", mustWork = TRUE)),
                 "..", "R", "setup.R"))

ensure_dirs()
log_step("Held-out evaluation scaffold is ready")

# TODO: this is the only script permitted to inspect held-out test outcomes.
