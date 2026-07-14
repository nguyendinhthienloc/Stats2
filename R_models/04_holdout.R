###############################################################################
# File:        04_holdout.R
# Owner:       P5 (Tai)
# Problem:     Problem 4D — Final Holdout Evaluation
# Description: Evaluates ALL fitted models on the held-out TEST set.
#              This is the DEFINITIVE comparison of model performance.
#
# ┌──────────────────────────────────────────────────────────────────────────┐
# │                                                                          │
# │   ⚠⚠⚠  WARNING: THIS IS THE FIRST AND ONLY SCRIPT THAT USES y_test  ⚠⚠⚠  │
# │                                                                          │
# │   The test set must NEVER be used during model training, tuning, or      │
# │   feature engineering.  It is used ONCE here for final evaluation.       │
# │                                                                          │
# │   If you use y_test anywhere else, your results are INVALID because      │
# │   you have committed data leakage (the model "saw" the test answers).    │
# │                                                                          │
# └──────────────────────────────────────────────────────────────────────────┘
#
# Depends on:  output/shared_data.RData  (01_data_prep_eda.R)
#              output/ols_fit.RData       (02_ols.R)
#              output/ridge_fit.RData     (02_ridge.R)
#              output/lasso_fit.RData     (02_lasso.R)
#              output/enet_fits.RData     (04_enet.R)
#              output/neural_fits.RData   (04_neural.R)
###############################################################################

# ─────────────────────────────────────────────────────────────────────────────
# 0.  SOURCE SHARED SETUP
# ─────────────────────────────────────────────────────────────────────────────

source("R_models/setup.R")
ensure_dirs()

cat("\n========== 04_holdout.R ==========\n\n")

cat("╔══════════════════════════════════════════════════════════════╗\n")
cat("║  FINAL HOLDOUT EVALUATION — using y_test for the FIRST time ║\n")
cat("╚══════════════════════════════════════════════════════════════╝\n\n")

# ─────────────────────────────────────────────────────────────────────────────
# 1.  LOAD ALL DATA AND MODEL FITS
# ─────────────────────────────────────────────────────────────────────────────

load("output/shared_data.RData")
load("output/ols_fit.RData")
load("output/ridge_fit.RData")
load("output/lasso_fit.RData")
load("output/enet_fits.RData")
load("output/neural_fits.RData")

cat("[04d_holdout] Loaded all shared data and model fits\n")
cat("  Test set size:", length(y_test), "observations\n\n")

# ─────────────────────────────────────────────────────────────────────────────
# 2.  GENERATE PREDICTIONS ON x_test (and H_test for neural models)
# ─────────────────────────────────────────────────────────────────────────────
# Each model predicts on the test predictors that it was designed for:
#   - OLS, Ridge, Lasso, Elastic Net  →  use x_test (14 original features)
#   - Neural Ridge/Lasso/ENet         →  use H_test (200 random features)

cat("--- Generating test-set predictions ---\n")

# 2a. OLS predictions
pred_ols <- predict(ols_fit, newdata = data.frame(x_test))
cat("  OLS predictions: done\n")

# 2b. Ridge predictions (at lambda.min)
pred_ridge <- as.vector(predict(ridge_fit, newx = x_test, s = "lambda.min"))
cat("  Ridge predictions: done\n")

# 2c. Lasso predictions (at lambda.min)
pred_lasso <- as.vector(predict(lasso_fit, newx = x_test, s = "lambda.min"))
cat("  Lasso predictions: done\n")

# 2d. Elastic Net predictions (at lambda.min of best alpha)
pred_enet <- as.vector(predict(best_fit, newx = x_test, s = "lambda.min"))
cat("  Elastic Net (alpha =", best_alpha, ") predictions: done\n")

# 2e. Neural Ridge predictions
pred_neural_ridge <- as.vector(predict(neural_ridge_fit, newx = H_test, s = "lambda.min"))
cat("  Neural Ridge predictions: done\n")

# 2f. Neural Lasso predictions
pred_neural_lasso <- as.vector(predict(neural_lasso_fit, newx = H_test, s = "lambda.min"))
cat("  Neural Lasso predictions: done\n")

# 2g. Neural Elastic Net predictions
pred_neural_enet <- as.vector(predict(neural_enet_fit, newx = H_test, s = "lambda.min"))
cat("  Neural Elastic Net predictions: done\n\n")

