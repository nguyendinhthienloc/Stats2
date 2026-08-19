###############################################################################
# File:        02_lasso.R
# Owner:       P3 (Thuan)
# Problem:     Problem 2C — Lasso Regression
# Description: Fits Lasso regression (alpha = 1) using cross-validation to
#              select the optimal lambda.  Lasso performs variable selection
#              by setting some coefficients exactly to zero.
#
# Background:
#   Lasso = Least Absolute Shrinkage and Selection Operator.
#   Penalty = lambda * sum(|beta_j|)  (L1 norm).
#   Unlike Ridge, Lasso can set coefficients EXACTLY to zero, effectively
#   removing predictors from the model (automatic feature selection).
#
# Depends on:  output/shared_data.RData  (produced by 01_data_prep_eda.R)
###############################################################################

# ─────────────────────────────────────────────────────────────────────────────
# 0.  SOURCE SHARED SETUP
# ─────────────────────────────────────────────────────────────────────────────

setup_file <- if (file.exists("R_models/setup.R")) "R_models/setup.R" else "setup.R"
source(setup_file)
ensure_dirs()

cat("\n========== 02_lasso.R ==========\n\n")

# ─────────────────────────────────────────────────────────────────────────────
# 1.  LOAD SHARED DATA
# ─────────────────────────────────────────────────────────────────────────────

load("output/shared_data.RData")
cat("[02c_lasso] Loaded shared_data.RData\n")
cat("  Training samples:", nrow(x_train), "\n")
cat("  Predictors:      ", ncol(x_train), "\n\n")

# ─────────────────────────────────────────────────────────────────────────────
# 2.  FIT LASSO REGRESSION (alpha = 1)
# ─────────────────────────────────────────────────────────────────────────────
# alpha = 1 tells glmnet to use L1 (Lasso) penalty.
# We use the same foldid as Ridge for a fair comparison.

lasso_fit <- fit_foldclean_glmnet(x_raw_train, y_train, alpha = 1, foldid = foldid)

# ─────────────────────────────────────────────────────────────────────────────
# 3.  REPORT LAMBDA VALUES AND FEATURE SELECTION
# ─────────────────────────────────────────────────────────────────────────────

cat("\n--- Lasso Lambda Selection ---\n")
cat("  lambda.min:", round(lasso_fit$lambda.min, 6), "\n")
cat("  lambda.1se:", round(lasso_fit$lambda.1se, 6), "\n\n")

# Count non-zero coefficients
n_nonzero_min <- count_nonzero(lasso_fit, s = "lambda.min")
n_nonzero_1se <- count_nonzero(lasso_fit, s = "lambda.1se")

cat("  Nonzero at lambda.min:", n_nonzero_min, "out of", ncol(x_train), "\n")
cat("  Nonzero at lambda.1se:", n_nonzero_1se, "out of", ncol(x_train), "\n\n")

# Extract coefficients at both required tuning rules
lasso_coefs <- as.vector(coef(lasso_fit, s = "lambda.min"))
lasso_coefs_1se <- as.vector(coef(lasso_fit, s = "lambda.1se"))
lasso_coef_names <- c("(Intercept)", predictors)
names(lasso_coefs) <- lasso_coef_names
names(lasso_coefs_1se) <- lasso_coef_names

cat("Lasso Coefficients at lambda.min:\n")
print(round(lasso_coefs, 4))
cat("\nLasso Coefficients at lambda.1se:\n")
print(round(lasso_coefs_1se, 4))

# Identify selected (non-zero) features
selected_mask   <- lasso_coefs[-1] != 0   # exclude intercept
selected_mask_1se <- abs(lasso_coefs_1se[-1]) > 1e-8
selected_names  <- predictors[selected_mask]
selected_names_1se <- predictors[selected_mask_1se]
eliminated_names <- predictors[!selected_mask]

cat("\n--- Feature Selection ---\n")
cat("  SELECTED features:   ", paste(selected_names, collapse = ", "), "\n")
cat("  ELIMINATED features: ", paste(eliminated_names, collapse = ", "), "\n\n")
cat("  SELECTED at lambda.1se:", paste(selected_names_1se, collapse = ", "), "\n\n")

# ─────────────────────────────────────────────────────────────────────────────
# 4.  TRAINING METRICS
# ─────────────────────────────────────────────────────────────────────────────

y_pred_lasso_train <- predict(lasso_fit, newx = x_raw_train, s = "lambda.min")
lasso_train_scores <- score_regression(y_train, as.vector(y_pred_lasso_train))

cat("--- Lasso Training Performance ---\n")
cat("  RMSE:", round(lasso_train_scores$RMSE, 4), "\n")
cat("  MAE: ", round(lasso_train_scores$MAE,  4), "\n")
cat("  R²:  ", round(lasso_train_scores$R2,   4), "\n\n")

###############################################################################
#                              FIGURES                                        #
###############################################################################

# ─────────────────────────────────────────────────────────────────────────────
# FIGURE 1:  CV ERROR PLOT
# ─────────────────────────────────────────────────────────────────────────────
# The top axis shows the number of non-zero coefficients at each lambda.
# As lambda increases (right), more coefficients are zeroed out.

cat("[02c_lasso] Generating CV error plot...\n")

pdf("output/figures/fig_p2_lasso_cv.pdf", width = 8, height = 5)
par(mar = c(5, 4, 3, 2))

plot(lasso_fit, main = "Lasso: Cross-Validation Error vs log(lambda)")

dev.off()
cat("[02c_lasso] Saved: output/figures/fig_p2_lasso_cv.pdf\n")

