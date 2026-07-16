###############################################################################
# File:        setup.R
# Owner:       ALL (shared configuration)
# Problem:     N/A — this file is sourced by every other script
# Description: Central configuration and helper functions for the
#              body-fat prediction project (Group 01).
#
#              This script does NOT run any analysis on its own.
#              Instead, every other R script starts with:
#                  source("R_models/setup.R")
#              so that everyone shares the same settings and utilities.
###############################################################################

# ─────────────────────────────────────────────────────────────────────────────
# 0.  LOAD REQUIRED PACKAGES
# ─────────────────────────────────────────────────────────────────────────────
# Resolve paths from this file instead of assuming a particular working directory.
setup_source <- tryCatch(sys.frame(1)$ofile, error = function(e) NULL)
if (is.null(setup_source) || !nzchar(setup_source)) {
  setup_source <- if (file.exists("R_models/setup.R")) {
    "R_models/setup.R"
  } else {
    "setup.R"
  }
}

SETUP_FILE <- normalizePath(setup_source, winslash = "/", mustWork = TRUE)
PROJECT_ROOT <- normalizePath(file.path(dirname(SETUP_FILE), ".."),
                              winslash = "/", mustWork = TRUE)

if (!identical(normalizePath(getwd(), winslash = "/"), PROJECT_ROOT)) {
  setwd(PROJECT_ROOT)
}

# Prefer the restored project library, but do not source renv/activate.R here.
# The autoloader can be slow or fragile in editor sessions; this direct library
# discovery keeps scripts reproducible across Windows, macOS, and Linux.
project_library_root <- file.path(PROJECT_ROOT, "renv", "library")
project_libraries <- if (dir.exists(project_library_root)) {
  list.dirs(project_library_root, recursive = TRUE, full.names = TRUE)
} else {
  character(0)
}

project_library <- project_libraries[
  file.exists(file.path(project_libraries, "renv", "DESCRIPTION"))
]

if (length(project_library) > 0) {
  project_library <- project_library[[length(project_library)]]
  .libPaths(c(project_library, .libPaths()))
} else {
  stop("Project renv library was not found. From the project root, run: ",
       "Rscript -e \"if (!requireNamespace('renv', quietly = TRUE)) ",
       "install.packages('renv', repos = 'https://cloud.r-project.org'); ",
       "renv::restore(prompt = FALSE)\"",
       call. = FALSE)
}

Sys.setenv(RENV_PROJECT = PROJECT_ROOT)

log_line <- function(level, ..., .sep = "") {
  text <- paste0(..., collapse = .sep)
  cat(sprintf(">>> [%s] %-5s %s\n", format(Sys.time(), "%H:%M:%S"), level, text))
}

log_step <- function(...) log_line("STEP", ...)
log_info <- function(...) log_line("INFO", ...)
log_warn <- function(...) log_line("WARN", ...)

abort_run <- function(...) {
  text <- paste(..., collapse = "")
  stop(sprintf(">>> [%s] ERROR %s", format(Sys.time(), "%H:%M:%S"), text),
       call. = FALSE)
}

lockfile <- file.path(PROJECT_ROOT, "renv.lock")
if (!file.exists(lockfile)) {
  abort_run("renv lockfile not found: ", lockfile)
}

required_packages <- c("glmnet", "xtable", "jsonlite", "rlang")

# requireNamespace() catches broken or incompatible installs; checking only
# installed.packages() incorrectly reports those packages as usable.
package_errors <- vapply(required_packages, function(package) {
  tryCatch({
    suppressWarnings(loadNamespace(package))
    ""
  }, error = function(e) conditionMessage(e))
}, character(1))

failed_packages <- names(package_errors)[nzchar(package_errors)]
if (length(failed_packages) > 0) {
  details <- paste(sprintf("  - %s: %s", failed_packages,
                           package_errors[failed_packages]), collapse = "\n")
  abort_run("Required R packages are unavailable:\n", details,
            "\nRun from the project root: ",
            "Rscript -e \"renv::restore(prompt = FALSE)\"")
}

