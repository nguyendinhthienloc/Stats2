###############################################################################
# Canonical full-run entry point for the STAT452 Group 8 final project.
# Works with Rscript and with source("analysis/00_run_all.R") in RStudio.
###############################################################################

frame_sources <- vapply(sys.frames(), function(frame) {
  value <- frame$ofile
  if (is.null(value) || !length(value)) NA_character_ else as.character(value[[1L]])
}, character(1L))
runner_frames <- frame_sources[
  !is.na(frame_sources) &
    basename(frame_sources) == "00_run_all.R" &
    basename(dirname(frame_sources)) == "analysis"
]
script_arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
runner_file <- if (length(runner_frames)) {
  tail(runner_frames, 1L)
} else if (length(script_arg)) {
  sub("^--file=", "", script_arg[[1L]])
} else {
  file.path("analysis", "00_run_all.R")
}
if (!file.exists(runner_file) && file.exists(basename(runner_file))) {
  runner_file <- basename(runner_file)
}
runner_file <- normalizePath(runner_file, winslash = "/", mustWork = TRUE)
source(file.path(dirname(runner_file), "..", "R", "setup.R"))

stages <- c(
  "01_eda_cleaning.R",
  "02_feature_selection.R",
  "03_regularized_models.R",
  "04_holdout_evaluation.R",
  "05_part2_experimental_design.R"
)

stage_artifacts <- list(
  "01_eda_cleaning.R" = c(
    file.path(paths$processed, "shared_data.RData"),
    file.path(paths$tables, "tab_p1_data_audit.tex"),
    file.path(paths$figures, "fig_p2_quality_distribution.pdf")
  ),
  "02_feature_selection.R" = c(
    file.path(paths$models, "baseline_fits.RData"),
    file.path(paths$tables, "tab_p3_feature_screening.tex")
  ),
  "03_regularized_models.R" = c(
    file.path(paths$models, "regularized_fits.RData"),
    file.path(PROJECT_ROOT, "output", "model_lock.csv")
  ),
  "04_holdout_evaluation.R" = c(
    file.path(paths$models, "holdout_summary.RData"),
    file.path(PROJECT_ROOT, "output", "HOLDOUT_COMPLETE.txt")
  ),
  "05_part2_experimental_design.R" = character(0)
)

run_analysis_pipeline <- function() {
  original_directory <- getwd()
  on.exit(setwd(original_directory), add = TRUE)

  setwd(PROJECT_ROOT)
  ensure_dirs()
  log_step("Running the canonical final-project analysis pipeline")

  for (stage in stages) {
    log_step("Stage: ", stage)
    sys.source(
      file.path(PROJECT_ROOT, "analysis", stage),
      envir = new.env(parent = globalenv())
    )
    expected <- stage_artifacts[[stage]]
    missing <- expected[!file.exists(expected)]
    if (length(missing)) {
      stop(
        "Stage ", stage, " did not create required artifact(s): ",
        paste(missing, collapse = ", "),
        call. = FALSE
      )
    }
  }

  log_step("Writing software-version and artifact manifests")
  packages <- c("glmnet", "knitr", "rmarkdown")
  package_versions <- data.frame(
    Package = c("R", packages),
    Version = c(
      as.character(getRversion()),
      vapply(packages, function(package) {
        as.character(utils::packageVersion(package))
      }, character(1L))
    ),
    stringsAsFactors = FALSE
  )
  utils::write.csv(
    package_versions,
    file.path(paths$tables, "tab_reproducibility_versions.csv"),
    row.names = FALSE
  )
  save_table_tex(
    package_versions, "tab_reproducibility_versions.tex",
    caption = "Software versions used for the verified run.",
    label = "tab:reproducibility-versions", digits = 2L
  )

  table_stems <- c(
    "tab_p1_data_audit", "tab_p1_split_summary", "tab_p1_data_dictionary",
    "tab_p2_descriptive_statistics", "tab_p2_quality_frequency",
    "tab_p2_outlier_audit", "tab_p2_transformation_plan",
    "tab_p2_target_correlations", "tab_p3_feature_screening",
    "tab_p3_baseline_performance", "tab_p3_stepwise_sensitivity",
    "tab_p4_regularized_summary", "tab_p4_regularized_display",
    "tab_p4_enet_alpha_search", "tab_p4_coefficient_comparison",
    "tab_p4_lasso_selection", "tab_p4_model_lock",
    "tab_p5_holdout_performance", "tab_p5_holdout_display",
    "tab_p5_error_by_quality", "tab_reproducibility_versions"
  )
  figure_files <- c(
    "fig_p2_quality_distribution.pdf",
    "fig_p2_predictor_distributions.pdf",
    "fig_p2_correlation_heatmap.pdf",
    "fig_p2_pairwise_quality.pdf", "fig_p2_outlier_audit.pdf",
    "fig_p3_feature_screening.pdf", "fig_p4_cv_curves.pdf",
    "fig_p4_coefficient_paths.pdf", "fig_p4_coefficient_comparison.pdf",
    "fig_p5_actual_vs_predicted.pdf",
    "fig_p5_locked_residual_diagnostics.pdf"
  )
  artifact_paths <- c(
    file.path(paths$processed,
              c("shared_data.RData", "training_data.csv",
                "holdout_predictors_no_outcome.csv", "split_manifest.csv")),
    file.path(paths$figures, figure_files),
    file.path(paths$tables,
              as.vector(outer(table_stems, c(".csv", ".tex"), paste0))),
    file.path(paths$models,
              c("baseline_fits.RData", "regularized_fits.RData",
                "holdout_summary.RData")),
    file.path(paths$logs, "session_info.txt"),
    file.path(PROJECT_ROOT, "output",
              c("model_lock.csv", "model_lock.txt",
                "HOLDOUT_COMPLETE.txt", "analysis_summary.RData"))
  )
  artifact_paths <- unique(artifact_paths[file.exists(artifact_paths)])
  normalized_paths <- normalizePath(artifact_paths, winslash = "/",
                                    mustWork = TRUE)
  project_prefix <- paste0(PROJECT_ROOT, "/")
  relative_paths <- ifelse(
    startsWith(normalized_paths, project_prefix),
    substring(normalized_paths, nchar(project_prefix) + 1L),
    normalized_paths
  )
  manifest <- data.frame(
    File = relative_paths,
    Bytes = as.numeric(file.info(artifact_paths)$size),
    MD5 = unname(tools::md5sum(artifact_paths)),
    stringsAsFactors = FALSE
  )
  manifest <- manifest[order(manifest$File), , drop = FALSE]
  utils::write.csv(
    manifest, file.path(PROJECT_ROOT, "output", "artifact_manifest.csv"),
    row.names = FALSE
  )

  sys.source(
    file.path(PROJECT_ROOT, "scripts", "validate_outputs.R"),
    envir = new.env(parent = globalenv())
  )
  log_step("Part 1 completed and validated; Part 2 remains a documented scaffold")
  invisible(stage_artifacts)
}

run_analysis_pipeline()
