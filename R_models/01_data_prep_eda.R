###############################################################################
# File:        01_data_prep_eda.R
# Owner:       P1 (Loc)
# Problem:     Problem 1 — Data Loading, Preprocessing, and EDA
# Description: This script loads the fat.csv dataset, selects the relevant
#              columns, splits into train/test, standardises predictors,
#              creates CV fold IDs, and saves everything to shared_data.RData.
#              It also produces Exploratory Data Analysis (EDA) figures and
#              a summary statistics table for the LaTeX report.
#
# IMPORTANT:   This script MUST be run FIRST.  All other scripts depend on
#              the shared_data.RData file that this script produces.
###############################################################################

# ─────────────────────────────────────────────────────────────────────────────
# 0.  SOURCE SHARED SETUP
# ─────────────────────────────────────────────────────────────────────────────
# source() executes setup.R so we inherit config, seeds, and helper fns.

setup_file <- if (file.exists("R_models/setup.R")) "R_models/setup.R" else "setup.R"
source(setup_file)
ensure_dirs()   # create output/figures/ and output/tables/ if missing

cat("\n========== 01_data_prep_eda.R ==========\n\n")

# ─────────────────────────────────────────────────────────────────────────────
# 1.  LOAD THE RAW DATA
# ─────────────────────────────────────────────────────────────────────────────

fat_raw <- find_exam_data(config$file)

cat("Dimensions of raw data:", nrow(fat_raw), "rows x", ncol(fat_raw), "cols\n")
cat("Column names:\n")
cat(paste(" ", colnames(fat_raw), collapse = "\n"), "\n\n")

# ─────────────────────────────────────────────────────────────────────────────
# 2.  DEFINE PREDICTORS
# ─────────────────────────────────────────────────────────────────────────────
# We take ALL column names, then REMOVE the ones listed in config$excluded.
# setdiff(A, B) returns elements in A that are NOT in B.
#
# Expected predictors (14):
#   age, weight, height, adipos, neck, chest, abdom, hip,
#   thigh, knee, ankle, biceps, forearm, wrist

predictors <- setdiff(colnames(fat_raw), config$excluded)

cat("Number of predictors:", length(predictors), "\n")
cat("Predictors:", paste(predictors, collapse = ", "), "\n\n")

# ─────────────────────────────────────────────────────────────────────────────
# 3.  BUILD ANALYSIS DATA
# ─────────────────────────────────────────────────────────────────────────────
# We keep only the response column + the 14 predictor columns.
# This is the "clean" dataset used for all modelling.

analysis_data <- fat_raw[, c(config$response, predictors)]

cat("analysis_data dimensions:", nrow(analysis_data), "x", ncol(analysis_data), "\n")

# ─────────────────────────────────────────────────────────────────────────────
# 4.  VALIDATE THE DATA
# ─────────────────────────────────────────────────────────────────────────────
# Check 1: No missing values (NA)
# Check 2: All columns are numeric (needed for matrix operations)

na_count <- sum(is.na(analysis_data))
cat("Missing values (NA):", na_count, "\n")
if (na_count > 0) {
  warning("There are missing values! Investigate before proceeding.")
}

all_numeric <- all(sapply(analysis_data, is.numeric))
cat("All columns numeric?", all_numeric, "\n\n")
if (!all_numeric) {
  stop("Some columns are not numeric. Check your data!")
}

# ─────────────────────────────────────────────────────────────────────────────
# 5.  TRAIN / TEST SPLIT  (80 / 20)
# ─────────────────────────────────────────────────────────────────────────────
# split_rows() returns a list with $train and $test index vectors.
# We use seeds$split so the split is reproducible.

idx <- split_rows(n = nrow(analysis_data), train_frac = 0.80, seed = seeds$split)

train_id <- idx$train
test_id  <- idx$test

# ─────────────────────────────────────────────────────────────────────────────
# 6.  CREATE MATRICES
# ─────────────────────────────────────────────────────────────────────────────
# glmnet requires:
#   x = a numeric MATRIX of predictors  (not a data.frame!)
#   y = a numeric VECTOR of responses
#
# as.matrix() converts the data.frame columns to a matrix.

# RAW (un-scaled) predictor matrices
x_raw_train <- as.matrix(analysis_data[train_id, predictors])
x_raw_test  <- as.matrix(analysis_data[test_id,  predictors])

# Response vectors
y_train <- analysis_data[train_id, config$response]
y_test  <- analysis_data[test_id,  config$response]

