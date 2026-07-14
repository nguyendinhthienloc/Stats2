###############################################################################
# File:        04_enet.R
# Owner:       P5 (Tai)
# Problem:     Problem 4B — Elastic Net on Original Predictors
# Description: Fits Elastic Net regression for a grid of alpha values using
#              cross-validation.  Elastic Net combines L1 (Lasso) and L2
#              (Ridge) penalties.
#
# Background:
#   Elastic Net penalty = alpha * |beta| + (1-alpha) * beta^2
#   - alpha = 0  →  pure Ridge
#   - alpha = 1  →  pure Lasso
#   - alpha in (0,1) → a blend of both
#
#   Elastic Net is useful when there are groups of correlated predictors:
#   Lasso tends to pick only one from the group, while Elastic Net keeps
#   the whole group together.
#
# Depends on:  output/shared_data.RData  (produced by 01_data_prep_eda.R)
###############################################################################

# ─────────────────────────────────────────────────────────────────────────────
# 0.  SOURCE SHARED SETUP
# ─────────────────────────────────────────────────────────────────────────────

source("R_models/setup.R")
ensure_dirs()

cat("\n========== 04_enet.R ==========\n\n")

# ─────────────────────────────────────────────────────────────────────────────
# 1.  LOAD SHARED DATA
# ─────────────────────────────────────────────────────────────────────────────

load("output/shared_data.RData")
cat("[04b_enet] Loaded shared_data.RData\n")
cat("  Training samples:", nrow(x_train), "\n")
cat("  Predictors:      ", ncol(x_train), "\n\n")

# ─────────────────────────────────────────────────────────────────────────────
# 2.  DEFINE ALPHA GRID
# ─────────────────────────────────────────────────────────────────────────────
# We try 5 alpha values spanning the range between Ridge-like (0.10) and
# Lasso-like (0.90).  We exclude 0 and 1 because those are pure Ridge
# and Lasso, which were already fitted in 02b and 02c.

alpha_grid <- c(0.10, 0.25, 0.50, 0.75, 0.90)

cat("Alpha grid:", paste(alpha_grid, collapse = ", "), "\n\n")

# ─────────────────────────────────────────────────────────────────────────────
# 3.  FIT ELASTIC NET FOR EACH ALPHA
# ─────────────────────────────────────────────────────────────────────────────
# For each alpha, we run cv.glmnet with the SAME foldid so that all models
# are evaluated on identical folds → fair comparison.

enet_fits <- list()          # store cv.glmnet objects
enet_summary <- data.frame(  # summary table
  Alpha       = numeric(0),
  Lambda_min  = numeric(0),
  CV_MSE      = numeric(0),
  CV_RMSE     = numeric(0),
  Nonzero     = integer(0),
  stringsAsFactors = FALSE
)

for (alpha in alpha_grid) {
  cat("--- Fitting Elastic Net with alpha =", alpha, "---\n")
  
  fit <- fit_cv_glmnet(x_train, y_train, alpha = alpha, foldid = foldid)
  
  # Store the fit
  enet_fits[[as.character(alpha)]] <- fit
  
  # Extract CV error at lambda.min
  idx_min <- which(fit$lambda == fit$lambda.min)
  cv_mse  <- fit$cvm[idx_min]
  
  # Count non-zero coefficients
  n_nz <- count_nonzero(fit, s = "lambda.min")
  
  # Add row to summary
  enet_summary <- rbind(enet_summary, data.frame(
    Alpha      = alpha,
    Lambda_min = round(fit$lambda.min, 6),
    CV_MSE     = round(cv_mse, 4),
    CV_RMSE    = round(sqrt(cv_mse), 4),
    Nonzero    = n_nz,
    stringsAsFactors = FALSE
  ))
  
  cat("\n")
}

# ─────────────────────────────────────────────────────────────────────────────
# 4.  SELECT BEST ALPHA
# ─────────────────────────────────────────────────────────────────────────────
# The best alpha is the one with the LOWEST CV MSE (mean squared error).

best_row   <- which.min(enet_summary$CV_MSE)
best_alpha <- enet_summary$Alpha[best_row]
best_fit   <- enet_fits[[as.character(best_alpha)]]

cat("=== Best Alpha:", best_alpha, "===\n")
cat("  CV MSE: ", enet_summary$CV_MSE[best_row], "\n")
cat("  CV RMSE:", enet_summary$CV_RMSE[best_row], "\n")
cat("  Nonzero:", enet_summary$Nonzero[best_row], "\n\n")

# Extract best coefficients
best_coefs <- as.vector(coef(best_fit, s = "lambda.min"))
best_coef_names <- c("(Intercept)", predictors)
names(best_coefs) <- best_coef_names

print(enet_summary)
cat("\n")

###############################################################################
#                              FIGURES                                        #
###############################################################################

