###############################################################################
# File:        04_p4_regularized_models.R
# Owner:       P4 — Nguyễn Bảo Minh Triết
# Reviewer:    P3 and P5 — selection logic and pre-holdout lock
# Description: Fold-clean Ridge/Lasso/Elastic Net tuning and coefficient paths.
###############################################################################

if (!exists("PROJECT_ROOT", inherits = TRUE)) {
  stop("Run this module through analysis/03_regularized_models.R.", call. = FALSE)
}
source(file.path(PROJECT_ROOT, "R", "setup.R"))
source(file.path(PROJECT_ROOT, "R", "part1_helpers.R"))

load(SHARED_DATA_FILE)
load(file.path(MODEL_DIR, "baseline_fits.RData"))

log_step("P4: tuning Ridge, Lasso, and Elastic Net on shared fold IDs")
lambda_grid <- exp(seq(log(100), log(1e-4), length.out = 120L))
alpha_grid <- c(0, 0.25, 0.50, 0.75, 1)
cv_results <- setNames(vector("list", length(alpha_grid)),
                       paste0("alpha_", format(alpha_grid, trim = TRUE)))

for (i in seq_along(alpha_grid)) {
  alpha <- alpha_grid[[i]]
  log_info("P4 CV alpha=", alpha)
  cv_results[[i]] <- cv_regularized_foldclean(
    train_data, foldid, alpha = alpha, lambda = lambda_grid,
    log_features = log_features
  )
}

ridge_cv <- cv_results[[which(alpha_grid == 0)]]
lasso_cv <- cv_results[[which(alpha_grid == 1)]]
enet_candidates <- which(alpha_grid > 0 & alpha_grid < 1)
enet_best_index <- enet_candidates[which.min(vapply(
  cv_results[enet_candidates],
  function(result) result$cv_mse[result$min_index], numeric(1)
))]
enet_alpha <- alpha_grid[[enet_best_index]]
enet_cv <- cv_results[[enet_best_index]]

ridge_fit <- glmnet::glmnet(
  x_train, y_train, alpha = 0, lambda = lambda_grid,
  family = "gaussian", standardize = FALSE, intercept = TRUE
)
lasso_fit <- glmnet::glmnet(
  x_train, y_train, alpha = 1, lambda = lambda_grid,
  family = "gaussian", standardize = FALSE, intercept = TRUE
)
enet_fit <- glmnet::glmnet(
  x_train, y_train, alpha = enet_alpha, lambda = lambda_grid,
  family = "gaussian", standardize = FALSE, intercept = TRUE
)

model_objects <- list("Ridge" = ridge_fit, "Lasso" = lasso_fit,
                      "Elastic Net" = enet_fit)
model_cv <- list("Ridge" = ridge_cv, "Lasso" = lasso_cv,
                 "Elastic Net" = enet_cv)
model_alpha <- c("Ridge" = 0, "Lasso" = 1, "Elastic Net" = enet_alpha)

regularized_summary <- do.call(rbind, lapply(names(model_objects), function(name) {
  fit <- model_objects[[name]]
  cv <- model_cv[[name]]
  training_prediction <- as.numeric(stats::predict(fit, newx = x_train,
                                                    s = cv$lambda_min))
  data.frame(
    Model = name,
    Alpha = model_alpha[[name]],
    Lambda_min = cv$lambda_min,
    Lambda_1se = cv$lambda_1se,
    Training_RMSE = score_regression(y_train, training_prediction)[["RMSE"]],
    CV_RMSE_min = sqrt(cv$cv_mse[cv$min_index]),
    CV_RMSE_1se = sqrt(cv$cv_mse[cv$one_se_index]),
    Nonzero_min = nonzero_count(fit, cv$lambda_min),
    Nonzero_1se = nonzero_count(fit, cv$lambda_1se),
    stringsAsFactors = FALSE
  )
}))
rownames(regularized_summary) <- NULL

regularized_display <- regularized_summary[
  , c("Model", "Alpha", "Lambda_min", "Lambda_1se", "CV_RMSE_min",
      "Nonzero_min", "Nonzero_1se")
]