suppressWarnings(suppressPackageStartupMessages({
  library(glmnet)    # Ridge, Lasso, Elastic Net via cv.glmnet()
  library(xtable)    # Convert data frames to LaTeX tables
}))

# ─────────────────────────────────────────────────────────────────────────────
# 1.  GROUP INFORMATION
# ─────────────────────────────────────────────────────────────────────────────
# Group 01 is an ODD group, so we use:
#   • Dataset : fat.csv
#   • Response: brozek  (body-fat percentage estimated by Brozek's equation)

GROUP_NUMBER <- 1L   # L suffix means "integer" in R

# ─────────────────────────────────────────────────────────────────────────────
# 2.  SEEDS — reproducibility is critical!
# ─────────────────────────────────────────────────────────────────────────────
# Every random operation MUST be preceded by set.seed() with the appropriate
# seed so that results are identical every time the script is run.
#
# We store them in a named list for easy reference:
#   seeds$split    → used when splitting data into train / test
#   seeds$cv       → used when creating cross-validation fold IDs
#   seeds$features → used when generating random neural-network features

seeds <- list(
  split    = 240201L,
  cv       = 240301L,
  features = 240401L
)

# ─────────────────────────────────────────────────────────────────────────────
# 3.  DATASET CONFIGURATION
# ─────────────────────────────────────────────────────────────────────────────
# config is a named list that tells every script:
#   • file     : path to the CSV (relative to project root)
#   • response : which column is the target variable (y)
#   • excluded : columns to DROP before modelling
#
# Why exclude siri, density, free?
#   These are alternative body-fat measures or are derived from the same
#   measurement, so including them would be "data leakage".

config <- list(
  file     = "data/fat.csv",
  response = "brozek",
  excluded = c("brozek", "siri", "density", "free")
)

# ─────────────────────────────────────────────────────────────────────────────
# 4.  COLOUR PALETTE  (professional, colour-blind friendly)
# ─────────────────────────────────────────────────────────────────────────────
# We define a shared palette so all figures look consistent.

project_colors <- c(
  OLS      = "#2166AC",   # dark blue

  Ridge    = "#4393C3",   # medium blue
  Lasso    = "#D6604D",   # red-orange
  ElasticNet = "#B2182B", # dark red
  NeuralRidge  = "#762A83",  # purple
  NeuralLasso  = "#9970AB",  # light purple
  NeuralENet   = "#C2A5CF",  # lavender
  highlight    = "#F4A582",  # salmon (for highlights)
  neutral      = "#999999"   # grey
)

###############################################################################
#                         HELPER FUNCTIONS                                    #
###############################################################################

# ─────────────────────────────────────────────────────────────────────────────
# ensure_dirs()
# ─────────────────────────────────────────────────────────────────────────────
# Purpose : Create the output directories if they do not already exist.
# Usage   : Call once at the top of every analysis script.
#
# dir.create(..., recursive = TRUE) builds the whole directory tree.
# showWarnings = FALSE means it won't complain if the folder already exists.

ensure_dirs <- function() {
  dir.create("output/figures", recursive = TRUE, showWarnings = FALSE)
  dir.create("output/tables",  recursive = TRUE, showWarnings = FALSE)
  log_info("Output directories ready: output/figures, output/tables")
}

# ─────────────────────────────────────────────────────────────────────────────
# save_table_tex(df, filename, caption, label)
# ─────────────────────────────────────────────────────────────────────────────
# Purpose : Save a data.frame as a standalone LaTeX table (.tex file).
# Args    :
#   df       — the data.frame to convert
#   filename — file name only (e.g. "tab_summary.tex"); saved to output/tables/
#   caption  — LaTeX caption text
#   label    — LaTeX label for cross-referencing (e.g. "tab:summary")
#
# The function uses xtable to create the LaTeX code and writes it to disk.
# 'booktabs = TRUE' uses \toprule / \midrule / \bottomrule for professional
# looking tables (requires the booktabs LaTeX package).