cat("Training set: ", length(y_train), "observations\n")
cat("Test set:     ", length(y_test),  "observations\n\n")

# ─────────────────────────────────────────────────────────────────────────────
# 7.  STANDARDISE (SCALE) PREDICTORS
# ─────────────────────────────────────────────────────────────────────────────
# Step 1: Fit the scaler on TRAINING data only
# Step 2: Apply that same scaler to both train and test
#
# Why not fit on test data?  Because in real life you don't have test data
# at training time.  Using test statistics would be "data leakage".

x_prep <- fit_scaler(x_raw_train)

x_train <- apply_scaler(x_raw_train, x_prep)
x_test  <- apply_scaler(x_raw_test,  x_prep)

cat("x_train scaled: mean ≈ 0, sd ≈ 1 for each column\n")
cat("  Column means (should be ~0):", round(colMeans(x_train), 4)[1:3], "...\n")
cat("  Column SDs   (should be ~1):", round(apply(x_train, 2, sd), 4)[1:3], "...\n\n")

# ─────────────────────────────────────────────────────────────────────────────
# 8.  CREATE FOLD IDS FOR CROSS-VALIDATION
# ─────────────────────────────────────────────────────────────────────────────
# We create ONE set of fold IDs and share it across all models.
# This ensures fair comparison: every model is evaluated on the same folds.

foldid <- make_foldid(n = nrow(x_train), nfolds = 5L, seed = seeds$cv)

# ─────────────────────────────────────────────────────────────────────────────
# 9.  SAVE SHARED DATA
# ─────────────────────────────────────────────────────────────────────────────
# All downstream scripts will load this file.

save(
  x_train, x_test,
  y_train, y_test,
  foldid,
  train_id, test_id,
  x_prep,
  config, seeds,
  analysis_data,
  predictors,
  file = "output/shared_data.RData"
)

cat("[01_data_eda] Saved output/shared_data.RData\n\n")

###############################################################################
#                       EXPLORATORY DATA ANALYSIS (EDA)                       #
#           All plots use TRAINING data only to avoid data leakage.           #
###############################################################################

# We'll use the training subset for all EDA
train_data <- analysis_data[train_id, ]

# ─────────────────────────────────────────────────────────────────────────────
# EDA PLOT 1:  CORRELATION HEATMAP
# ─────────────────────────────────────────────────────────────────────────────
# A correlation heatmap shows pairwise Pearson correlations between all
# variables (including the response).  Strong correlations suggest
# multicollinearity among predictors, which motivates regularization.

cat("[EDA] Generating correlation heatmap...\n")

# Compute correlation matrix (training data only)
cor_matrix <- cor(train_data)

pdf("output/figures/fig_p1_correlation.pdf", width = 10, height = 9)

# Set margins: bottom, left, top, right
par(mar = c(6, 6, 3, 2))

# image() draws a matrix as coloured tiles
# We reverse the row order so the diagonal goes top-left to bottom-right
n_vars <- ncol(cor_matrix)
image(
  x    = 1:n_vars,
  y    = 1:n_vars,
  z    = cor_matrix[, n_vars:1],   # flip vertically
  axes = FALSE,
  col  = colorRampPalette(c("#2166AC", "white", "#B2182B"))(100),
  zlim = c(-1, 1),
  xlab = "", ylab = "",
  main = "Correlation Heatmap (Training Data)"
)
axis(1, at = 1:n_vars, labels = colnames(cor_matrix), las = 2, cex.axis = 0.7)
axis(2, at = 1:n_vars, labels = rev(colnames(cor_matrix)), las = 2, cex.axis = 0.7)

# Add correlation values as text labels
for (i in 1:n_vars) {
  for (j in 1:n_vars) {
    text(i, n_vars - j + 1, labels = round(cor_matrix[i, j], 2),
         cex = 0.5, col = ifelse(abs(cor_matrix[i, j]) > 0.6, "white", "black"))
  }
}

dev.off()
cat("[EDA] Saved: output/figures/fig_p1_correlation.pdf\n")

# ─────────────────────────────────────────────────────────────────────────────
# EDA PLOT 2:  RESPONSE DISTRIBUTION HISTOGRAM
# ─────────────────────────────────────────────────────────────────────────────
# Shows the distribution of the response variable (brozek) in training data.
# A roughly normal distribution is ideal for linear regression.

cat("[EDA] Generating response distribution histogram...\n")

