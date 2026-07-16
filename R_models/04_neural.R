###############################################################################
# File:        04_neural.R
# Owner:       P5 (Tai)
# Problem:     Problem 4C — Fixed ReLU (Random Kitchen Sink) Features
# Description: Generates M = 200 random non-linear features using a fixed
#              random projection + ReLU activation, then fits Ridge, Lasso,
#              and Elastic Net on the expanded feature space.
#
# Background:
#   This is a simple form of "random features" (Rahimi & Recht, 2007):
#     1. Draw a random matrix A (p × M) and bias vector b (1 × M)
#     2. Compute H = ReLU(X %*% A + b)    where ReLU(z) = max(z, 0)
#     3. Fit linear models on H instead of X
#
#   This is NOT a trained neural network.  The weights A and b are fixed
#   (random), and only the output-layer coefficients are learned via
#   Ridge / Lasso / Elastic Net.  This lets us capture non-linear patterns
#   without the complexity of backpropagation.
#
# Depends on:  output/shared_data.RData  (01_data_prep_eda.R)
#              output/enet_fits.RData     (04_enet.R) — for best_alpha
###############################################################################

# ─────────────────────────────────────────────────────────────────────────────
# 0.  SOURCE SHARED SETUP
# ─────────────────────────────────────────────────────────────────────────────

source("R_models/setup.R")
ensure_dirs()

cat("\n========== 04_neural.R ==========\n\n")

# ─────────────────────────────────────────────────────────────────────────────
# 1.  LOAD SHARED DATA AND BEST ALPHA
# ─────────────────────────────────────────────────────────────────────────────

load("output/shared_data.RData")
load("output/enet_fits.RData")    # provides best_alpha

cat("[04c_neural] Loaded shared_data.RData and enet_fits.RData\n")
cat("  Training samples:", nrow(x_train), "\n")
cat("  Original predictors:", ncol(x_train), "\n")
cat("  Best alpha from 04b:", best_alpha, "\n\n")

# ─────────────────────────────────────────────────────────────────────────────
# 2.  DEFINE ReLU ACTIVATION
# ─────────────────────────────────────────────────────────────────────────────
# ReLU(z) = max(z, 0)
# pmax() is the vectorised version: it returns element-wise max of z and 0.

relu <- function(z) pmax(z, 0)

# ─────────────────────────────────────────────────────────────────────────────
# 3.  RANDOM PROJECTION PARAMETERS
# ─────────────────────────────────────────────────────────────────────────────

M <- 200L   # number of random features (hidden units)
p <- ncol(x_train)   # number of original predictors (14)

cat("Generating", M, "random features from", p, "original predictors\n")

# Set the seed so the random matrix is reproducible
set.seed(seeds$features)

# A: random projection matrix, p × M
#    Entries drawn from N(0, 1/p)
#    The 1/p variance scaling prevents the pre-activation values from
#    being too large or too small.
A <- matrix(rnorm(p * M, mean = 0, sd = 1 / sqrt(p)),
            nrow = p, ncol = M)

# bias: 1 × M vector
#    Entries drawn from Uniform(0, 2*pi)
bias <- matrix(runif(M, min = 0, max = 2 * pi),
               nrow = 1, ncol = M)

cat("  A matrix:   ", nrow(A), "x", ncol(A), "\n")
cat("  bias vector:", ncol(bias), "values in [0, 2*pi]\n\n")

# ─────────────────────────────────────────────────────────────────────────────
# 4.  COMPUTE RANDOM FEATURES
# ─────────────────────────────────────────────────────────────────────────────
# H = ReLU( X %*% A + bias )
#
# X is n × p,  A is p × M  →  X %*% A is n × M
# We broadcast the bias vector to n × M by repeating it for each row.

# Training features
H_train_raw <- relu(
  x_train %*% A +
    matrix(bias, nrow = nrow(x_train), ncol = M, byrow = TRUE)
)

# Test features
H_test_raw <- relu(
  x_test %*% A +
    matrix(bias, nrow = nrow(x_test), ncol = M, byrow = TRUE)
)

cat("H_train dimensions:", nrow(H_train_raw), "x", ncol(H_train_raw), "\n")
cat("H_test  dimensions:", nrow(H_test_raw),  "x", ncol(H_test_raw),  "\n\n")