save_table_tex <- function(df, filename, caption = "", label = "") {
  filepath <- file.path("output", "tables", filename)
  table_scale <- if (ncol(df) >= 7L) {
    0.88
  } else if (ncol(df) >= 6L) {
    0.92
  } else {
    NULL
  }

  sanitize_colnames <- function(x) {
    gsub("_", "\\_", x, fixed = TRUE)
  }
  
  # Create the xtable object
  tbl <- xtable::xtable(df, caption = caption, label = label)
  
  # Print (= write) to a .tex file
  print(tbl,
        file            = filepath,
        type            = "latex",
        booktabs        = TRUE,          # professional horizontal rules
        include.rownames = TRUE,         # keep row names
        caption.placement = "top",       # caption above the table
        sanitize.text.function = identity, # preserve intentional cell math
        sanitize.colnames.function = sanitize_colnames,
        scalebox = table_scale
  )
  
  cat("[save_table_tex] Written:", filepath, "\n")
}

# ─────────────────────────────────────────────────────────────────────────────
# find_exam_data(path)
# ─────────────────────────────────────────────────────────────────────────────
# Purpose : Locate and load the CSV data file.
# Returns : A data.frame.
#
# This is a thin wrapper so that every script uses the same loading logic.

find_exam_data <- function(path) {
  if (!file.exists(path)) {
    stop("[find_exam_data] File not found: ", path,
         "\n  Make sure you are running from the project root directory.")
  }
  df <- read.csv(path, stringsAsFactors = FALSE)
  cat("[find_exam_data] Loaded", nrow(df), "rows x", ncol(df), "cols from", path, "\n")
  return(df)
}

# ─────────────────────────────────────────────────────────────────────────────
# split_rows(n, train_frac, seed)
# ─────────────────────────────────────────────────────────────────────────────
# Purpose : Randomly assign row indices to a TRAINING set or a TEST set.
# Args    :
#   n          — total number of observations (rows)
#   train_frac — proportion allocated to training (e.g. 0.80)
#   seed       — random seed for reproducibility
# Returns : A list with two integer vectors:
#   $train — indices for training rows
#   $test  — indices for test rows
#
# Example:
#   idx <- split_rows(252, 0.80, seed = 240201)
#   train_data <- full_data[idx$train, ]

split_rows <- function(n, train_frac = 0.80, seed) {
  set.seed(seed)
  # sample() picks 'size' values from 1:n without replacement
  train_id <- sort(sample(seq_len(n), size = floor(n * train_frac)))
  test_id  <- setdiff(seq_len(n), train_id)
  
  cat("[split_rows] Train:", length(train_id),
      " | Test:", length(test_id),
      " (seed =", seed, ")\n")
  
  return(list(train = train_id, test = test_id))
}

# ─────────────────────────────────────────────────────────────────────────────
# fit_scaler(X_train)
# ─────────────────────────────────────────────────────────────────────────────
# Purpose : Compute column means and standard deviations from TRAINING data.
# Why?    : We must standardize features (zero mean, unit variance) before
#           Ridge / Lasso so that regularization treats all predictors equally.
# IMPORTANT: The scaler is fitted on training data ONLY to avoid data leakage.
# Returns : A list with $center (means) and $scale (std devs).

fit_scaler <- function(X_train, tol = 1e-12) {
  X_train <- as.matrix(X_train)
  centers <- colMeans(X_train)
  scales <- apply(X_train, 2, sd)
  keep <- is.finite(scales) & scales > tol

  if (!any(keep)) {
    abort_run("No nonconstant training predictor remains after scaling checks")
  }

  dropped <- colnames(X_train)[!keep]
  log_info("Scaler fitted on ", sum(keep), "/", ncol(X_train), " columns")
  if (length(dropped) > 0) {
    log_warn("Dropped constant/non-finite training columns: ",
             paste(dropped, collapse = ", "))
  }

  list(
    center = centers[keep],
    scale = scales[keep],
    keep = keep,
    dropped = dropped
  )
}

# ─────────────────────────────────────────────────────────────────────────────
# apply_scaler(X, scaler)
# ─────────────────────────────────────────────────────────────────────────────
# Purpose : Apply a previously fitted scaler to a data matrix.
# Formula : X_scaled[, j] = (X[, j] - center_j) / scale_j
# Returns : A scaled matrix.

