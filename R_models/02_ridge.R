###############################################################################
# File:        02_ridge.R
# Owner:       P2 (Tuan)
# Problem:     Problem 2B — Ridge Regression
# Description: Fits Ridge regression (alpha = 0) using cross-validation to
#              select the optimal lambda.  Compares condition numbers before
#              and after Ridge regularization.
#
# Background:
#   Ridge regression adds a penalty = lambda * sum(beta_j^2) to the OLS
#   loss function.  This shrinks all coefficients towards zero but never
#   sets them exactly to zero.  It is especially useful when predictors
#   are correlated (multicollinearity).
#
# Depends on:  output/shared_data.RData  (produced by 01_data_prep_eda.R)
###############################################################################

# ─────────────────────────────────────────────────────────────────────────────
# 0.  SOURCE SHARED SETUP
# ─────────────────────────────────────────────────────────────────────────────

setup_file <- if (file.exists("R_models/setup.R")) "R_models/setup.R" else "setup.R"
source(setup_file)
ensure_dirs()

cat("\n========== 02_ridge.R ==========\n\n")

# ─────────────────────────────────────────────────────────────────────────────
# 1.  LOAD SHARED DATA
# ─────────────────────────────────────────────────────────────────────────────

load("output/shared_data.RData")
cat("[02b_ridge] Loaded shared_data.RData\n")
cat("  Training samples:", nrow(x_train), "\n")
cat("  Predictors:      ", ncol(x_train), "\n\n")

# ─────────────────────────────────────────────────────────────────────────────
# 2.  FIT RIDGE REGRESSION (alpha = 0)
# ─────────────────────────────────────────────────────────────────────────────
# alpha = 0 tells glmnet to use L2 (Ridge) penalty.
# cv.glmnet performs K-fold CV (using our shared foldid) to pick lambda.

ridge_fit <- fit_cv_glmnet(x_train, y_train, alpha = 0, foldid = foldid)

# ─────────────────────────────────────────────────────────────────────────────
# 3.  REPORT LAMBDA VALUES
# ─────────────────────────────────────────────────────────────────────────────
# lambda.min — the lambda that gives the lowest CV error
# lambda.1se — the largest lambda within 1 standard error of the minimum
#              (more regularization → simpler model)

cat("\n--- Ridge Lambda Selection ---\n")
cat("  lambda.min:", round(ridge_fit$lambda.min, 6), "\n")
cat("  lambda.1se:", round(ridge_fit$lambda.1se, 6), "\n\n")

# Extract coefficients at both required tuning rules
ridge_coefs <- as.vector(coef(ridge_fit, s = "lambda.min"))
ridge_coefs_1se <- as.vector(coef(ridge_fit, s = "lambda.1se"))
ridge_coef_names <- c("(Intercept)", predictors)
names(ridge_coefs) <- ridge_coef_names
names(ridge_coefs_1se) <- ridge_coef_names

cat("Ridge Coefficients at lambda.min:\n")
print(round(ridge_coefs, 4))
cat("\nRidge Coefficients at lambda.1se:\n")
print(round(ridge_coefs_1se, 4))

# ─────────────────────────────────────────────────────────────────────────────
# 4.  CONDITION NUMBERS
# ─────────────────────────────────────────────────────────────────────────────
# This demonstrates why Ridge is useful: it dramatically reduces the
# condition number of X'X, making the solution numerically stable.

cat("\n--- Condition Number Analysis ---\n")
cond <- safe_condition_numbers(x_train, lambda = ridge_fit$lambda.min)

# ─────────────────────────────────────────────────────────────────────────────
# 5.  TRAINING METRICS
# ─────────────────────────────────────────────────────────────────────────────

y_pred_ridge_train <- predict(ridge_fit, newx = x_train, s = "lambda.min")
ridge_train_scores <- score_regression(y_train, as.vector(y_pred_ridge_train))

cat("\n--- Ridge Training Performance ---\n")
cat("  RMSE:", round(ridge_train_scores$RMSE, 4), "\n")
cat("  MAE: ", round(ridge_train_scores$MAE,  4), "\n")
cat("  R²:  ", round(ridge_train_scores$R2,   4), "\n\n")

###############################################################################
#                              FIGURES                                        #
###############################################################################

# ─────────────────────────────────────────────────────────────────────────────
# FIGURE 1:  CV ERROR PLOT
# ─────────────────────────────────────────────────────────────────────────────
# Shows how cross-validation error changes with log(lambda).
# The two vertical dashed lines mark lambda.min and lambda.1se.

cat("[02b_ridge] Generating CV error plot...\n")

pdf("output/figures/fig_p2_ridge_cv.pdf", width = 8, height = 5)
par(mar = c(5, 4, 3, 2))

plot(ridge_fit, main = "Ridge: Cross-Validation Error vs log(lambda)")

dev.off()
cat("[02b_ridge] Saved: output/figures/fig_p2_ridge_cv.pdf\n")