all_model_cv <- rbind(
  baseline_performance[, c("Model", "Training_RMSE", "CV_RMSE")],
  data.frame(
    Model = regularized_summary$Model,
    Training_RMSE = regularized_summary$Training_RMSE,
    CV_RMSE = regularized_summary$CV_RMSE_min
  )
)
candidate_rows <- all_model_cv$Model != "Mean"
locked_model <- all_model_cv$Model[candidate_rows][
  which.min(all_model_cv$CV_RMSE[candidate_rows])
]
model_lock <- data.frame(
  Locked_model = locked_model,
  Selection_metric = "Five-fold CV RMSE",
  CV_RMSE = all_model_cv$CV_RMSE[match(locked_model, all_model_cv$Model)],
  Rule = "Lowest CV RMSE; selected before holdout outcomes are reconstructed",
  stringsAsFactors = FALSE
)

coefficient_matrix <- data.frame(
  Feature = PREDICTORS,
  OLS = as.numeric(stats::coef(ols_fit)[PREDICTORS]),
  Ridge = as.numeric(stats::coef(ridge_fit, s = ridge_cv$lambda_min))[-1],
  Lasso = as.numeric(stats::coef(lasso_fit, s = lasso_cv$lambda_min))[-1],
  Elastic_Net = as.numeric(stats::coef(enet_fit, s = enet_cv$lambda_min))[-1],
  stringsAsFactors = FALSE
)

lasso_1se_coefficients <- as.numeric(
  stats::coef(lasso_fit, s = lasso_cv$lambda_1se)
)[-1]
lasso_selection <- data.frame(
  Feature = PREDICTORS,
  Coefficient = lasso_1se_coefficients,
  Selected = ifelse(abs(lasso_1se_coefficients) > 1e-8, "Yes", "No"),
  stringsAsFactors = FALSE
)
lasso_selection <- lasso_selection[
  order(abs(lasso_selection$Coefficient), decreasing = TRUE),
]

enet_alpha_search <- data.frame(
  Alpha = alpha_grid[enet_candidates],
  CV_RMSE_min = vapply(
    cv_results[enet_candidates],
    function(result) sqrt(result$cv_mse[result$min_index]), numeric(1)
  ),
  Lambda_min = vapply(
    cv_results[enet_candidates], function(result) result$lambda_min, numeric(1)
  )
)

save_table_artifacts(
  regularized_summary, "tab_p4_regularized_summary",
  "Cross-validated regularized-model tuning results before holdout evaluation.",
  "p4-regularized-summary", digits = 4
)
save_table_artifacts(
  regularized_display, "tab_p4_regularized_display",
  "Regularized-model tuning and effective size on the shared training folds.",
  "p4-regularized-display", digits = 4
)
save_table_artifacts(
  enet_alpha_search, "tab_p4_enet_alpha_search",
  "Elastic Net mixing-parameter search on shared folds.",
  "p4-enet-alpha-search", digits = 4
)
save_table_artifacts(
  coefficient_matrix, "tab_p4_coefficient_comparison",
  "Coefficients at minimum-CV penalties on the standardized transformed scale.",
  "p4-coefficient-comparison", digits = 4
)
save_table_artifacts(
  lasso_selection, "tab_p4_lasso_selection",
  "Embedded Lasso feature selection using the one-standard-error penalty.",
  "p4-lasso-selection", digits = 4
)
save_table_artifacts(
  model_lock, "tab_p4_model_lock",
  "Model locked by cross-validation before holdout evaluation.",
  "p4-model-lock", digits = 4
)
utils::write.csv(model_lock, file.path(OUTPUT_DIR, "model_lock.csv"),
                 row.names = FALSE)
writeLines(
  c(
    paste("Locked model:", model_lock$Locked_model),
    paste("Selection metric:", model_lock$Selection_metric),
    sprintf("Cross-validated RMSE: %.6f", model_lock$CV_RMSE),
    paste("Rule:", model_lock$Rule)
  ),
  file.path(OUTPUT_DIR, "model_lock.txt")
)

plot_cv_panel <- function(result, title) {
  x <- log(result$lambda)
  y <- sqrt(result$cv_mse)
  se_rmse <- sqrt(result$cv_mse + result$cv_se) - y
  graphics::plot(
    x, y, type = "l", lwd = 2, col = "#2878B5",
    xlab = expression(log(lambda)), ylab = "CV RMSE", main = title,
    ylim = range(c(y - se_rmse, y + se_rmse), finite = TRUE)
  )
  graphics::polygon(
    c(x, rev(x)), c(y - se_rmse, rev(y + se_rmse)),
    border = NA, col = grDevices::adjustcolor("#2878B5", alpha.f = 0.18)
  )
  graphics::lines(x, y, lwd = 2, col = "#2878B5")
  graphics::abline(v = log(result$lambda_min), col = "#D1495B", lty = 2, lwd = 1.5)
  graphics::abline(v = log(result$lambda_1se), col = "#2A9D8F", lty = 3, lwd = 1.5)
}