apply_scaler <- function(X, scaler) {
  X <- as.matrix(X)[, scaler$keep, drop = FALSE]
  # scale() is a built-in R function that subtracts center and divides by scale
  X_scaled <- scale(X, center = scaler$center, scale = scaler$scale)
  # Remove the attributes that scale() attaches (they clutter downstream code)
  attr(X_scaled, "scaled:center") <- NULL
  attr(X_scaled, "scaled:scale")  <- NULL
  return(X_scaled)
}

# ─────────────────────────────────────────────────────────────────────────────
# make_foldid(n, nfolds, seed)
# ─────────────────────────────────────────────────────────────────────────────
# Purpose : Create a vector of fold IDs for K-fold cross-validation.
# Why?    : By using the SAME foldid vector for Ridge, Lasso, and Elastic Net,
#           we ensure fair comparison — every model sees the same folds.
# Args    :
#   n      — number of training observations
#   nfolds — number of folds (default 5, as required by the project rubric)
#   seed   — random seed
# Returns : An integer vector of length n, each element in {1, 2, ..., nfolds}.

make_foldid <- function(n, nfolds = 5L, seed) {
  if (nfolds < 3L || nfolds > n) {
    abort_run("Cross-validation requires 3 <= nfolds <= n")
  }
  set.seed(seed)
  # rep_len repeats 1:nfolds until we have n values, then sample() shuffles them
  foldid <- sample(rep_len(seq_len(nfolds), length.out = n))
  
  cat("[make_foldid] Created", nfolds, "folds for", n,
      "observations (seed =", seed, ")\n")
  return(foldid)
}

# ─────────────────────────────────────────────────────────────────────────────
# fit_cv_glmnet(x, y, alpha, foldid, ...)
# ─────────────────────────────────────────────────────────────────────────────
# Purpose : A thin wrapper around glmnet::cv.glmnet() with sensible defaults.
# Args    :
#   x      — predictor matrix (already scaled)
#   y      — response vector
#   alpha  — mixing parameter: 0 = Ridge, 1 = Lasso, (0,1) = Elastic Net
#   foldid — pre-built fold assignment vector
#   ...    — additional arguments passed to cv.glmnet()
# Returns : The cv.glmnet fit object.
#
# Key outputs of the returned object:
#   $lambda.min — lambda that minimises CV error
#   $lambda.1se — largest lambda within 1 SE of the minimum (more parsimonious)

fit_cv_glmnet <- function(x, y, alpha, foldid, ...) {
  model_type <- ifelse(alpha == 0, "Ridge",
                ifelse(alpha == 1, "Lasso",
                       paste0("Elastic Net (alpha=", alpha, ")")))
  cat("[fit_cv_glmnet] Fitting", model_type, "...\n")
  
  fit <- cv.glmnet(
    x           = x,
    y           = y,
    family      = "gaussian",
    alpha       = alpha,
    foldid      = foldid,
    standardize = FALSE,
    intercept   = TRUE,
    type.measure = "mse",
    ...
  )
  
  cat("  lambda.min =", round(fit$lambda.min, 6),
      " | lambda.1se =", round(fit$lambda.1se, 6), "\n")
  return(fit)
}

default_lambda_grid <- function() {
  exp(seq(log(1e-4), log(1e3), length.out = 140L))
}

lambda_index <- function(lambda, s) {
  if (is.character(s)) {
    match.arg(s, c("lambda.min", "lambda.1se"))
    return(s)
  }
  which.min(abs(lambda - as.numeric(s)))
}

foldclean_select_lambda <- function(fold_mse, lambda) {
  cvm <- colMeans(fold_mse)
  cvsd <- apply(fold_mse, 2, sd) / sqrt(nrow(fold_mse))
  min_idx <- which.min(cvm)
  threshold <- cvm[min_idx] + cvsd[min_idx]
  eligible <- which(cvm <= threshold)
  one_se_idx <- eligible[which.max(lambda[eligible])]

  list(
    cvm = cvm,
    cvsd = cvsd,
    lambda.min = lambda[min_idx],
    lambda.1se = lambda[one_se_idx]
  )
}

