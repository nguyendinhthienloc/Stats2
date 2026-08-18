script_arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
script_file <- if (length(script_arg)) sub("^--file=", "", script_arg[[1L]]) else "analysis/03_regularized_models.R"
source(file.path(dirname(normalizePath(script_file, winslash = "/", mustWork = TRUE)),
                 "..", "R", "setup.R"))

ensure_dirs()
log_step("Regularized-model scaffold is ready")

# TODO: fit the baseline, Ridge, Lasso, and optional Elastic Net on shared folds.
