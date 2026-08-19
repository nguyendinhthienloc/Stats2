script_arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
script_file <- normalizePath(sub("^--file=", "", script_arg[[1L]]),
                             winslash = "/", mustWork = TRUE)
source(file.path(dirname(script_file), "..", "R", "setup.R"))

stages <- c(
  "01_eda_cleaning.R",
  "02_feature_selection.R",
  "03_regularized_models.R",
  "04_holdout_evaluation.R",
  "05_part2_experimental_design.R"
)

log_step("Running the final-project analysis pipeline")
for (stage in stages) {
  log_step("Stage: ", stage)
  sys.source(file.path(PROJECT_ROOT, "analysis", stage), envir = new.env())
}
log_step("Analysis pipeline completed")