# ─────────────────────────────────────────────────────────────────────────────
# 5.  SCALE THE RANDOM FEATURES
# ─────────────────────────────────────────────────────────────────────────────
# Just like with the original predictors, we standardise the neural features.
# Fit on H_train only, apply to both.

h_scaler <- fit_scaler(H_train_raw)
H_train  <- apply_scaler(H_train_raw, h_scaler)
H_test   <- apply_scaler(H_test_raw,  h_scaler)

cat("Neural features scaled (H_train mean ≈ 0, sd ≈ 1)\n\n")

# ─────────────────────────────────────────────────────────────────────────────
# 6.  FOLDID — reuse the same folds (matches training rows)
# ─────────────────────────────────────────────────────────────────────────────
# The foldid vector from shared_data already has length = nrow(x_train),
# and H_train has the same number of rows, so we reuse it directly.

cat("Using the same foldid (length =", length(foldid), ") for neural models\n\n")

# ─────────────────────────────────────────────────────────────────────────────
# 7.  FIT MODELS ON NEURAL FEATURES
# ─────────────────────────────────────────────────────────────────────────────

# 7a. Ridge on H_train
cat("=== Neural Ridge ===\n")
neural_ridge_fit <- fit_cv_glmnet(H_train, y_train, alpha = 0, foldid = foldid)
n_nz_ridge <- count_nonzero(neural_ridge_fit, s = "lambda.min")

# 7b. Lasso on H_train
cat("\n=== Neural Lasso ===\n")
neural_lasso_fit <- fit_cv_glmnet(H_train, y_train, alpha = 1, foldid = foldid)
n_nz_lasso <- count_nonzero(neural_lasso_fit, s = "lambda.min")

# 7c. Elastic Net on H_train (using best_alpha from 04b)
cat("\n=== Neural Elastic Net (alpha =", best_alpha, ") ===\n")
neural_enet_fit <- fit_cv_glmnet(H_train, y_train, alpha = best_alpha, foldid = foldid)
n_nz_enet <- count_nonzero(neural_enet_fit, s = "lambda.min")

# ─────────────────────────────────────────────────────────────────────────────
# 8.  TRAINING METRICS
# ─────────────────────────────────────────────────────────────────────────────

pred_nr <- predict(neural_ridge_fit, newx = H_train, s = "lambda.min")
pred_nl <- predict(neural_lasso_fit, newx = H_train, s = "lambda.min")
pred_ne <- predict(neural_enet_fit,  newx = H_train, s = "lambda.min")

scores_nr <- score_regression(y_train, as.vector(pred_nr))
scores_nl <- score_regression(y_train, as.vector(pred_nl))
scores_ne <- score_regression(y_train, as.vector(pred_ne))

# CV RMSE
cv_idx_nr <- which(neural_ridge_fit$lambda == neural_ridge_fit$lambda.min)
cv_idx_nl <- which(neural_lasso_fit$lambda == neural_lasso_fit$lambda.min)
cv_idx_ne <- which(neural_enet_fit$lambda  == neural_enet_fit$lambda.min)

neural_summary <- data.frame(
  Model       = c("Neural Ridge", "Neural Lasso",
                   paste0("Neural ENet (a=", best_alpha, ")")),
  Alpha       = c(0, 1, best_alpha),
  Lambda_min  = round(c(neural_ridge_fit$lambda.min,
                         neural_lasso_fit$lambda.min,
                         neural_enet_fit$lambda.min), 6),
  Train_RMSE  = round(c(scores_nr$RMSE, scores_nl$RMSE, scores_ne$RMSE), 4),
  Train_MAE   = round(c(scores_nr$MAE,  scores_nl$MAE,  scores_ne$MAE), 4),
  CV_RMSE     = round(c(sqrt(neural_ridge_fit$cvm[cv_idx_nr]),
                         sqrt(neural_lasso_fit$cvm[cv_idx_nl]),
                         sqrt(neural_enet_fit$cvm[cv_idx_ne])), 4),
  Active_Features = c(n_nz_ridge, n_nz_lasso, n_nz_enet),
  stringsAsFactors = FALSE
)

cat("\n--- Neural Feature Models Summary ---\n")
print(neural_summary)
cat("\n")

###############################################################################
#                              FIGURES                                        #
###############################################################################

# ─────────────────────────────────────────────────────────────────────────────
# FIGURE 1:  NEURAL RIDGE CV PLOT
# ─────────────────────────────────────────────────────────────────────────────

