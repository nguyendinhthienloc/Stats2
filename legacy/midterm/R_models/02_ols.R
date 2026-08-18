###############################################################################
# File:        02_ols.R
# Owner:       P2 (Tuan)
# Problem:     Problem 2A — OLS (Ordinary Least Squares) Baseline
# Description: Fits a standard linear regression (no regularization) on the
#              training data.  This serves as the BASELINE that we compare
#              Ridge and Lasso against.
#
# Depends on:  output/shared_data.RData  (produced by 01_data_prep_eda.R)
###############################################################################

# ─────────────────────────────────────────────────────────────────────────────
# 0.  SOURCE SHARED SETUP
# ─────────────────────────────────────────────────────────────────────────────

setup_file <- if (file.exists("R_models/setup.R")) "R_models/setup.R" else "setup.R"
source(setup_file)
ensure_dirs()

cat("\n========== 02_ols.R ==========\n\n")

# ─────────────────────────────────────────────────────────────────────────────
# 1.  LOAD SHARED DATA
# ─────────────────────────────────────────────────────────────────────────────
# This brings into memory: x_train, x_test, y_train, y_test, foldid,
# config, seeds, predictors, etc.

load("output/shared_data.RData")
cat("[02a_ols] Loaded shared_data.RData\n")
cat("  Training samples:", nrow(x_train), "\n")
cat("  Predictors:      ", ncol(x_train), "\n\n")

# ─────────────────────────────────────────────────────────────────────────────
# 2.  FIT OLS MODEL
# ─────────────────────────────────────────────────────────────────────────────
# lm() = linear model (OLS).  We need to combine x_train and y_train into
# a data.frame because lm() uses the formula interface (y ~ .).
#
# The formula  y ~ .  means "regress y on ALL other columns in the data".

ols_df <- data.frame(y = y_train, x_train)
ols_fit <- lm(y ~ ., data = ols_df)

# Print a summary of the OLS fit
cat("--- OLS Model Summary ---\n")
print(summary(ols_fit))

# ─────────────────────────────────────────────────────────────────────────────
# 3.  EXTRACT COEFFICIENTS
# ─────────────────────────────────────────────────────────────────────────────
# coef() returns a named vector: intercept first, then one per predictor.

ols_coefs <- coef(ols_fit)
cat("\nOLS Coefficients:\n")
print(round(ols_coefs, 4))

# ─────────────────────────────────────────────────────────────────────────────
# 4.  COMPUTE TRAINING METRICS
# ─────────────────────────────────────────────────────────────────────────────
# We evaluate on the TRAINING set to see how well OLS fits the data it saw.
# (Test-set evaluation is reserved for 04_holdout.R.)

y_pred_train <- predict(ols_fit, newdata = data.frame(x_train))
ols_train_scores <- score_regression(y_train, y_pred_train)

cat("\n--- OLS Training Performance ---\n")
cat("  RMSE:", round(ols_train_scores$RMSE, 4), "\n")
cat("  MAE: ", round(ols_train_scores$MAE,  4), "\n")
cat("  R²:  ", round(ols_train_scores$R2,   4), "\n\n")

# ─────────────────────────────────────────────────────────────────────────────
# 5.  COEFFICIENT BAR PLOT
# ─────────────────────────────────────────────────────────────────────────────
# A bar chart of coefficients shows which predictors have the largest
# influence in the OLS model.  (Intercept is excluded for clarity.)

cat("[02a_ols] Generating coefficient bar plot...\n")

# Drop the intercept for the plot
coef_no_int <- ols_coefs[-1]

pdf("output/figures/fig_p2_ols_coef.pdf", width = 8, height = 5)
par(mar = c(7, 4, 3, 2))

barplot(
  coef_no_int,
  col    = ifelse(coef_no_int > 0, project_colors["OLS"], project_colors["Lasso"]),
  border = NA,
  main   = "OLS Coefficients (Standardised Predictors)",
  ylab   = "Coefficient Value",
  las    = 2,
  cex.names = 0.8
)
abline(h = 0, col = "grey40", lty = 2)

