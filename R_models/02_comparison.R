###############################################################################
# File:        02_comparison.R
# Owner:       P3 (Thuan)
# Problem:     Problem 2D-2E — Model Comparison and Perturbation Analysis
# Description: Compares OLS, Ridge, and Lasso on training metrics and CV
#              error.  Performs a bootstrap perturbation analysis to check
#              coefficient stability across methods.
#
# Depends on:  output/shared_data.RData  (01_data_prep_eda.R)
#              output/ols_fit.RData       (02_ols.R)
#              output/ridge_fit.RData     (02_ridge.R)
#              output/lasso_fit.RData     (02_lasso.R)
###############################################################################

# ─────────────────────────────────────────────────────────────────────────────
# 0.  SOURCE SHARED SETUP
# ─────────────────────────────────────────────────────────────────────────────

source("R_models/setup.R")
ensure_dirs()

cat("\n========== 02_comparison.R ==========\n\n")

# ─────────────────────────────────────────────────────────────────────────────
# 1.  LOAD ALL REQUIRED DATA AND MODELS
# ─────────────────────────────────────────────────────────────────────────────

load("output/shared_data.RData")
load("output/ols_fit.RData")
load("output/ridge_fit.RData")
load("output/lasso_fit.RData")

cat("[02d_comparison] Loaded shared_data, ols_fit, ridge_fit, lasso_fit\n\n")

# ─────────────────────────────────────────────────────────────────────────────
# 2.  BUILD COMPARISON TABLE
# ─────────────────────────────────────────────────────────────────────────────
# We compare three metrics:
#   - Training RMSE  : how well the model fits training data
#   - Training MAE   : mean absolute error on training data
#   - CV RMSE        : estimated out-of-sample error (from cross-validation)
#
# OLS does NOT have a built-in CV RMSE from glmnet, so we compute it
# manually using the foldid.

cat("--- Computing OLS CV RMSE ---\n")

# Compute OLS CV RMSE by hand: for each fold, hold it out, fit on the rest
ols_cv_errors <- numeric(max(foldid))

for (k in seq_len(max(foldid))) {
  # Indices for this fold
  val_idx   <- which(foldid == k)
  train_idx <- which(foldid != k)
  
  # Fit OLS on the training folds
  ols_cv_df <- data.frame(y = y_train[train_idx], x_train[train_idx, , drop = FALSE])
  ols_cv_model <- lm(y ~ ., data = ols_cv_df)
  
  # Predict on the validation fold
  ols_cv_pred <- predict(ols_cv_model,
                         newdata = data.frame(x_train[val_idx, , drop = FALSE]))
  
  # Compute MSE for this fold
  ols_cv_errors[k] <- mean((y_train[val_idx] - ols_cv_pred)^2)
}

ols_cv_rmse <- sqrt(mean(ols_cv_errors))
cat("  OLS CV RMSE:", round(ols_cv_rmse, 4), "\n")

# Ridge CV RMSE at lambda.min
ridge_cv_idx  <- which(ridge_fit$lambda == ridge_fit$lambda.min)
ridge_cv_rmse <- sqrt(ridge_fit$cvm[ridge_cv_idx])

# Lasso CV RMSE at lambda.min
lasso_cv_idx  <- which(lasso_fit$lambda == lasso_fit$lambda.min)
lasso_cv_rmse <- sqrt(lasso_fit$cvm[lasso_cv_idx])

# Assemble the comparison table
comparison_df <- data.frame(
  Model        = c("OLS", "Ridge", "Lasso"),
  Train_RMSE   = round(c(ols_train_scores$RMSE,
                          ridge_train_scores$RMSE,
                          lasso_train_scores$RMSE), 4),
  Train_MAE    = round(c(ols_train_scores$MAE,
                          ridge_train_scores$MAE,
                          lasso_train_scores$MAE), 4),
  CV_RMSE      = round(c(ols_cv_rmse,
                          ridge_cv_rmse,
                          lasso_cv_rmse), 4),
  stringsAsFactors = FALSE
)

cat("\n--- Model Comparison ---\n")
print(comparison_df)

# ─────────────────────────────────────────────────────────────────────────────
# 3.  NOMINATE CORE MODEL
# ─────────────────────────────────────────────────────────────────────────────
# TODO: After reviewing the comparison table, fill in your justification
#       for which model you nominate as the "core" model.
#
# Criteria to consider:
#   - Lowest CV RMSE (best generalisation)
#   - Simplicity / interpretability (fewer features = Lasso advantage)
#   - Numerical stability (Ridge advantage over OLS)
#
# Placeholder:
core_model_name <- "Ridge"   # TODO: Change if needed after analysis
cat("\nNominated core model:", core_model_name, "\n")
cat("  TODO: Write your justification in the LaTeX report.\n\n")

# ─────────────────────────────────────────────────────────────────────────────
# 4.  PERTURBATION / BOOTSTRAP STABILITY ANALYSIS
# ─────────────────────────────────────────────────────────────────────────────
# Idea: Resample training data B=50 times (with replacement), refit each
# model, and see how much the coefficients vary.
#
# A STABLE model produces similar coefficients regardless of small changes
# in the training data.  We expect Ridge to be the most stable (because
# the L2 penalty smooths the solution) and OLS to be the least stable
# (especially if predictors are correlated).

cat("--- Perturbation Analysis (B = 50 bootstrap resamples) ---\n")

B <- 50L   # number of bootstrap resamples
p <- ncol(x_train)

# Storage: B rows x p columns for each model
ols_boot_coefs   <- matrix(NA, nrow = B, ncol = p)
ridge_boot_coefs <- matrix(NA, nrow = B, ncol = p)
lasso_boot_coefs <- matrix(NA, nrow = B, ncol = p)

