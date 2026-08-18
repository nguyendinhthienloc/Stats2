###############################################################################
# File:        00_run_all.R
# Owner:       ALL — integration runner
# Description: Execute the five Part 1 workstreams in dependency order.
###############################################################################

setup_candidates <- c("setup.R", file.path("finals", "part1", "setup.R"),
                      file.path("..", "setup.R"))
source(setup_candidates[file.exists(setup_candidates)][1])
ensure_dirs()

scripts <- c(
  "Exploratory Data Analysis" = "R/01_p1_data_prep.R",
  "Data Cleaning" = "R/02_p2_eda_cleaning.R",
  "Feature Selection" = "R/03_p3_feature_selection.R",
  "Modelling with Regularization" = "R/04_p4_regularized_models.R",
  "Evaluation" = "R/04_holdout.R"
)

log_path <- file.path(LOG_DIR, "part1_pipeline.log")
writeLines(
  c(
    "STAT452 Group 08 — Part 1 pipeline",
    paste("Started:", format(Sys.time(), tz = "UTC", usetz = TRUE)),
    paste("R:", as.character(getRversion())),
    paste("Working root:", PART1_ROOT),
    ""
  ),
  log_path
)

rscript <- file.path(R.home("bin"), if (.Platform$OS.type == "windows") {
  "Rscript.exe"
} else {
  "Rscript"
})

pipeline_start <- proc.time()[["elapsed"]]
log_step("Starting Part 1 pipeline with ", length(scripts), " workstreams")

for (i in seq_along(scripts)) {
  section <- names(scripts)[[i]]
  script <- unname(scripts[[i]])
  script_path <- file.path(PART1_ROOT, script)
  step_start <- proc.time()[["elapsed"]]
  log_step(sprintf("RUN %d/%d: %s [%s]", i, length(scripts), section, script))

  output <- suppressWarnings(system2(
    rscript, args = c("--vanilla", shQuote(script_path)),
    stdout = TRUE, stderr = TRUE
  ))
  status <- attr(output, "status")
  if (is.null(status)) status <- 0L
  cat(paste(output, collapse = "\n"), "\n")
  cat(
    sprintf("\n===== %d/%d %s =====\n", i, length(scripts), script),
    paste(output, collapse = "\n"), "\n",
    file = log_path, append = TRUE
  )

  elapsed <- proc.time()[["elapsed"]] - step_start
  if (!identical(as.integer(status), 0L)) {
    abort_run(sprintf("FAILED %d/%d: %s (exit=%d, %.1fs). See %s",
                      i, length(scripts), script, status, elapsed, log_path))
  }
  log_info(sprintf("DONE %d/%d: %s (%.1fs)",
                   i, length(scripts), script, elapsed))
}

total_elapsed <- proc.time()[["elapsed"]] - pipeline_start
cat(
  paste("Completed:", format(Sys.time(), tz = "UTC", usetz = TRUE)),
  sprintf("Elapsed seconds: %.1f", total_elapsed), "",
  file = log_path, append = TRUE, sep = "\n"
)

package_versions <- data.frame(
  Package = c("R", required_packages),
  Version = c(
    as.character(getRversion()),
    vapply(required_packages, function(name) {
      as.character(utils::packageVersion(name))
    }, character(1))
  ),
  stringsAsFactors = FALSE
)
save_table_artifacts(
  package_versions, "tab_reproducibility_versions",
  "Software versions used for the verified run.",
  "reproducibility-versions", digits = 2
)

log_step("Creating reproducibility manifest")
artifact_paths <- list.files(
  c(DATA_DIR, OUTPUT_DIR), recursive = TRUE, full.names = TRUE,
  include.dirs = FALSE
)
artifact_paths <- artifact_paths[file.info(artifact_paths)$isdir %in% FALSE]
manifest_path <- file.path(OUTPUT_DIR, "artifact_manifest.csv")
artifact_paths <- artifact_paths[
  normalizePath(artifact_paths, winslash = "/", mustWork = TRUE) !=
    normalizePath(manifest_path, winslash = "/", mustWork = FALSE)
]
manifest <- data.frame(
  File = sub(paste0("^", gsub("([\\.\\+\\(\\)\\[\\]\\{\\}\\^\\$\\|\\?\\*])", "\\\\\\1",
                             paste0(PART1_ROOT, "/"))), "",
             normalizePath(artifact_paths, winslash = "/", mustWork = TRUE)),
  Bytes = as.numeric(file.info(artifact_paths)$size),
  MD5 = unname(tools::md5sum(artifact_paths)),
  stringsAsFactors = FALSE
)
manifest <- manifest[order(manifest$File), ]
utils::write.csv(manifest, manifest_path, row.names = FALSE)

log_step(sprintf("Part 1 pipeline complete: %d/%d succeeded (%.1fs)",
                 length(scripts), length(scripts), total_elapsed))