fit_foldclean_glmnet <- function(x_raw, y, alpha, foldid,
                                 lambda = default_lambda_grid(), ...) {
  x_raw <- as.matrix(x_raw)
  y <- as.numeric(y)
  lambda <- sort(lambda, decreasing = TRUE)
  folds <- sort(unique(foldid))
  fold_mse <- matrix(NA_real_, nrow = length(folds), ncol = length(lambda))

  model_type <- ifelse(alpha == 0, "Ridge",
                ifelse(alpha == 1, "Lasso",
                       paste0("Elastic Net (alpha=", alpha, ")")))
  cat("[fit_foldclean_glmnet] Fitting fold-clean", model_type, "...\n")

  for (i in seq_along(folds)) {
    val_idx <- which(foldid == folds[i])
    train_idx <- which(foldid != folds[i])

    fold_scaler <- fit_scaler(x_raw[train_idx, , drop = FALSE])
    x_fold_train <- apply_scaler(x_raw[train_idx, , drop = FALSE], fold_scaler)
    x_fold_val <- apply_scaler(x_raw[val_idx, , drop = FALSE], fold_scaler)

    fold_fit <- glmnet(
      x = x_fold_train,
      y = y[train_idx],
      family = "gaussian",
      alpha = alpha,
      lambda = lambda,
      standardize = FALSE,
      intercept = TRUE,
      ...
    )
    pred <- predict(fold_fit, newx = x_fold_val, s = lambda)
    fold_mse[i, ] <- colMeans((y[val_idx] - pred)^2)
  }

  selected <- foldclean_select_lambda(fold_mse, lambda)
  final_scaler <- fit_scaler(x_raw)
  x_final <- apply_scaler(x_raw, final_scaler)
  final_fit <- glmnet(
    x = x_final,
    y = y,
    family = "gaussian",
    alpha = alpha,
    lambda = lambda,
    standardize = FALSE,
    intercept = TRUE,
    ...
  )

  fit <- list(
    alpha = alpha,
    lambda = lambda,
    cvm = selected$cvm,
    cvsd = selected$cvsd,
    lambda.min = selected$lambda.min,
    lambda.1se = selected$lambda.1se,
    fold_mse = fold_mse,
    scaler = final_scaler,
    glmnet.fit = final_fit,
    transform = "scaled",
    feature_names = colnames(x_final)
  )
  class(fit) <- "foldclean_glmnet"

  cat("  lambda.min =", round(fit$lambda.min, 6),
      " | lambda.1se =", round(fit$lambda.1se, 6), "\n")
  return(fit)
}