# ─────────────────────────────────────────────────────────────────────────────
# FIGURE 2:  COEFFICIENT PATH PLOT
# ─────────────────────────────────────────────────────────────────────────────
# Shows how each coefficient evolves as lambda increases (left to right).
# All coefficients shrink towards zero as lambda grows.

cat("[02b_ridge] Generating coefficient path plot...\n")

pdf("output/figures/fig_p2_ridge_path.pdf", width = 8, height = 5)
par(mar = c(5, 4, 3, 6))   # extra right margin for labels

# glmnet object is stored inside the cv.glmnet object as $glmnet.fit
plot(ridge_fit$glmnet.fit, xvar = "lambda",
     main = "Ridge: Coefficient Paths")
abline(v = log(ridge_fit$lambda.min), lty = 2, col = "red")
abline(v = log(ridge_fit$lambda.1se), lty = 2, col = "blue")
legend("topright",
       legend = c("lambda.min", "lambda.1se"),
       lty = 2, col = c("red", "blue"), bty = "n", cex = 0.8)

dev.off()
cat("[02b_ridge] Saved: output/figures/fig_p2_ridge_path.pdf\n")

# ─────────────────────────────────────────────────────────────────────────────
# FIGURE 3:  RIDGE COEFFICIENTS BAR CHART
# ─────────────────────────────────────────────────────────────────────────────

cat("[02b_ridge] Generating coefficient bar chart...\n")

# Exclude intercept for the bar chart
coef_no_int <- ridge_coefs[-1]

pdf("output/figures/fig_p2_ridge_coef.pdf", width = 8, height = 5)
par(mar = c(7, 4, 3, 2))

barplot(
  coef_no_int,
  col    = ifelse(coef_no_int > 0, project_colors["Ridge"], project_colors["Lasso"]),
  border = NA,
  main   = "Ridge Coefficients at lambda.min",
  ylab   = "Coefficient Value",
  las    = 2,
  cex.names = 0.8
)
abline(h = 0, col = "grey40", lty = 2)

dev.off()
cat("[02b_ridge] Saved: output/figures/fig_p2_ridge_coef.pdf\n")

###############################################################################
#                              TABLES                                         #
###############################################################################

# ─────────────────────────────────────────────────────────────────────────────
# TABLE 1:  LAMBDA VALUES
# ─────────────────────────────────────────────────────────────────────────────

lambda_df <- data.frame(
  Metric     = c("lambda.min", "lambda.1se"),
  Value      = round(c(ridge_fit$lambda.min, ridge_fit$lambda.1se), 6),
  CV_Error   = round(c(
    ridge_fit$cvm[which(ridge_fit$lambda == ridge_fit$lambda.min)],
    ridge_fit$cvm[which(ridge_fit$lambda == ridge_fit$lambda.1se)]
  ), 4)
)

save_table_tex(
  df       = lambda_df,
  filename = "tab_p2_ridge_lambda.tex",
  caption  = "Ridge Regression: Selected Lambda Values",
  label    = "tab:ridge_lambda"
)

# ─────────────────────────────────────────────────────────────────────────────
# TABLE 2:  RIDGE COEFFICIENTS
# ─────────────────────────────────────────────────────────────────────────────

ridge_coef_df <- data.frame(
  Predictor       = names(ridge_coefs),
  Coef_lambda_min = round(ridge_coefs, 4),
  Coef_lambda_1se = round(ridge_coefs_1se, 4)
)
rownames(ridge_coef_df) <- NULL

save_table_tex(
  df       = ridge_coef_df,
  filename = "tab_p2_ridge_coef.tex",
  caption  = "Ridge Regression Coefficients at $\\lambda_{\\min}$ and $\\lambda_{1\\mathrm{se}}$",
  label    = "tab:ridge_coef"
)

# ─────────────────────────────────────────────────────────────────────────────
# TABLE 3:  CONDITION NUMBERS
# ─────────────────────────────────────────────────────────────────────────────

cond_df <- data.frame(
  Matrix     = c("G = X'X/n", "G + lambda*I"),
  Condition_Number = format(c(cond$ols_cond, cond$ridge_cond),
                            big.mark = ",", digits = 4),
  Improvement = c("—",
                   paste0(round(cond$ols_cond / cond$ridge_cond, 1), "x reduction"))
)

save_table_tex(
  df       = cond_df,
  filename = "tab_p2_cond.tex",
  caption  = "Condition Numbers: OLS vs Ridge",
  label    = "tab:condition_numbers"
)

# ─────────────────────────────────────────────────────────────────────────────
# SAVE RIDGE FIT
# ─────────────────────────────────────────────────────────────────────────────

save(ridge_fit, ridge_train_scores, ridge_coefs, ridge_coefs_1se, cond,
     file = "output/ridge_fit.RData")
cat("[02b_ridge] Saved: output/ridge_fit.RData\n")

# ─────────────────────────────────────────────────────────────────────────────
# DONE
# ─────────────────────────────────────────────────────────────────────────────
cat("\n========== 02_ridge.R COMPLETE ==========\n")
