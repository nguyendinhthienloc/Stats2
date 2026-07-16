###############################################################################
# File:        00_run_all.R
# Description: Run the complete model pipeline with clear status logging.
###############################################################################

setup_file <- if (file.exists("R_models/setup.R")) "R_models/setup.R" else "setup.R"
source(setup_file)
ensure_dirs()

scripts <- c(
  "R_models/01_data_prep_eda.R",
  "R_models/02_ols.R",
  "R_models/02_ridge.R",
  "R_models/02_lasso.R",
  "R_models/04_enet.R",
  "R_models/04_neural.R",
  "R_models/02_comparison.R",
  "R_models/04_holdout.R"
)

rscript <- file.path(R.home("bin"), "Rscript.exe")
pipeline_start <- proc.time()[["elapsed"]]
log_step("Starting model pipeline with ", length(scripts), " scripts")

for (index in seq_along(scripts)) {
  script <- scripts[[index]]
  script_start <- proc.time()[["elapsed"]]
  log_step(sprintf("RUN %d/%d: %s", index, length(scripts), script))

  status <- system2(rscript, args = shQuote(script), stdout = "", stderr = "")
  elapsed <- proc.time()[["elapsed"]] - script_start

  if (!identical(status, 0L)) {
    abort_run(sprintf("FAILED %d/%d: %s (exit=%d, %.1fs)",
                      index, length(scripts), script, status, elapsed))
  }

  log_info(sprintf("DONE %d/%d: %s (%.1fs)",
                   index, length(scripts), script, elapsed))
}

total_elapsed <- proc.time()[["elapsed"]] - pipeline_start
capture.output(sessionInfo(), file = "output/session_info.txt")
log_info("Saved reproducibility record: output/session_info.txt")
log_step(sprintf("Pipeline complete: %d/%d scripts succeeded (%.1fs)",
                 length(scripts), length(scripts), total_elapsed))