cat("[04c_neural] Generating neural Ridge CV plot...\n")

pdf("output/figures/fig_p4_neural_ridge_cv.pdf", width = 8.5, height = 5.5)
par(mar = c(5, 4, 4, 2))
plot(neural_ridge_fit, main = "Neural Ridge: Cross-Validation Error",
  xlab = expression(log(lambda)), ylab = "CV MSE", col = project_colors["NeuralRidge"],
  lwd = 2)
abline(v = log(neural_ridge_fit$lambda.min), col = project_colors["NeuralRidge"], lty = 2)
dev.off()
cat("[04c_neural] Saved: output/figures/fig_p4_neural_ridge_cv.pdf\n")

# ─────────────────────────────────────────────────────────────────────────────
# FIGURE 2:  NEURAL LASSO CV PLOT
# ─────────────────────────────────────────────────────────────────────────────

cat("[04c_neural] Generating neural Lasso CV plot...\n")

pdf("output/figures/fig_p4_neural_lasso_cv.pdf", width = 8.5, height = 5.5)
par(mar = c(5, 4, 4, 2))
plot(neural_lasso_fit, main = "Neural Lasso: Cross-Validation Error",
  xlab = expression(log(lambda)), ylab = "CV MSE", col = project_colors["NeuralLasso"],
  lwd = 2)
abline(v = log(neural_lasso_fit$lambda.min), col = project_colors["NeuralLasso"], lty = 2)
dev.off()
cat("[04c_neural] Saved: output/figures/fig_p4_neural_lasso_cv.pdf\n")

# ─────────────────────────────────────────────────────────────────────────────
# FIGURE 3:  ACTIVE FEATURES COMPARISON
# ─────────────────────────────────────────────────────────────────────────────
# Bar chart showing how many of the 200 random features each model uses.

cat("[04c_neural] Generating active features comparison...\n")

pdf("output/figures/fig_p4_neural_active.pdf", width = 8, height = 5.5)
par(mar = c(6, 4, 4, 2))

active_counts <- c(n_nz_ridge, n_nz_lasso, n_nz_enet)
active_names  <- c("Neural\nRidge", "Neural\nLasso",
                    paste0("Neural\nENet\n(a=", best_alpha, ")"))

bp <- barplot(
  active_counts,
  names.arg = active_names,
  col       = c(project_colors["NeuralRidge"],
                project_colors["NeuralLasso"],
                project_colors["NeuralENet"]),
  border    = NA,
  main      = paste("Active Features Out of", M, "Random Features"),
  ylab      = "Number of Active (Non-Zero) Features",
  ylim      = c(0, M + 20),
  las       = 1
)

# Add count labels on top of bars
text(bp, active_counts + 8, labels = active_counts, cex = 0.9, font = 2)

# Add a reference line at M = 200
abline(h = M, col = project_colors["neutral"], lty = 2)
text(bp[1], M + 10, labels = paste("M =", M), col = project_colors["neutral"],
     adj = 0, cex = 0.8)

dev.off()
cat("[04c_neural] Saved: output/figures/fig_p4_neural_active.pdf\n")

###############################################################################
#                              TABLES                                         #
###############################################################################

# ─────────────────────────────────────────────────────────────────────────────
# TABLE:  NEURAL FEATURES MODEL SUMMARY
# ─────────────────────────────────────────────────────────────────────────────

save_table_tex(
  df       = neural_summary,
  filename = "tab_p4_neural_summary.tex",
  caption  = "Neural Random Features: Model Summary (M = 200)",
  label    = "tab:neural_summary"
)

# ─────────────────────────────────────────────────────────────────────────────
# SAVE NEURAL FITS AND PROJECTION PARAMETERS
# ─────────────────────────────────────────────────────────────────────────────
# We save A, bias, H_train, H_test, the scaler, and all three fits.
# 04_holdout.R will need H_test to make predictions.

save(neural_ridge_fit, neural_lasso_fit, neural_enet_fit,
     A, bias, H_train, H_test, h_scaler,
     neural_summary,
     file = "output/neural_fits.RData")
cat("[04c_neural] Saved: output/neural_fits.RData\n")

# ─────────────────────────────────────────────────────────────────────────────
# DONE
# ─────────────────────────────────────────────────────────────────────────────
cat("\n========== 04_neural.R COMPLETE ==========\n")
