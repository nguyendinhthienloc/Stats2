###############################################################################
# File:        02_p2_eda_cleaning.R
# Owner:       P2 — Trần Lê Anh Tuấn
# Reviewer:    P3 — preprocessing and feature-screening interface
# Description: Training-only EDA, outlier audit, transformations, and recipe.
###############################################################################

setup_candidates <- c("setup.R", file.path("finals", "part1", "setup.R"),
                      file.path("..", "setup.R"))
source(setup_candidates[file.exists(setup_candidates)][1])
load("output/shared_data.RData")

log_step("P2: auditing distributions and selecting training-only transformations")
training_predictors <- train_data[PREDICTORS]
y_train <- train_data[[TARGET]]
raw_skewness <- vapply(training_predictors, sample_skewness, numeric(1))
nonnegative <- vapply(training_predictors, function(x) min(x, na.rm = TRUE) >= 0,
                      logical(1))
log_features <- names(raw_skewness)[raw_skewness > 1 & nonnegative]

recipe <- fit_preprocessor(
  train_data, predictors = PREDICTORS, log_features = log_features,
  winsor_probs = WINSOR_PROBS
)
x_train <- apply_preprocessor(train_data, recipe)
x_holdout <- apply_preprocessor(holdout_predictors, recipe)

if (any(!is.finite(x_train)) || any(!is.finite(x_holdout))) {
  abort_run("Non-finite values remain after preprocessing")
}

descriptive_statistics <- do.call(rbind, lapply(c(PREDICTORS, TARGET), function(name) {
  x <- train_data[[name]]
  data.frame(
    Variable = name, N = length(x), Mean = mean(x), SD = stats::sd(x),
    Min = min(x), Q1 = unname(stats::quantile(x, 0.25)), Median = stats::median(x),
    Q3 = unname(stats::quantile(x, 0.75)), Max = max(x),
    Skewness = sample_skewness(x), stringsAsFactors = FALSE
  )
}))

quality_frequency <- as.data.frame(table(y_train), stringsAsFactors = FALSE)
names(quality_frequency) <- c("Quality", "Count")
quality_frequency$Percent <- 100 * quality_frequency$Count / sum(quality_frequency$Count)

outlier_audit <- do.call(rbind, lapply(PREDICTORS, function(name) {
  x <- train_data[[name]]
  quartiles <- stats::quantile(x, c(0.25, 0.75), names = FALSE)
  spread <- diff(quartiles)
  lower <- quartiles[1] - 1.5 * spread
  upper <- quartiles[2] + 1.5 * spread
  flagged <- x < lower | x > upper
  data.frame(
    Variable = name, IQR_Flags = sum(flagged),
    Percent = 100 * mean(flagged), Lower_Fence = lower, Upper_Fence = upper,
    stringsAsFactors = FALSE
  )
}))

row_outlier_matrix <- sapply(PREDICTORS, function(name) {
  x <- train_data[[name]]
  quartiles <- stats::quantile(x, c(0.25, 0.75), names = FALSE)
  spread <- diff(quartiles)
  x < quartiles[1] - 1.5 * spread | x > quartiles[2] + 1.5 * spread
})
rows_with_any_iqr_flag <- sum(rowSums(row_outlier_matrix) > 0)

transformation_plan <- data.frame(
  Variable = PREDICTORS,
  Raw_Skewness = unname(raw_skewness[PREDICTORS]),
  IQR_Flags = outlier_audit$IQR_Flags,
  Winsor_Lower = unname(recipe$limits["lower", PREDICTORS]),
  Winsor_Upper = unname(recipe$limits["upper", PREDICTORS]),
  Transformation = ifelse(PREDICTORS %in% log_features,
                          "log1p + standardize", "standardize"),
  stringsAsFactors = FALSE
)

correlation_matrix <- stats::cor(train_data[c(PREDICTORS, TARGET)])
target_correlations <- correlation_matrix[PREDICTORS, TARGET]
correlation_quality <- data.frame(
  Variable = names(target_correlations),
  Correlation_with_quality = as.numeric(target_correlations),
  Absolute_correlation = abs(as.numeric(target_correlations)),
  stringsAsFactors = FALSE
)
correlation_quality <- correlation_quality[
  order(correlation_quality$Absolute_correlation, decreasing = TRUE),
]

save_table_artifacts(
  descriptive_statistics, "tab_p2_descriptive_statistics",
  "Training-set descriptive statistics.", "p2-descriptive-statistics", digits = 3
)
save_table_artifacts(
  quality_frequency, "tab_p2_quality_frequency",
  "Training-set quality-score distribution.", "p2-quality-frequency", digits = 1
)
save_table_artifacts(
  outlier_audit, "tab_p2_outlier_audit",
  "Training-set Tukey-IQR outlier audit; rows are retained.",
  "p2-outlier-audit", digits = 3
)
save_table_artifacts(
  transformation_plan, "tab_p2_transformation_plan",
  "Training-only transformation and winsorization plan.",
  "p2-transformation-plan", digits = 4
)
save_table_artifacts(
  correlation_quality, "tab_p2_target_correlations",
  "Training-set marginal correlations with quality.",
  "p2-target-correlations", digits = 3
)