# ─────────────────────────────────────────────────────────────────────────────
# 3.  COMPUTE TEST-SET METRICS
# ─────────────────────────────────────────────────────────────────────────────

cat("--- Computing test-set metrics (RMSE, MAE) ---\n")

scores_ols   <- score_regression(y_test, pred_ols)
scores_ridge <- score_regression(y_test, pred_ridge)
scores_lasso <- score_regression(y_test, pred_lasso)
scores_enet  <- score_regression(y_test, pred_enet)
scores_nr    <- score_regression(y_test, pred_neural_ridge)
scores_nl    <- score_regression(y_test, pred_neural_lasso)
scores_ne    <- score_regression(y_test, pred_neural_enet)

# ─────────────────────────────────────────────────────────────────────────────
# 4.  BUILD FINAL COMPARISON TABLE
# ─────────────────────────────────────────────────────────────────────────────

final_df <- data.frame(
  Model = c("OLS", "Ridge", "Lasso",
            paste0("Elastic Net (a=", best_alpha, ")"),
            "Neural Ridge", "Neural Lasso",
            paste0("Neural ENet (a=", best_alpha, ")")),
  Test_RMSE = round(c(scores_ols$RMSE, scores_ridge$RMSE, scores_lasso$RMSE,
                       scores_enet$RMSE, scores_nr$RMSE, scores_nl$RMSE,
                       scores_ne$RMSE), 4),
  Test_MAE  = round(c(scores_ols$MAE, scores_ridge$MAE, scores_lasso$MAE,
                       scores_enet$MAE, scores_nr$MAE, scores_nl$MAE,
                       scores_ne$MAE), 4),
  Test_R2   = round(c(scores_ols$R2, scores_ridge$R2, scores_lasso$R2,
                       scores_enet$R2, scores_nr$R2, scores_nl$R2,
                       scores_ne$R2), 4),
  stringsAsFactors = FALSE
)

# Sort by Test RMSE (best first)
final_df <- final_df[order(final_df$Test_RMSE), ]
rownames(final_df) <- NULL

cat("\n╔═══════════════════════════════════════════════════╗\n")
cat("║          FINAL HOLDOUT RESULTS                     ║\n")
cat("╠═══════════════════════════════════════════════════╣\n")
print(final_df)
cat("╚═══════════════════════════════════════════════════╝\n\n")

# Identify the best model
best_model_name <- final_df$Model[1]
cat("*** BEST MODEL:", best_model_name,
    "(Test RMSE =", final_df$Test_RMSE[1], ") ***\n\n")

###############################################################################
#                              FIGURES                                        #
###############################################################################

# ─────────────────────────────────────────────────────────────────────────────
# FIGURE 1:  FINAL RMSE / MAE COMPARISON BAR CHART
# ─────────────────────────────────────────────────────────────────────────────

cat("[04d_holdout] Generating final comparison bar chart...\n")

pdf("output/figures/fig_p4_holdout_compare.pdf", width = 11, height = 6)
par(mar = c(8, 4, 3, 8), xpd = TRUE)

bar_data_final <- rbind(final_df$Test_RMSE, final_df$Test_MAE)
colnames(bar_data_final) <- final_df$Model
rownames(bar_data_final) <- c("Test RMSE", "Test MAE")

# Use distinct colours for each model
model_colors <- c(
  project_colors["OLS"],
  project_colors["Ridge"],
  project_colors["Lasso"],
  project_colors["ElasticNet"],
  project_colors["NeuralRidge"],
  project_colors["NeuralLasso"],
  project_colors["NeuralENet"]
)
# Reorder colours to match sorted order
sorted_indices <- match(final_df$Model,
                        c("OLS", "Ridge", "Lasso",
                          paste0("Elastic Net (a=", best_alpha, ")"),
                          "Neural Ridge", "Neural Lasso",
                          paste0("Neural ENet (a=", best_alpha, ")")))
sorted_colors <- model_colors[sorted_indices]

bp <- barplot(
  bar_data_final,
  beside    = TRUE,
  col       = c(project_colors["highlight"], project_colors["neutral"]),
  border    = NA,
  main      = "Final Holdout: Test RMSE and MAE",
  ylab      = "Error",
  las       = 2,
  cex.names = 0.65
)