fit_foldclean_neural_glmnet <- function(x_raw, y, foldid, A, bias, alpha,
                                        lambda = default_lambda_grid(), ...) {
  x_raw <- as.matrix(x_raw)
  y <- as.numeric(y)
  lambda <- sort(lambda, decreasing = TRUE)
  folds <- sort(unique(foldid))
  fold_mse <- matrix(NA_real_, nrow = length(folds), ncol = length(lambda))
  relu <- function(z) pmax(z, 0)

  model_type <- ifelse(alpha == 0, "Neural Ridge",
                ifelse(alpha == 1, "Neural Lasso",
                       paste0("Neural Elastic Net (alpha=", alpha, ")")))
  cat("[fit_foldclean_neural_glmnet] Fitting fold-clean", model_type, "...\n")

  for (i in seq_along(folds)) {
    val_idx <- which(foldid == folds[i])
    train_idx <- which(foldid != folds[i])

    x_fold_scaler <- fit_scaler(x_raw[train_idx, , drop = FALSE])
    x_fold_train <- apply_scaler(x_raw[train_idx, , drop = FALSE], x_fold_scaler)
    x_fold_val <- apply_scaler(x_raw[val_idx, , drop = FALSE], x_fold_scaler)

    h_train_raw <- relu(x_fold_train %*% A +
                          matrix(bias, nrow = nrow(x_fold_train),
                                 ncol = ncol(A), byrow = TRUE))
    h_val_raw <- relu(x_fold_val %*% A +
                        matrix(bias, nrow = nrow(x_fold_val),
                               ncol = ncol(A), byrow = TRUE))

    h_fold_scaler <- fit_scaler(h_train_raw)
    h_fold_train <- apply_scaler(h_train_raw, h_fold_scaler)
    h_fold_val <- apply_scaler(h_val_raw, h_fold_scaler)

    fold_fit <- glmnet(
      x = h_fold_train,
      y = y[train_idx],
      family = "gaussian",
      alpha = alpha,
      lambda = lambda,
      standardize = FALSE,
      intercept = TRUE,
      ...
    )
    pred <- predict(fold_fit, newx = h_fold_val, s = lambda)
    fold_mse[i, ] <- colMeans((y[val_idx] - pred)^2)
  }

  selected <- foldclean_select_lambda(fold_mse, lambda)

  x_final_scaler <- fit_scaler(x_raw)
  x_final <- apply_scaler(x_raw, x_final_scaler)
  h_final_raw <- relu(x_final %*% A +
                        matrix(bias, nrow = nrow(x_final),
                               ncol = ncol(A), byrow = TRUE))
  h_final_scaler <- fit_scaler(h_final_raw)
  h_final <- apply_scaler(h_final_raw, h_final_scaler)

  final_fit <- glmnet(
    x = h_final,
    y = y,
    family = "gaussian",
    alpha = alpha,
    lambda = lambda,
    standardize = FALSE,
    intercept = TRUE,
    ...
  )

  fit <- list(
    alpha = alpha,
    lambda = lambda,
    cvm = selected$cvm,
    cvsd = selected$cvsd,
    lambda.min = selected$lambda.min,
    lambda.1se = selected$lambda.1se,
    fold_mse = fold_mse,
    x_scaler = x_final_scaler,
    h_scaler = h_final_scaler,
    A = A,
    bias = bias,
    glmnet.fit = final_fit,
    transform = "neural",
    feature_names = colnames(h_final)
  )
  class(fit) <- "foldclean_glmnet"

  cat("  lambda.min =", round(fit$lambda.min, 6),
      " | lambda.1se =", round(fit$lambda.1se, 6), "\n")
  return(fit)
}

coef.foldclean_glmnet <- function(object, s = "lambda.min", ...) {
  s_value <- if (is.character(s)) object[[s]] else s
  coef(object$glmnet.fit, s = s_value, ...)
}

predict.foldclean_glmnet <- function(object, newx, s = "lambda.min", ...) {
  s_value <- if (is.character(s)) object[[s]] else s
  newx <- as.matrix(newx)

  if (identical(object$transform, "scaled")) {
    transformed <- apply_scaler(newx, object$scaler)
  } else if (identical(object$transform, "neural")) {
    relu <- function(z) pmax(z, 0)
    x_scaled <- apply_scaler(newx, object$x_scaler)
    h_raw <- relu(x_scaled %*% object$A +
                    matrix(object$bias, nrow = nrow(x_scaled),
                           ncol = ncol(object$A), byrow = TRUE))
    transformed <- apply_scaler(h_raw, object$h_scaler)
  } else {
    abort_run("Unknown fold-clean transform: ", object$transform)
  }

  predict(object$glmnet.fit, newx = transformed, s = s_value, ...)
}

plot.foldclean_glmnet <- function(x, main = "Fold-clean CV Error vs log(lambda)", ...) {
  upper <- x$cvm + x$cvsd
  lower <- x$cvm - x$cvsd
  plot(log(x$lambda), x$cvm, type = "b", pch = 16,
       ylim = range(c(lower, upper), finite = TRUE),
       xlab = expression(log(lambda)), ylab = "Cross-Validation MSE",
       main = main, ...)
  arrows(log(x$lambda), lower, log(x$lambda), upper,
         angle = 90, code = 3, length = 0.03, col = "grey60")
  abline(v = log(x$lambda.min), lty = 2, col = "red")
  abline(v = log(x$lambda.1se), lty = 2, col = "blue")
}

# ─────────────────────────────────────────────────────────────────────────────
# score_regression(y_true, y_pred)
# ─────────────────────────────────────────────────────────────────────────────
# Purpose : Compute common regression error metrics.
# Returns : A named list with:
#   $RMSE — Root Mean Squared Error  = sqrt( mean( (y - ŷ)^2 ) )
#   $MAE  — Mean Absolute Error      = mean( |y - ŷ| )
#   $R2   — Coefficient of determination
#
# RMSE penalises large errors more heavily than MAE because of the squaring.