pdf("output/figures/fig_p1_dist.pdf", width = 7, height = 5)
par(mar = c(5, 4, 3, 2))

hist(
  train_data[[config$response]],
  breaks = 20,
  col    = project_colors["OLS"],
  border = "white",
  main   = paste("Distribution of", config$response, "(Training Data)"),
  xlab   = config$response,
  ylab   = "Frequency",
  las    = 1
)

# Add a vertical line at the mean
abline(v = mean(train_data[[config$response]]),
       col = project_colors["Lasso"], lwd = 2, lty = 2)
legend("topright",
       legend = paste("Mean =", round(mean(train_data[[config$response]]), 2)),
       col = project_colors["Lasso"], lwd = 2, lty = 2, bty = "n")

dev.off()
cat("[EDA] Saved: output/figures/fig_p1_dist.pdf\n")

# ─────────────────────────────────────────────────────────────────────────────
# EDA PLOT 3:  BOXPLOTS OF PREDICTORS
# ─────────────────────────────────────────────────────────────────────────────
# Boxplots let us quickly compare the spread and outliers across predictors.
# We use the SCALED training data so all predictors are on the same scale.

cat("[EDA] Generating predictor boxplots...\n")

pdf("output/figures/fig_p1_boxplots.pdf", width = 10, height = 6)
par(mar = c(7, 4, 3, 2))

boxplot(
  as.data.frame(x_train),
  col      = project_colors["Ridge"],
  border   = "#333333",
  main     = "Boxplots of Standardised Predictors (Training Data)",
  ylab     = "Standardised Value",
  las      = 2,         # rotate x-axis labels
  cex.axis = 0.8,
  outline  = TRUE       # show outliers
)
abline(h = 0, col = project_colors["neutral"], lty = 2)

dev.off()
cat("[EDA] Saved: output/figures/fig_p1_boxplots.pdf\n")

# ─────────────────────────────────────────────────────────────────────────────
# EDA PLOT 4:  PAIRWISE SCATTER OF TOP CORRELATED PREDICTORS
# ─────────────────────────────────────────────────────────────────────────────
# We pick the top 4 predictors most correlated with the response and create
# a scatter-plot matrix (pairs plot).

cat("[EDA] Generating pairwise scatter plot...\n")

# Correlations between each predictor and the response
cor_with_response <- cor(train_data[, predictors], train_data[[config$response]])
cor_with_response <- sort(abs(cor_with_response[, 1]), decreasing = TRUE)

# Pick top 4
top_preds <- names(cor_with_response)[1:4]
cat("  Top 4 predictors correlated with", config$response, ":",
    paste(top_preds, collapse = ", "), "\n")

pdf("output/figures/fig_p1_pairwise.pdf", width = 9, height = 9)

pairs(
  train_data[, c(config$response, top_preds)],
  col  = adjustcolor(project_colors["OLS"], alpha.f = 0.5),
  pch  = 16,
  cex  = 0.7,
  main = paste("Pairwise Scatter: Top 4 Predictors vs", config$response),
  lower.panel = NULL   # show scatter in upper panel only
)

dev.off()
cat("[EDA] Saved: output/figures/fig_p1_pairwise.pdf\n")

# ─────────────────────────────────────────────────────────────────────────────
# EDA TABLE:  SUMMARY STATISTICS
# ─────────────────────────────────────────────────────────────────────────────
# Generate a table of mean, sd, min, median, max for each variable in
# the training data.

cat("[EDA] Generating summary statistics table...\n")

summary_stats <- data.frame(
  Variable = colnames(train_data),
  Mean     = sapply(train_data, mean),
  SD       = sapply(train_data, sd),
  Min      = sapply(train_data, min),
  Median   = sapply(train_data, median),
  Max      = sapply(train_data, max),
  row.names = NULL
)

# Round for readability
summary_stats[, -1] <- round(summary_stats[, -1], 3)

print(summary_stats)

save_table_tex(
  df       = summary_stats,
  filename = "tab_p1_summary.tex",
  caption  = "Summary Statistics of Training Data",
  label    = "tab:summary_stats"
)

# ─────────────────────────────────────────────────────────────────────────────
# DONE
# ─────────────────────────────────────────────────────────────────────────────
cat("\n========== 01_data_prep_eda.R COMPLETE ==========\n")
cat("Next step: run 02_ols.R, 02_ridge.R, 02_lasso.R\n")