open_pdf("fig_p4_cv_curves.pdf", width = 10, height = 4.3)
graphics::par(mfrow = c(1, 3), mar = c(4.1, 4.1, 2.5, 0.7))
plot_cv_panel(ridge_cv, "Ridge")
plot_cv_panel(lasso_cv, "Lasso")
plot_cv_panel(enet_cv, sprintf("Elastic Net (alpha = %.2f)", enet_alpha))
graphics::mtext("Dashed: lambda.min   Dotted: lambda.1se", side = 1,
                outer = TRUE, line = -1.2, cex = 0.78)
grDevices::dev.off()

plot_path_panel <- function(fit, selected_lambda, title) {
  beta <- as.matrix(fit$beta)
  colors <- grDevices::hcl.colors(nrow(beta), "Dark 3")
  graphics::matplot(
    log(fit$lambda), t(beta), type = "l", lty = 1, lwd = 1.3,
    col = colors, xlab = expression(log(lambda)),
    ylab = "Standardized coefficient", main = title
  )
  graphics::abline(v = log(selected_lambda), col = "#17212B", lty = 2, lwd = 1.5)
  invisible(colors)
}

open_pdf("fig_p4_coefficient_paths.pdf", width = 10, height = 4.6)
graphics::par(mfrow = c(1, 3), mar = c(4.1, 4.2, 2.5, 0.7))
plot_path_panel(ridge_fit, ridge_cv$lambda_min, "Ridge paths")
plot_path_panel(lasso_fit, lasso_cv$lambda_min, "Lasso paths")
plot_path_panel(enet_fit, enet_cv$lambda_min, "Elastic Net paths")
grDevices::dev.off()

open_pdf("fig_p4_coefficient_comparison.pdf", width = 9, height = 6.5)
plot_order <- order(coefficient_matrix$OLS)
y_positions <- seq_along(plot_order)
range_x <- range(coefficient_matrix[, c("OLS", "Ridge", "Lasso", "Elastic_Net")])
graphics::plot(
  coefficient_matrix$OLS[plot_order], y_positions,
  xlim = range_x, ylim = c(0.5, length(plot_order) + 0.5),
  yaxt = "n", pch = 16, col = MODEL_COLORS[["OLS"]],
  xlab = "Coefficient on standardized transformed scale", ylab = "",
  main = "Regularization shrinks correlated coefficients"
)
graphics::axis(2, at = y_positions,
               labels = gsub("_", " ", coefficient_matrix$Feature[plot_order]),
               las = 1, cex.axis = 0.78)
for (name in c("Ridge", "Lasso", "Elastic_Net")) {
  display_name <- gsub("_", " ", name)
  graphics::points(
    coefficient_matrix[[name]][plot_order], y_positions,
    pch = c("Ridge" = 17, "Lasso" = 15, "Elastic_Net" = 18)[[name]],
    col = MODEL_COLORS[[display_name]], cex = 0.9
  )
}
graphics::abline(v = 0, col = "#AAB2B8")
graphics::legend(
  "bottomright", legend = c("OLS", "Ridge", "Lasso", "Elastic Net"),
  col = MODEL_COLORS[c("OLS", "Ridge", "Lasso", "Elastic Net")],
  pch = c(16, 17, 15, 18), bty = "n", cex = 0.8
)
grDevices::dev.off()

save(
  lambda_grid, alpha_grid, cv_results, ridge_cv, lasso_cv, enet_cv,
  enet_alpha, ridge_fit, lasso_fit, enet_fit, regularized_summary,
  regularized_display, coefficient_matrix, lasso_selection, enet_alpha_search, model_lock,
  all_model_cv,
  file = file.path(MODEL_DIR, "regularized_fits.RData")
)

log_info("P4 complete | Elastic Net alpha=", enet_alpha,
         " | locked model=", locked_model,
         " | locked CV RMSE=", sprintf("%.4f", model_lock$CV_RMSE))
