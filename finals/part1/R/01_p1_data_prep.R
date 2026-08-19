###############################################################################
# File:        01_p1_data_prep.R
# Owner:       P1 — Nguyễn Đình Thiên Lộc
# Reviewer:    P5 — integration and leakage audit
# Description: Ingest, validate, deduplicate, split, and lock shared row IDs.
###############################################################################

if (!exists("PROJECT_ROOT", inherits = TRUE)) {
  stop("Run this module through analysis/01_eda_cleaning.R.", call. = FALSE)
}
source(file.path(PROJECT_ROOT, "R", "setup.R"))
source(file.path(PROJECT_ROOT, "R", "part1_helpers.R"))

log_step("P1: ingesting and validating Wine Quality (Red)")
wine_raw <- read_red_wine()
analytical_columns <- c(PREDICTORS, TARGET)

missing_cells <- sum(is.na(wine_raw[analytical_columns]))
nonfinite_cells <- sum(!is.finite(as.matrix(wine_raw[analytical_columns])))
duplicate_rows <- sum(duplicated(wine_raw[analytical_columns]))
wine_unique <- deduplicate_wine(wine_raw)

if (missing_cells != 0L || nonfinite_cells != 0L) {
  log_warn("Unexpected missing/non-finite values found; training-only imputation remains active")
}
if (nrow(wine_unique) != 1359L || duplicate_rows != 240L) {
  abort_run("Data audit mismatch: expected 1,359 unique rows and 240 duplicates")
}

log_step("P1: creating the fixed, quality-stratified 80/20 split")
holdout_index <- stratified_holdout_indices(
  wine_unique[[TARGET]], HOLDOUT_FRACTION, SEED_SPLIT
)
training_index <- setdiff(seq_len(nrow(wine_unique)), holdout_index)

train_data <- wine_unique[
  training_index, c("record_id", PREDICTORS, TARGET), drop = FALSE
]
holdout_predictors <- wine_unique[
  holdout_index, c("record_id", PREDICTORS), drop = FALSE
]
foldid <- stratified_folds(train_data[[TARGET]], N_FOLDS, SEED_FOLDS)

if (length(intersect(train_data$record_id, holdout_predictors$record_id)) > 0L) {
  abort_run("Training/holdout record overlap detected")
}
if (!identical(sort(unique(foldid)), seq_len(N_FOLDS))) {
  abort_run("Cross-validation fold construction failed")
}

split_manifest <- data.frame(
  record_id = wine_unique$record_id,
  partition = ifelse(seq_len(nrow(wine_unique)) %in% holdout_index,
                     "holdout", "training"),
  stringsAsFactors = FALSE
)
split_summary <- data.frame(
  Partition = c("Raw archive", "Unique before split", "Training", "Holdout"),
  Observations = c(nrow(wine_raw), nrow(wine_unique),
                   nrow(train_data), nrow(holdout_predictors)),
  Percent_of_unique = c(NA, 100, 100 * nrow(train_data) / nrow(wine_unique),
                        100 * nrow(holdout_predictors) / nrow(wine_unique))
)

data_audit <- data.frame(
  Check = c(
    "Raw observations", "Numeric predictors", "Missing cells",
    "Non-finite numeric cells", "Exact duplicate rows removed",
    "Unique observations", "Observed quality range"
  ),
  Result = c(
    nrow(wine_raw), length(PREDICTORS), missing_cells, nonfinite_cells,
    duplicate_rows, nrow(wine_unique),
    paste0(min(wine_raw[[TARGET]]), "--", max(wine_raw[[TARGET]]))
  ),
  Decision = c(
    "Validated against UCI metadata", "All retained", "None to impute",
    "None", "Remove before splitting to prevent duplicate leakage",
    "Analysis population", "Treat as numeric regression response"
  ),
  stringsAsFactors = FALSE
)

data_dictionary <- data.frame(
  Variable = c(PREDICTORS, TARGET),
  Role = c(rep("Predictor", length(PREDICTORS)), "Response"),
  Type = c(rep("Numeric", length(PREDICTORS)), "Integer score"),
  Description = c(
    "Fixed acidity (g/dm3)", "Volatile acidity (g/dm3)",
    "Citric acid (g/dm3)", "Residual sugar (g/dm3)",
    "Chlorides (g/dm3)", "Free sulfur dioxide (mg/dm3)",
    "Total sulfur dioxide (mg/dm3)", "Density (g/cm3)", "pH",
    "Potassium sulphate (g/dm3)", "Alcohol (% by volume)",
    "Median sensory score from wine experts (0--10 documented; 3--8 observed)"
  ),
  stringsAsFactors = FALSE
)

save_table_artifacts(
  data_audit, "tab_p1_data_audit",
  "Data-integrity audit and decisions.", "p1-data-audit", digits = 2
)
save_table_artifacts(
  split_summary, "tab_p1_split_summary",
  "Locked data partitions after deduplication.", "p1-split-summary", digits = 1
)
save_table_artifacts(
  data_dictionary, "tab_p1_data_dictionary",
  "Wine Quality (Red) data dictionary.", "p1-data-dictionary", digits = 2
)

log_step("P1: writing split artifacts and the predictor-only holdout interface")
stale_outcome_copies <- file.path(
  DATA_DIR, c("winequality-red.csv", "winequality.names")
)
invisible(file.remove(stale_outcome_copies[file.exists(stale_outcome_copies)]))
archive <- file.path(PROJECT_ROOT, "data", "raw", "source",
                     "wine-quality.zip")
utils::write.csv(train_data, file.path(DATA_DIR, "training_data.csv"),
                 row.names = FALSE)
utils::write.csv(holdout_predictors,
                 file.path(DATA_DIR, "holdout_predictors_no_outcome.csv"),
                 row.names = FALSE)
utils::write.csv(split_manifest, file.path(DATA_DIR, "split_manifest.csv"),
                 row.names = FALSE)

analysis_config <- list(
  group = "08",
  project = "03 — Wine Quality (Red)",
  task = "regression",
  target = TARGET,
  predictors = PREDICTORS,
  seed_split = SEED_SPLIT,
  seed_folds = SEED_FOLDS,
  seed_bootstrap = SEED_BOOTSTRAP,
  holdout_fraction = HOLDOUT_FRACTION,
  folds = N_FOLDS,
  raw_rows = nrow(wine_raw),
  duplicate_rows = duplicate_rows,
  unique_rows = nrow(wine_unique),
  training_rows = nrow(train_data),
  holdout_rows = nrow(holdout_predictors),
  archive_md5 = if (file.exists(archive)) unname(tools::md5sum(archive)) else NA_character_
)

# Deliberately omit holdout outcomes. Stage 04 reconstructs them once.
save(
  train_data, holdout_predictors, training_index, holdout_index, foldid,
  split_manifest, split_summary, data_audit, data_dictionary, analysis_config,
  file = SHARED_DATA_FILE
)

log_info("P1 complete | raw=", nrow(wine_raw), " | unique=", nrow(wine_unique),
         " | training=", nrow(train_data), " | holdout=", nrow(holdout_predictors),
         " | duplicates removed=", duplicate_rows)