dev.off()
cat("[02a_ols] Saved: output/figures/fig_p2_ols_coef.pdf\n")

# ─────────────────────────────────────────────────────────────────────────────
# 6.  RESIDUAL VS FITTED PLOT
# ─────────────────────────────────────────────────────────────────────────────
# This diagnostic plot checks whether residuals are randomly scattered
# around zero (good) or show a pattern (bad — suggests non-linearity).

cat("[02a_ols] Generating residual vs fitted plot...\n")

ols_residuals <- residuals(ols_fit)
ols_fitted    <- fitted(ols_fit)

pdf("output/figures/fig_p2_ols_resid.pdf", width = 7, height = 5)
par(mar = c(5, 4, 3, 2))

plot(
  ols_fitted, ols_residuals,
  pch  = 16,
  col  = adjustcolor(project_colors["OLS"], alpha.f = 0.6),
  xlab = "Fitted Values",
  ylab = "Residuals",
  main = "OLS: Residuals vs Fitted Values",
  las  = 1
)
abline(h = 0, col = project_colors["Lasso"], lwd = 2, lty = 2)

# Add a LOESS smoother to check for systematic patterns
lines(lowess(ols_fitted, ols_residuals), col = project_colors["ElasticNet"], lwd = 2)
legend("topright",
       legend = c("Residuals", "Zero line", "LOESS smoother"),
       pch    = c(16, NA, NA),
       lty    = c(NA, 2, 1),
       col    = c(project_colors["OLS"], project_colors["Lasso"], project_colors["ElasticNet"]),
       bty    = "n")

dev.off()
cat("[02a_ols] Saved: output/figures/fig_p2_ols_resid.pdf\n")

# ─────────────────────────────────────────────────────────────────────────────
# 7.  Q-Q PLOT OF RESIDUALS
# ─────────────────────────────────────────────────────────────────────────────
# A Q-Q (quantile-quantile) plot checks whether residuals are approximately
# normally distributed.  Points on the diagonal = normal.

cat("[02a_ols] Generating Q-Q plot...\n")

pdf("output/figures/fig_p2_ols_qq.pdf", width = 6, height = 6)
par(mar = c(5, 4, 3, 2))

qqnorm(
  ols_residuals,
  pch  = 16,
  col  = adjustcolor(project_colors["OLS"], alpha.f = 0.6),
  main = "Q-Q Plot of OLS Residuals"
)
qqline(ols_residuals, col = project_colors["Lasso"], lwd = 2)

dev.off()
cat("[02a_ols] Saved: output/figures/fig_p2_ols_qq.pdf\n")

# ─────────────────────────────────────────────────────────────────────────────
# 8.  SAVE COEFFICIENTS TABLE
# ─────────────────────────────────────────────────────────────────────────────

coef_df <- data.frame(
  Predictor   = names(ols_coefs),
  Coefficient = round(ols_coefs, 4)
)
rownames(coef_df) <- NULL

save_table_tex(
  df       = coef_df,
  filename = "tab_p2_ols_coef.tex",
  caption  = "OLS Regression Coefficients (Standardised Predictors)",
  label    = "tab:ols_coef"
)

# ─────────────────────────────────────────────────────────────────────────────
# 9.  SAVE OLS FIT OBJECT
# ─────────────────────────────────────────────────────────────────────────────
# Other scripts (02d_comparison, 04d_holdout) will load this to make
# predictions without re-fitting.

save(ols_fit, ols_train_scores, file = "output/ols_fit.RData")
cat("[02a_ols] Saved: output/ols_fit.RData\n")

# ─────────────────────────────────────────────────────────────────────────────
# DONE
# ─────────────────────────────────────────────────────────────────────────────
cat("\n========== 02_ols.R COMPLETE ==========\n")
