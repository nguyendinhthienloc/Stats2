###############################################################################
# File:        03_p3_feature_selection.R
# Owner:       P3 — Lê Minh Thuận
# Reviewer:    P4 — common-fold and modelling interface
# Description: Correlation/VIF screening, sensitivity selection, and baselines.
###############################################################################

if (!exists("PROJECT_ROOT", inherits = TRUE)) {
  stop("Run this module through analysis/02_feature_selection.R.", call. = FALSE)
}
source(file.path(PROJECT_ROOT, "R", "setup.R"))
source(file.path(PROJECT_ROOT, "R", "part1_helpers.R"))

load(SHARED_DATA_FILE)

log_step("P3: computing correlation/VIF screening and baseline models")
vif_values <- compute_vif(x_train)
target_correlations <- stats::cor(x_train, y_train)[, 1]

model_frame <- data.frame(quality = y_train, x_train, check.names = FALSE)
ols_fit <- stats::lm(quality ~ ., data = model_frame)
null_fit <- stats::lm(quality ~ 1, data = model_frame)
stepwise_fit <- stats::step(
  null_fit,
  scope = list(lower = stats::formula(null_fit), upper = stats::formula(ols_fit)),
  direction = "both", trace = 0, k = 2
)
stepwise_features <- attr(stats::terms(stepwise_fit), "term.labels")

ols_coefficients <- stats::coef(ols_fit)[PREDICTORS]
feature_screening <- data.frame(
  Feature = PREDICTORS,
  Correlation_with_quality = as.numeric(target_correlations[PREDICTORS]),
  VIF = as.numeric(vif_values[PREDICTORS]),
  OLS_standardized_coefficient = as.numeric(ols_coefficients[PREDICTORS]),
  Stepwise_AIC_retained = ifelse(PREDICTORS %in% stepwise_features, "Yes", "No"),
  stringsAsFactors = FALSE
)
feature_screening <- feature_screening[
  order(abs(feature_screening$Correlation_with_quality), decreasing = TRUE),
]

mean_prediction <- rep(mean(y_train), length(y_train))
ols_prediction <- stats::predict(ols_fit, newdata = model_frame)
mean_training_score <- score_regression(y_train, mean_prediction)
ols_training_score <- score_regression(y_train, ols_prediction)
mean_cv_score <- cv_mean_baseline(y_train, foldid)
ols_cv_score <- cv_ols_foldclean(train_data, foldid, log_features)

baseline_performance <- data.frame(
  Model = c("Mean", "OLS"),
  Training_RMSE = c(mean_training_score[["RMSE"]], ols_training_score[["RMSE"]]),
  CV_RMSE = c(mean_cv_score[["RMSE"]], ols_cv_score[["RMSE"]]),
  CV_MAE = c(mean_cv_score[["MAE"]], ols_cv_score[["MAE"]]),
  CV_R2 = c(mean_cv_score[["R2"]], ols_cv_score[["R2"]]),
  Predictors = c(0L, length(PREDICTORS)),
  stringsAsFactors = FALSE
)

stepwise_selection <- data.frame(
  Feature = PREDICTORS,
  Retained = ifelse(PREDICTORS %in% stepwise_features, "Yes", "No"),
  stringsAsFactors = FALSE
)

save_table_artifacts(
  feature_screening, "tab_p3_feature_screening",
  "Training-only feature screening and OLS coefficients on the standardized scale.",
  "p3-feature-screening", digits = 3
)
save_table_artifacts(
  baseline_performance, "tab_p3_baseline_performance",
  "Mean and OLS baseline performance before holdout evaluation.",
  "p3-baseline-performance", digits = 3
)
save_table_artifacts(
  stepwise_selection, "tab_p3_stepwise_sensitivity",
  "AIC stepwise selection used as a sensitivity analysis.",
  "p3-stepwise-sensitivity", digits = 2
)

open_pdf("fig_p3_feature_screening.pdf", width = 9, height = 5.5)
graphics::par(mfrow = c(1, 2), mar = c(4.2, 7.2, 2.7, 0.8))
vif_order <- order(feature_screening$VIF)
graphics::barplot(
  feature_screening$VIF[vif_order],
  names.arg = gsub("_", " ", feature_screening$Feature[vif_order]),
  horiz = TRUE, las = 1, col = "#E9C46A", border = NA,
  xlab = "Variance inflation factor", main = "Collinearity diagnostic",
  cex.names = 0.72
)
graphics::abline(v = c(5, 10), lty = c(2, 3), col = c("#D1495B", "#7F0000"))

coef_order <- order(ols_coefficients)
coefficient_colors <- ifelse(ols_coefficients[coef_order] >= 0,
                             "#2A9D8F", "#D1495B")
graphics::barplot(
  ols_coefficients[coef_order],
  names.arg = gsub("_", " ", names(ols_coefficients)[coef_order]),
  horiz = TRUE, las = 1, col = coefficient_colors, border = NA,
  xlab = "OLS coefficient (standardized predictor)",
  main = "Direction and relative magnitude", cex.names = 0.72
)
graphics::abline(v = 0, col = "#25313C")
grDevices::dev.off()

save(
  ols_fit, stepwise_fit, stepwise_features, feature_screening,
  baseline_performance, mean_training_score, ols_training_score,
  mean_cv_score, ols_cv_score,
  file = file.path(MODEL_DIR, "baseline_fits.RData")
)

log_info("P3 complete | max VIF=", sprintf("%.2f", max(vif_values)),
         " | AIC sensitivity retained=", length(stepwise_features), "/",
         length(PREDICTORS), " | OLS CV RMSE=", sprintf("%.3f", ols_cv_score[["RMSE"]]))