legend("topright", inset = c(-0.18, 0),
       legend = c("Test RMSE", "Test MAE"),
       fill   = c(project_colors["highlight"], project_colors["neutral"]),
       bty = "n", cex = 0.8)

dev.off()
cat("[04d_holdout] Saved: output/figures/fig_p4_holdout_compare.pdf\n")

# ─────────────────────────────────────────────────────────────────────────────
# FIGURE 2:  ACTUAL VS PREDICTED SCATTER (BEST MODEL)
# ─────────────────────────────────────────────────────────────────────────────
# A perfect model would have all points on the 45-degree line.

cat("[04d_holdout] Generating actual vs predicted scatter...\n")

# Get predictions for the best model
# We need to map the best model name back to its predictions
all_preds <- list(
  "OLS"                                          = pred_ols,
  "Ridge"                                        = pred_ridge,
  "Lasso"                                        = pred_lasso,
  "Elastic Net"                                  = pred_enet,
  "Neural Ridge"                                 = pred_neural_ridge,
  "Neural Lasso"                                 = pred_neural_lasso
)
# Add the Elastic Net and Neural ENet with their full names
all_preds[[paste0("Elastic Net (a=", best_alpha, ")")]] <- pred_enet
all_preds[[paste0("Neural ENet (a=", best_alpha, ")")]] <- pred_neural_enet

best_pred <- all_preds[[best_model_name]]

# If best_pred is NULL, fall back to Ridge
if (is.null(best_pred)) {
  cat("  Warning: could not match best model name. Using Ridge predictions.\n")
  best_pred <- pred_ridge
  best_model_name <- "Ridge"
}

pdf("output/figures/fig_p4_actual_vs_pred.pdf", width = 7, height = 7)
par(mar = c(5, 4, 3, 2))

# Axis range should cover both actual and predicted
axis_range <- range(c(y_test, best_pred))

plot(
  y_test, best_pred,
  pch  = 16,
  col  = adjustcolor(project_colors["OLS"], alpha.f = 0.6),
  cex  = 1.2,
  xlab = paste("Actual", config$response),
  ylab = paste("Predicted", config$response),
  main = paste("Actual vs Predicted:", best_model_name),
  xlim = axis_range,
  ylim = axis_range,
  las  = 1
)

# Add 45-degree line (perfect prediction)
abline(0, 1, col = project_colors["Lasso"], lwd = 2, lty = 2)

# Add regression line through the points
abline(lm(best_pred ~ y_test), col = project_colors["Ridge"], lwd = 2)

legend("topleft",
       legend = c("Data Points", "Perfect Prediction (y = x)", "Best Fit Line"),
       pch    = c(16, NA, NA),
       lty    = c(NA, 2, 1),
       lwd    = c(NA, 2, 2),
       col    = c(project_colors["OLS"], project_colors["Lasso"], project_colors["Ridge"]),
       bty    = "n", cex = 0.8)

# Add R² annotation
text(axis_range[1] + diff(axis_range) * 0.05,
     axis_range[2] - diff(axis_range) * 0.05,
     labels = paste0("R² = ", round(scores_ols$R2, 3)),
     adj = 0, cex = 0.9)

dev.off()
cat("[04d_holdout] Saved: output/figures/fig_p4_actual_vs_pred.pdf\n")

###############################################################################
#                              TABLES                                         #
###############################################################################

# ─────────────────────────────────────────────────────────────────────────────
# TABLE:  FINAL HOLDOUT COMPARISON
# ─────────────────────────────────────────────────────────────────────────────

save_table_tex(
  df       = final_df,
  filename = "tab_p4_holdout.tex",
  caption  = "Final Holdout Test-Set Performance (Sorted by RMSE)",
  label    = "tab:final_holdout"
)

# ─────────────────────────────────────────────────────────────────────────────
# DONE
# ─────────────────────────────────────────────────────────────────────────────
cat("\n╔══════════════════════════════════════════════════════╗\n")
cat("║  04_holdout.R COMPLETE — All models evaluated!       ║\n")
cat("║  Check output/tables/tab_p4_holdout.tex            ║\n")
cat("╚══════════════════════════════════════════════════════╝\n")