colnames(ols_boot_coefs)   <- predictors
colnames(ridge_boot_coefs) <- predictors
colnames(lasso_boot_coefs) <- predictors

set.seed(seeds$split)   # reproducibility for the bootstrap

for (b in seq_len(B)) {
  if (b %% 10 == 0) cat("  Bootstrap iteration:", b, "/", B, "\n")
  
  # Resample training indices WITH replacement
  boot_idx <- sample(seq_len(nrow(x_train)), replace = TRUE)
  
  x_boot <- x_train[boot_idx, ]
  y_boot <- y_train[boot_idx]
  
  # OLS
  ols_boot_df <- data.frame(y = y_boot, x_boot)
  ols_boot_fit <- lm(y ~ ., data = ols_boot_df)
  ols_boot_coefs[b, ] <- coef(ols_boot_fit)[-1]  # exclude intercept
  
  # Ridge (use same lambda.min, don't re-CV)
  ridge_boot_fit <- glmnet(x_boot, y_boot, alpha = 0)
  ridge_boot_coefs[b, ] <- as.vector(
    coef(ridge_boot_fit, s = ridge_fit$lambda.min)[-1, ]
  )
  
  # Lasso (use same lambda.min, don't re-CV)
  lasso_boot_fit <- glmnet(x_boot, y_boot, alpha = 1)
  lasso_boot_coefs[b, ] <- as.vector(
    coef(lasso_boot_fit, s = lasso_fit$lambda.min)[-1, ]
  )
}

# Compute coefficient standard deviations across bootstrap samples
ols_stability   <- apply(ols_boot_coefs,   2, sd)
ridge_stability <- apply(ridge_boot_coefs, 2, sd)
lasso_stability <- apply(lasso_boot_coefs, 2, sd)

cat("\nMean coefficient SD across predictors:\n")
cat("  OLS:  ", round(mean(ols_stability),   4), "\n")
cat("  Ridge:", round(mean(ridge_stability),  4), "\n")
cat("  Lasso:", round(mean(lasso_stability),  4), "\n\n")

###############################################################################
#                              FIGURES                                        #
###############################################################################

# ─────────────────────────────────────────────────────────────────────────────
# FIGURE 1:  MODEL COMPARISON BAR CHART
# ─────────────────────────────────────────────────────────────────────────────

cat("[02d_comparison] Generating model comparison bar chart...\n")

pdf("output/figures/fig_p2_comparison.pdf", width = 8, height = 5)
par(mar = c(5, 4, 3, 8), xpd = TRUE)

# Create a matrix for grouped bar chart
bar_data <- rbind(
  comparison_df$Train_RMSE,
  comparison_df$Train_MAE,
  comparison_df$CV_RMSE
)
colnames(bar_data) <- comparison_df$Model
rownames(bar_data) <- c("Train RMSE", "Train MAE", "CV RMSE")

bar_colors_comp <- c(project_colors["OLS"],
                     project_colors["Ridge"],
                     project_colors["Lasso"])

barplot(
  bar_data,
  beside = TRUE,
  col    = c(project_colors["highlight"], project_colors["neutral"], project_colors["ElasticNet"]),
  border = NA,
  main   = "Model Comparison: OLS vs Ridge vs Lasso",
  ylab   = "Error",
  las    = 1
)
legend("topright", inset = c(-0.25, 0),
       legend = rownames(bar_data),
       fill   = c(project_colors["highlight"], project_colors["neutral"], project_colors["ElasticNet"]),
       bty = "n", cex = 0.8)

dev.off()
cat("[02d_comparison] Saved: output/figures/fig_p2_comparison.pdf\n")

# ─────────────────────────────────────────────────────────────────────────────
# FIGURE 2:  PERTURBATION STABILITY PLOT
# ─────────────────────────────────────────────────────────────────────────────
# Shows the standard deviation of each coefficient across bootstrap resamples.
# Lower SD = more stable.

cat("[02d_comparison] Generating perturbation stability plot...\n")

pdf("output/figures/fig_p2_perturbation.pdf", width = 10, height = 6)
par(mar = c(7, 4, 3, 8), xpd = TRUE)

stability_matrix <- rbind(ols_stability, ridge_stability, lasso_stability)
colnames(stability_matrix) <- predictors

barplot(
  stability_matrix,
  beside    = TRUE,
  col       = c(project_colors["OLS"], project_colors["Ridge"], project_colors["Lasso"]),
  border    = NA,
  main      = "Coefficient Stability: SD Across 50 Bootstrap Resamples",
  ylab      = "Standard Deviation of Coefficient",
  las       = 2,
  cex.names = 0.7
)
legend("topright", inset = c(-0.18, 0),
       legend = c("OLS", "Ridge", "Lasso"),
       fill   = c(project_colors["OLS"], project_colors["Ridge"], project_colors["Lasso"]),
       bty = "n", cex = 0.8)

dev.off()
cat("[02d_comparison] Saved: output/figures/fig_p2_perturbation.pdf\n")

###############################################################################
#                              TABLES                                         #
###############################################################################

# ─────────────────────────────────────────────────────────────────────────────
# TABLE:  MODEL COMPARISON
# ─────────────────────────────────────────────────────────────────────────────

save_table_tex(
  df       = comparison_df,
  filename = "tab_p2_comparison.tex",
  caption  = "Comparison of OLS, Ridge, and Lasso Regression",
  label    = "tab:model_comparison"
)

# ─────────────────────────────────────────────────────────────────────────────
# DONE
# ─────────────────────────────────────────────────────────────────────────────
cat("\n========== 02_comparison.R COMPLETE ==========\n")