# ─────────────────────────────────────────────────────────────────────────────
# FIGURE 2:  COEFFICIENT PATH PLOT
# ─────────────────────────────────────────────────────────────────────────────
# Watch how coefficients shrink and then HIT ZERO as lambda increases.
# This is the key visual difference between Lasso and Ridge.

cat("[02c_lasso] Generating coefficient path plot...\n")

pdf("output/figures/fig_p2_lasso_path.pdf", width = 8, height = 5)
par(mar = c(5, 4, 3, 6))

plot(lasso_fit$glmnet.fit, xvar = "lambda",
     main = "Lasso: Coefficient Paths")
abline(v = log(lasso_fit$lambda.min), lty = 2, col = "red")
abline(v = log(lasso_fit$lambda.1se), lty = 2, col = "blue")
legend("topright",
       legend = c("lambda.min", "lambda.1se"),
       lty = 2, col = c("red", "blue"), bty = "n", cex = 0.8)

dev.off()
cat("[02c_lasso] Saved: output/figures/fig_p2_lasso_path.pdf\n")

# ─────────────────────────────────────────────────────────────────────────────
# FIGURE 3:  NON-ZERO COEFFICIENTS BAR CHART
# ─────────────────────────────────────────────────────────────────────────────
# Only shows the coefficients that Lasso kept (non-zero at lambda.min).

cat("[02c_lasso] Generating non-zero coefficients bar chart...\n")

# All predictor coefficients (excluding intercept)
coef_no_int <- lasso_coefs[-1]

pdf("output/figures/fig_p2_lasso_coef.pdf", width = 8, height = 5)
par(mar = c(7, 4, 3, 2))

# Colour: selected features in red-orange, eliminated features in grey
bar_colors <- ifelse(coef_no_int != 0,
                     ifelse(coef_no_int > 0,
                            project_colors["Lasso"],
                            project_colors["ElasticNet"]),
                     project_colors["neutral"])

barplot(
  coef_no_int,
  col    = bar_colors,
  border = NA,
  main   = paste("Lasso Coefficients at lambda.min (",
                  n_nonzero_min, "non-zero )"),
  ylab   = "Coefficient Value",
  las    = 2,
  cex.names = 0.8
)
abline(h = 0, col = "grey40", lty = 2)

# Add a legend
legend("topright",
       legend = c("Selected (positive)", "Selected (negative)", "Eliminated (= 0)"),
       fill   = c(project_colors["Lasso"], project_colors["ElasticNet"], project_colors["neutral"]),
       bty    = "n", cex = 0.7)

dev.off()
cat("[02c_lasso] Saved: output/figures/fig_p2_lasso_coef.pdf\n")

###############################################################################
#                              TABLES                                         #
###############################################################################

# ─────────────────────────────────────────────────────────────────────────────
# TABLE 1:  LASSO LAMBDA VALUES
# ─────────────────────────────────────────────────────────────────────────────

lambda_df <- data.frame(
  Metric     = c("lambda.min", "lambda.1se"),
  Value      = round(c(lasso_fit$lambda.min, lasso_fit$lambda.1se), 6),
  Nonzero    = c(n_nonzero_min, n_nonzero_1se),
  CV_Error   = round(c(
    lasso_fit$cvm[which(lasso_fit$lambda == lasso_fit$lambda.min)],
    lasso_fit$cvm[which(lasso_fit$lambda == lasso_fit$lambda.1se)]
  ), 4)
)

save_table_tex(
  df       = lambda_df,
  filename = "tab_p2_lasso_lambda.tex",
  caption  = "Lasso Regression: Selected Lambda Values",
  label    = "tab:lasso_lambda"
)

# ─────────────────────────────────────────────────────────────────────────────
# TABLE 2:  LASSO COEFFICIENTS
# ─────────────────────────────────────────────────────────────────────────────

lasso_coef_df <- data.frame(
  Predictor       = names(lasso_coefs),
  Coef_lambda_min = round(lasso_coefs, 4),
  Coef_lambda_1se = round(lasso_coefs_1se, 4),
  At_lambda_min   = c("Intercept", ifelse(selected_mask, "Selected", "Zero")),
  At_lambda_1se   = c("Intercept", ifelse(selected_mask_1se, "Selected", "Zero"))
)
rownames(lasso_coef_df) <- NULL

save_table_tex(
  df       = lasso_coef_df,
  filename = "tab_p2_lasso_coef.tex",
  caption  = "Lasso Coefficients and Selection at Both Tuning Rules",
  label    = "tab:lasso_coef"
)

# ─────────────────────────────────────────────────────────────────────────────
# TABLE 3:  SELECTED FEATURES SUMMARY
# ─────────────────────────────────────────────────────────────────────────────

selected_df <- data.frame(
  Rule = c("lambda.min", "lambda.1se"),
  Nonzero = c(n_nonzero_min, n_nonzero_1se),
  Selected_Features = c(
    paste(selected_names, collapse = ", "),
    paste(selected_names_1se, collapse = ", ")
  ),
  stringsAsFactors = FALSE
)

save_table_tex(
  df       = selected_df,
  filename = "tab_p2_lasso_sel.tex",
  caption  = "Lasso Selected Features Under Both Tuning Rules",
  label    = "tab:lasso_selected"
)

# ─────────────────────────────────────────────────────────────────────────────
# SAVE LASSO FIT
# ─────────────────────────────────────────────────────────────────────────────

save(lasso_fit, lasso_train_scores, lasso_coefs, lasso_coefs_1se,
     selected_names, selected_names_1se, eliminated_names,
     file = "output/lasso_fit.RData")
cat("[02c_lasso] Saved: output/lasso_fit.RData\n")

# ─────────────────────────────────────────────────────────────────────────────
# DONE
# ─────────────────────────────────────────────────────────────────────────────
cat("\n========== 02_lasso.R COMPLETE ==========\n")