score_regression <- function(y_true, y_pred) {
  y_true <- as.numeric(y_true)
  y_pred <- as.numeric(y_pred)
  if (length(y_true) != length(y_pred) || any(!is.finite(c(y_true, y_pred)))) {
    abort_run("Regression metrics require equal-length finite vectors")
  }
  residuals <- y_true - y_pred
  
  rmse <- sqrt(mean(residuals^2))
  mae  <- mean(abs(residuals))
  
  # R² = 1 − SS_res / SS_tot
  ss_res <- sum(residuals^2)
  ss_tot <- sum((y_true - mean(y_true))^2)
  r2 <- 1 - ss_res / ss_tot
  
  return(list(RMSE = rmse, MAE = mae, R2 = r2))
}

# ─────────────────────────────────────────────────────────────────────────────
# count_nonzero(cv_fit, s)
# ─────────────────────────────────────────────────────────────────────────────
# Purpose : Count how many predictor coefficients are non-zero at a given lambda.
# Args    :
#   cv_fit — a cv.glmnet object
#   s      — which lambda to use, e.g. "lambda.min" or "lambda.1se"
# Returns : An integer count (excluding the intercept).
#
# coef() on a glmnet object returns a sparse matrix.  The first row is the
# intercept, so we drop it with [-1, ].

count_nonzero <- function(cv_fit, s = "lambda.min", tol = 1e-8) {
  coefs <- coef(cv_fit, s = s)
  # Drop intercept (row 1), count entries != 0
  nonzero <- sum(abs(coefs[-1, ]) > tol)
  cat("[count_nonzero] At", s, ":", nonzero, "non-zero coefficients\n")
  return(nonzero)
}

# ─────────────────────────────────────────────────────────────────────────────
# safe_condition_numbers(X, lambda)
# ─────────────────────────────────────────────────────────────────────────────
# Purpose : Compute the condition number of X'X and of (X'X + λI).
#
# Background:
#   The condition number measures how "ill-conditioned" a matrix is.
#   A large condition number means small changes in data cause large changes
#   in the solution — the OLS system is numerically unstable.
#   Ridge regression adds λI to X'X, which REDUCES the condition number
#   and stabilises the solution.
#
# Args    :
#   X      — the (scaled) predictor matrix
#   lambda — the Ridge penalty parameter
# Returns : A named list with $ols_cond and $ridge_cond.

safe_condition_numbers <- function(X, lambda = 0, tol = 1e-10) {
  # glmnet's Gaussian objective uses G = X'X / n, so lambda must be compared
  # with eigenvalues on that same scale.
  G <- crossprod(X) / nrow(X)
  eig_vals <- eigen(G, symmetric = TRUE, only.values = TRUE)$values
  eig_vals <- pmax(eig_vals, 0)

  largest <- max(eig_vals)
  smallest <- min(eig_vals)
  cutoff <- tol * max(1, largest)
  ols_cond <- if (smallest <= cutoff) Inf else largest / smallest
  ridge_cond <- (largest + lambda) / (smallest + lambda)
  
  cat("[safe_condition_numbers]\n")
  cat("  OLS   condition number:", format(ols_cond, big.mark = ","), "\n")
  cat("  Ridge condition number:", format(ridge_cond, big.mark = ","),
      " (lambda =", round(lambda, 6), ")\n")
  
  return(list(
    ols_cond = ols_cond,
    ridge_cond = ridge_cond,
    eigen_min = smallest,
    eigen_max = largest,
    tolerance = cutoff
  ))
}

# ─────────────────────────────────────────────────────────────────────────────
# DONE — this file is ready to be sourced
# ─────────────────────────────────────────────────────────────────────────────
log_info("setup.R loaded | project=", PROJECT_ROOT,
         " | group=", GROUP_NUMBER,
         " | R=", getRversion(),
         " | renv=", as.character(packageVersion("renv")),
         " | glmnet=", as.character(packageVersion("glmnet")))
