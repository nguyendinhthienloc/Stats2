script_arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
script_file <- if (length(script_arg)) sub("^--file=", "", script_arg[[1L]]) else "analysis/05_part2_experimental_design.R"
source(file.path(dirname(normalizePath(script_file, winslash = "/", mustWork = TRUE)),
                 "..", "R", "setup.R"))

ensure_dirs()
log_step("Part 2 experimental-design scaffold is ready")

# TODO: add the chosen dataset, hypotheses, ANOVA/factorial analysis, diagnostics,
# post-hoc analysis, practical interpretation, and limitations.