log_step("P2: generating training-only EDA figures")
open_pdf("fig_p2_quality_distribution.pdf", width = 7, height = 4.5)
quality_counts <- table(y_train)
graphics::barplot(
  quality_counts, col = "#2878B5", border = NA,
  xlab = "Observed quality score", ylab = "Training observations",
  main = "Quality is concentrated at scores 5 and 6"
)
graphics::grid(nx = NA, ny = NULL, col = "#E4E8EB")
graphics::box()
grDevices::dev.off()

open_pdf("fig_p2_predictor_distributions.pdf", width = 10, height = 8)
graphics::par(mfrow = c(3, 4), mar = c(3.1, 3.1, 2.1, 0.7),
              mgp = c(1.9, 0.6, 0), tcl = -0.2)
for (name in PREDICTORS) {
  graphics::hist(
    train_data[[name]], breaks = "FD", col = "#B9D7EA", border = "white",
    main = gsub("_", " ", name), xlab = "", ylab = "Count"
  )
}
graphics::plot.new()
graphics::text(0.5, 0.6, "Training data only", cex = 1.1, font = 2)
graphics::text(0.5, 0.43, paste("log1p selected:", paste(log_features, collapse = ", ")),
               cex = 0.72)
grDevices::dev.off()

open_pdf("fig_p2_correlation_heatmap.pdf", width = 8.5, height = 7.5)
ordered_names <- c(PREDICTORS, TARGET)
image_matrix <- correlation_matrix[rev(ordered_names), ordered_names]
palette <- grDevices::colorRampPalette(c("#B2182B", "#F7F7F7", "#2166AC"))(101)
graphics::image(
  seq_along(ordered_names), seq_along(ordered_names), image_matrix,
  zlim = c(-1, 1), col = palette, axes = FALSE,
  xlab = "", ylab = "", main = "Training correlation structure"
)
graphics::axis(1, at = seq_along(ordered_names),
               labels = gsub("_", " ", ordered_names), las = 2, cex.axis = 0.66)
graphics::axis(2, at = seq_along(ordered_names),
               labels = gsub("_", " ", rev(ordered_names)), las = 2,
               cex.axis = 0.66)
graphics::box()
grDevices::dev.off()

top_relationships <- correlation_quality$Variable[seq_len(4)]
open_pdf("fig_p2_pairwise_quality.pdf", width = 9, height = 7)
graphics::par(mfrow = c(2, 2), mar = c(4, 4, 2.2, 0.8))
set.seed(SEED_SPLIT + 11L)
for (name in top_relationships) {
  x <- train_data[[name]]
  jittered_quality <- jitter(y_train, amount = 0.09)
  graphics::plot(
    x, jittered_quality, pch = 16, cex = 0.5,
    col = grDevices::adjustcolor("#2878B5", alpha.f = 0.32),
    xlab = gsub("_", " ", name), ylab = "Quality",
    main = sprintf("r = %.2f", target_correlations[[name]])
  )
  graphics::abline(stats::lm(y_train ~ x), col = "#D1495B", lwd = 2)
}
grDevices::dev.off()

open_pdf("fig_p2_outlier_audit.pdf", width = 8, height = 5.5)
ordered_outliers <- outlier_audit[order(outlier_audit$IQR_Flags), ]
graphics::barplot(
  ordered_outliers$IQR_Flags, names.arg = gsub("_", " ", ordered_outliers$Variable),
  horiz = TRUE, las = 1, col = "#E9C46A", border = NA,
  xlab = "Training observations beyond 1.5 x IQR fences",
  main = "Outlier flags are common and distributed across variables",
  cex.names = 0.76
)
grDevices::dev.off()

# Extend the shared interface without adding a holdout outcome.
save(
  train_data, holdout_predictors, training_index, holdout_index, foldid,
  split_manifest, split_summary, data_audit, data_dictionary, analysis_config,
  recipe, log_features, x_train, x_holdout, y_train, raw_skewness,
  descriptive_statistics, quality_frequency, outlier_audit,
  rows_with_any_iqr_flag, transformation_plan, correlation_matrix,
  correlation_quality,
  file = file.path(OUTPUT_DIR, "shared_data.RData")
)

log_info("P2 complete | log1p features=", paste(log_features, collapse = ", "),
         " | rows with >=1 IQR flag=", rows_with_any_iqr_flag,
         " (", sprintf("%.1f", 100 * rows_with_any_iqr_flag / nrow(train_data)), "%)")