# ─────────────────────────────────────────────────────────────────────────────
# FIGURE 1:  CV ERROR COMPARISON ACROSS ALPHAS
# ─────────────────────────────────────────────────────────────────────────────
# Each line shows CV error vs log(lambda) for one alpha value.
# This helps visualise which alpha gives the best error curve.

cat("[04b_enet] Generating CV error comparison plot...\n")

# Choose distinct colours for each alpha
alpha_colors <- colorRampPalette(c("#2166AC", "#B2182B"))(length(alpha_grid))

pdf("output/figures/fig_p4_enet_cv.pdf", width = 9, height = 6)
par(mar = c(5, 4, 3, 8), xpd = TRUE)

# Determine axis limits across all fits
all_log_lambda <- unlist(lapply(enet_fits, function(f) log(f$lambda)))
all_cvm <- unlist(lapply(enet_fits, function(f) f$cvm))

plot(NULL,
     xlim = range(all_log_lambda),
     ylim = range(all_cvm),
     xlab = expression(log(lambda)),
     ylab = "Cross-Validation MSE",
     main = "Elastic Net: CV Error for Different Alpha Values",
     las = 1)

for (i in seq_along(alpha_grid)) {
  alpha_char <- as.character(alpha_grid[i])
  fit <- enet_fits[[alpha_char]]
  lines(log(fit$lambda), fit$cvm, col = alpha_colors[i], lwd = 2)
  
  # Mark lambda.min with a point
  idx_min <- which(fit$lambda == fit$lambda.min)
  points(log(fit$lambda.min), fit$cvm[idx_min],
         col = alpha_colors[i], pch = 16, cex = 1.5)
}

# Highlight the best alpha
legend("topright", inset = c(-0.22, 0),
       legend = paste0("alpha = ", alpha_grid,
                       ifelse(alpha_grid == best_alpha, " (BEST)", "")),
       col = alpha_colors, lwd = 2, bty = "n", cex = 0.75)

dev.off()
cat("[04b_enet] Saved: output/figures/fig_p4_enet_cv.pdf\n")

# ─────────────────────────────────────────────────────────────────────────────
# FIGURE 2:  BEST ELASTIC NET COEFFICIENT PLOT
# ─────────────────────────────────────────────────────────────────────────────

cat("[04b_enet] Generating best elastic net coefficient plot...\n")

coef_no_int <- best_coefs[-1]

pdf("output/figures/fig_p4_enet_coef.pdf", width = 8, height = 5)
par(mar = c(7, 4, 3, 2))

bar_colors_enet <- ifelse(coef_no_int != 0,
                          ifelse(coef_no_int > 0,
                                 project_colors["ElasticNet"],
                                 project_colors["OLS"]),
                          project_colors["neutral"])

barplot(
  coef_no_int,
  col    = bar_colors_enet,
  border = NA,
  main   = paste0("Elastic Net Coefficients (alpha = ", best_alpha,
                   ", lambda.min = ", round(best_fit$lambda.min, 4), ")"),
  ylab   = "Coefficient Value",
  las    = 2,
  cex.names = 0.8
)
abline(h = 0, col = "grey40", lty = 2)

dev.off()
cat("[04b_enet] Saved: output/figures/fig_p4_enet_coef.pdf\n")

###############################################################################
#                              TABLES                                         #
###############################################################################

# ─────────────────────────────────────────────────────────────────────────────
# TABLE 1:  ALPHA COMPARISON
# ─────────────────────────────────────────────────────────────────────────────

save_table_tex(
  df       = enet_summary,
  filename = "tab_p4_enet_alpha.tex",
  caption  = "Elastic Net: CV Performance Across Alpha Values",
  label    = "tab:enet_alpha"
)

# ─────────────────────────────────────────────────────────────────────────────
# TABLE 2:  BEST ELASTIC NET COEFFICIENTS
# ─────────────────────────────────────────────────────────────────────────────

enet_coef_df <- data.frame(
  Predictor   = names(best_coefs),
  Coefficient = round(best_coefs, 4),
  Status      = c("—", ifelse(best_coefs[-1] != 0, "Active", "Zero"))
)
rownames(enet_coef_df) <- NULL

save_table_tex(
  df       = enet_coef_df,
  filename = "tab_p4_enet_coef.tex",
  caption  = paste0("Elastic Net Coefficients at Best Alpha = ", best_alpha),
  label    = "tab:enet_coef"
)

# ─────────────────────────────────────────────────────────────────────────────
# SAVE ELASTIC NET FITS
# ─────────────────────────────────────────────────────────────────────────────

save(enet_fits, enet_summary, best_alpha, best_fit,
     file = "output/enet_fits.RData")
cat("[04b_enet] Saved: output/enet_fits.RData\n")

# ─────────────────────────────────────────────────────────────────────────────
# DONE
# ─────────────────────────────────────────────────────────────────────────────
cat("\n========== 04_enet.R COMPLETE ==========\n")
