###############################################################################
# Validate the generated Part 1 interface after the canonical pipeline runs.
###############################################################################

frame_sources <- vapply(sys.frames(), function(frame) {
  value <- frame$ofile
  if (is.null(value) || !length(value)) NA_character_ else as.character(value[[1L]])
}, character(1L))
script_frames <- frame_sources[
  !is.na(frame_sources) &
    basename(frame_sources) == "validate_outputs.R" &
    basename(dirname(frame_sources)) == "scripts"
]
script_arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
script_file <- if (length(script_frames)) {
  tail(script_frames, 1L)
} else if (length(script_arg)) {
  sub("^--file=", "", script_arg[[1L]])
} else {
  file.path("scripts", "validate_outputs.R")
}
if (!file.exists(script_file) && file.exists(basename(script_file))) {
  script_file <- basename(script_file)
}
script_file <- normalizePath(script_file, winslash = "/", mustWork = TRUE)
source(file.path(dirname(script_file), "..", "R", "setup.R"))

log_step("Validating generated Part 1 artifacts")
required <- c(
  file.path(paths$processed, "shared_data.RData"),
  file.path(paths$processed, "training_data.csv"),
  file.path(paths$processed, "holdout_predictors_no_outcome.csv"),
  file.path(paths$models, "baseline_fits.RData"),
  file.path(paths$models, "regularized_fits.RData"),
  file.path(paths$models, "holdout_summary.RData"),
  file.path(PROJECT_ROOT, "output", "model_lock.csv"),
  file.path(PROJECT_ROOT, "output", "analysis_summary.RData"),
  file.path(PROJECT_ROOT, "output", "artifact_manifest.csv"),
  file.path(paths$tables, "tab_p5_holdout_display.tex"),
  file.path(paths$figures, "fig_p5_locked_residual_diagnostics.pdf")
)
missing <- required[!file.exists(required)]
if (length(missing)) {
  stop("Missing generated artifact(s): ", paste(missing, collapse = ", "),
       call. = FALSE)
}

manifest_file <- file.path(PROJECT_ROOT, "output", "artifact_manifest.csv")
artifact_manifest <- utils::read.csv(manifest_file, stringsAsFactors = FALSE)
if (!"File" %in% names(artifact_manifest) || anyDuplicated(artifact_manifest$File)) {
  stop("The artifact manifest is malformed.", call. = FALSE)
}
output_root <- file.path(PROJECT_ROOT, "output")
manifest_output <- artifact_manifest$File[
  startsWith(artifact_manifest$File, "output/")
]
expected_output <- normalizePath(
  file.path(PROJECT_ROOT, manifest_output),
  winslash = "/", mustWork = FALSE
)
actual_output <- list.files(
  output_root, recursive = TRUE, full.names = TRUE, all.files = TRUE,
  no.. = TRUE
)
actual_output <- actual_output[
  file.info(actual_output)$isdir %in% FALSE & basename(actual_output) != ".gitkeep"
]
actual_output <- normalizePath(actual_output, winslash = "/", mustWork = TRUE)
allowed_output <- unique(c(expected_output, normalizePath(
  manifest_file, winslash = "/", mustWork = TRUE
)))
unexpected_output <- actual_output[
  !(tolower(actual_output) %in% tolower(allowed_output))
]
if (length(unexpected_output)) {
  stop(
    "Unexpected noncanonical output artifact(s): ",
    paste(unexpected_output, collapse = ", "),
    call. = FALSE
  )
}

forbidden_outcome_copies <- file.path(
  paths$processed, c("winequality-red.csv", "winequality.names")
)
if (any(file.exists(forbidden_outcome_copies))) {
  stop(
    "Processed data must not contain a full-data outcome copy: ",
    paste(forbidden_outcome_copies[file.exists(forbidden_outcome_copies)],
          collapse = ", "),
    call. = FALSE
  )
}

shared <- new.env(parent = emptyenv())
shared_objects <- load(file.path(paths$processed, "shared_data.RData"),
                       envir = shared)
if ("y_test" %in% shared_objects) {
  stop("Leakage boundary violated: shared_data.RData contains y_test.",
       call. = FALSE)
}
if (!all(c("train_data", "holdout_predictors", "foldid",
           "analysis_config") %in% shared_objects)) {
  stop("The shared training interface is incomplete.", call. = FALSE)
}
if ("quality" %in% names(shared$holdout_predictors)) {
  stop("Leakage boundary violated: holdout predictor data contain quality.",
       call. = FALSE)
}
if (nrow(shared$train_data) != 1088L ||
    nrow(shared$holdout_predictors) != 271L) {
  stop("Unexpected train/holdout row counts.", call. = FALSE)
}
if (length(intersect(shared$train_data$record_id,
                     shared$holdout_predictors$record_id))) {
  stop("Training and holdout record IDs overlap.", call. = FALSE)
}
if (!identical(sort(unique(shared$foldid)), seq_len(config$cv_folds))) {
  stop("Shared cross-validation fold IDs do not match config$cv_folds.",
       call. = FALSE)
}

lock <- utils::read.csv(file.path(PROJECT_ROOT, "output", "model_lock.csv"),
                        stringsAsFactors = FALSE)
if (nrow(lock) != 1L || !lock$Locked_model[[1L]] %in%
    c("OLS", "Ridge", "Lasso", "Elastic Net")) {
  stop("The pre-holdout model lock is invalid.", call. = FALSE)
}

holdout <- new.env(parent = emptyenv())
holdout_objects <- load(file.path(paths$models, "holdout_summary.RData"),
                        envir = holdout)
if ("y_test" %in% holdout_objects ||
    !all(c("holdout_summary", "holdout_performance") %in% holdout_objects)) {
  stop("Holdout results must contain aggregates and must not serialize y_test.",
       call. = FALSE)
}
if (!identical(holdout$holdout_summary$locked_model,
               lock$Locked_model[[1L]])) {
  stop("Holdout summary does not match the pre-holdout model lock.",
       call. = FALSE)
}
if (nrow(holdout$holdout_performance) != 5L ||
    any(!is.finite(holdout$holdout_performance$Holdout_RMSE))) {
  stop("Holdout model comparison is incomplete.", call. = FALSE)
}

log_step(
  "Generated outputs passed: 1,088 training rows, 271 holdout rows, locked ",
  lock$Locked_model[[1L]], ", no serialized y_test"
)
