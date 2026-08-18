script_arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
script_file <- if (length(script_arg)) sub("^--file=", "", script_arg[[1L]]) else "analysis/02_feature_selection.R"
source(file.path(dirname(normalizePath(script_file, winslash = "/", mustWork = TRUE)),
                 "..", "R", "setup.R"))

ensure_dirs()
log_step("Feature-selection scaffold is ready")

# TODO: implement principled feature selection using training/resampling data only.
