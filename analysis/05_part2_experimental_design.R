###############################################################################
# Part 2: Student Performance observational 2 x 2 factorial extension.
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
log_step("Running Part 2 Student Performance factorial analysis")

part2_sections <- file.path(
  PROJECT_ROOT, "finals", "part2", "R",
  c(
    "01_data_audit_design.R",
    "02_descriptive_visualization.R",
    "03_factorial_anova.R",
    "04_diagnostics_posthoc.R",
    "05_interpretation_integration.R"
  )
)
missing_sections <- part2_sections[!file.exists(part2_sections)]
if (length(missing_sections)) {
  stop("Missing Part 2 section(s): ", paste(missing_sections, collapse = ", "),
       call. = FALSE)
}

for (section in part2_sections) {
  log_step("Part 2 module: ", basename(section))
  sys.source(section, envir = new.env(parent = globalenv()))
}

required_part2 <- c(
  file.path(paths$processed, "student_performance_clean.csv"),
  file.path(paths$tables, "tab_part2_anova.tex"),
  file.path(paths$figures, "fig_part2_diagnostics.pdf"),
  file.path(paths$models, "part2_anova.RData"),
  file.path(PROJECT_ROOT, "output", "part2_summary.RData")
)
missing_part2 <- required_part2[!file.exists(required_part2)]
if (length(missing_part2)) {
  stop(
    "Part 2 did not create required artifact(s): ",
    paste(missing_part2, collapse = ", "), call. = FALSE
  )
}

log_step("Part 2 analysis completed and integrated")
