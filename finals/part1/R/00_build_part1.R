###############################################################################
# File:        00_build_part1.R
# Owner:       ALL — reproducible R artifact builder
# Description: Run and validate the complete Part 1 analysis in R.
###############################################################################

setup_candidates <- c("setup.R", file.path("finals", "part1", "setup.R"),
                      file.path("..", "setup.R"))
source(setup_candidates[file.exists(setup_candidates)][1])

log_step("Building all Part 1 analysis artifacts")
source(file.path(PART1_ROOT, "R", "00_run_all.R"), local = new.env(parent = globalenv()))

required_artifacts <- c(
  file.path(OUTPUT_DIR, "shared_data.RData"),
  file.path(OUTPUT_DIR, "analysis_summary.RData"),
  file.path(OUTPUT_DIR, "model_lock.csv"),
  file.path(OUTPUT_DIR, "artifact_manifest.csv"),
  file.path(MODEL_DIR, "regularized_fits.RData"),
  file.path(MODEL_DIR, "holdout_summary.RData")
)
if (any(!file.exists(required_artifacts)) ||
    any(file.info(required_artifacts)$size <= 0)) {
  abort_run("One or more required R analysis artifacts are missing or empty")
}

log_step("Part 1 R content and analysis artifacts are complete")
log_info("Report content: report/Group08_WineQuality_Part1.Rmd")
log_info("Presentation content: presentation/Group08_WineQuality_Part1_Presentation.Rmd")
