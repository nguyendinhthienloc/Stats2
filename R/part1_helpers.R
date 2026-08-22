###############################################################################
# Canonical Part 1 helpers. R/setup.R must be sourced before this file.
###############################################################################

required_packages <- c("glmnet", "knitr", "rmarkdown")
missing_packages <- required_packages[
  !vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)
]
if (length(missing_packages)) {
  stop(
    "Missing R package(s): ", paste(missing_packages, collapse = ", "),
    ". Run renv::restore() before the Part 1 pipeline.",
    call. = FALSE
  )
}

SEED_SPLIT <- seeds$split
SEED_FOLDS <- seeds$folds
SEED_BOOTSTRAP <- seeds$bootstrap
HOLDOUT_FRACTION <- config$test_fraction
N_FOLDS <- config$cv_folds
WINSOR_PROBS <- c(0.01, 0.99)
TARGET <- config$response
PREDICTORS <- c(
  "fixed_acidity", "volatile_acidity", "citric_acid", "residual_sugar",
  "chlorides", "free_sulfur_dioxide", "total_sulfur_dioxide", "density",
  "ph", "sulphates", "alcohol"
)

OUTPUT_DIR <- file.path(PROJECT_ROOT, "output")
FIGURE_DIR <- paths$figures
TABLE_DIR <- paths$tables
MODEL_DIR <- paths$models
LOG_DIR <- paths$logs
DATA_DIR <- paths$processed
SHARED_DATA_FILE <- file.path(DATA_DIR, "shared_data.RData")

ensure_dirs <- function() {
  dirs <- c(DATA_DIR, OUTPUT_DIR, FIGURE_DIR, TABLE_DIR, MODEL_DIR, LOG_DIR)
  invisible(vapply(dirs, dir.create, logical(1), recursive = TRUE,
                   showWarnings = FALSE))
}

log_line <- function(level, ...) {
  cat(sprintf(">>> [%s] %-5s %s\n", format(Sys.time(), "%H:%M:%S"), level,
              paste0(..., collapse = "")))
}
log_step <- function(...) log_line("STEP", ...)
log_info <- function(...) log_line("INFO", ...)
log_warn <- function(...) log_line("WARN", ...)
abort_run <- function(...) stop(paste0(..., collapse = ""), call. = FALSE)

snake_case <- function(x) {
  x <- tolower(trimws(x))
  x <- gsub("[^a-z0-9]+", "_", x)
  gsub("(^_+|_+$)", "", x)
}

read_red_wine <- function() {
  wine <- read_wine_red()
  names(wine) <- snake_case(names(wine))
  expected <- c(PREDICTORS, TARGET)
  if (!identical(names(wine), expected)) {
    abort_run("Unexpected red-wine schema: ", paste(names(wine), collapse = ", "))
  }
  if (nrow(wine) != 1599L || any(!vapply(wine, is.numeric, logical(1)))) {
    abort_run("Red-wine data failed the expected 1599-row numeric schema check")
  }
  wine$source_row <- seq_len(nrow(wine))
  wine
}
deduplicate_wine <- function(wine) {
  analytical <- c(PREDICTORS, TARGET)
  keep <- !duplicated(wine[analytical])
  unique_wine <- wine[keep, c("source_row", analytical), drop = FALSE]
  rownames(unique_wine) <- NULL
  unique_wine$record_id <- sprintf("RW%04d", seq_len(nrow(unique_wine)))
  unique_wine[, c("record_id", "source_row", analytical), drop = FALSE]
}

stratified_holdout_indices <- function(y, fraction, seed) {
  set.seed(seed)
  groups <- split(seq_along(y), y)
  selected <- unlist(lapply(groups, function(index) {
    n_take <- max(1L, min(length(index) - 1L,
                         as.integer(round(length(index) * fraction))))
    sample(index, size = n_take, replace = FALSE)
  }), use.names = FALSE)
  sort(as.integer(selected))
}

stratified_folds <- function(y, k, seed) {
  set.seed(seed)
  foldid <- integer(length(y))
  for (index in split(seq_along(y), y)) {
    shuffled <- sample(index, length(index), replace = FALSE)
    foldid[shuffled] <- rep(seq_len(k), length.out = length(index))
  }
  foldid
}

sample_skewness <- function(x) {
  x <- x[is.finite(x)]
  if (length(x) < 3L || stats::sd(x) == 0) return(0)
  z <- (x - mean(x)) / stats::sd(x)
  mean(z^3)
}

fit_preprocessor <- function(data, predictors = PREDICTORS,
                             log_features = NULL,
                             winsor_probs = WINSOR_PROBS) {
  x <- as.data.frame(data[predictors], check.names = FALSE)
  medians <- vapply(x, stats::median, numeric(1), na.rm = TRUE)
  for (name in predictors) {
    missing <- is.na(x[[name]]) | !is.finite(x[[name]])
    x[[name]][missing] <- medians[[name]]
  }

  # A NULL value means that transformation selection belongs to this analysis
  # sample. This is used inside cross-validation so validation-fold predictor
  # distributions cannot influence the transformation choice.
  if (is.null(log_features)) {
    raw_skewness <- vapply(x, sample_skewness, numeric(1))
    nonnegative <- vapply(x, function(value) min(value) >= 0, logical(1))
    log_features <- names(raw_skewness)[raw_skewness > 1 & nonnegative]
  }

  limits <- vapply(x, stats::quantile, numeric(2), probs = winsor_probs,
                   na.rm = TRUE, names = FALSE, type = 7)
  rownames(limits) <- c("lower", "upper")
  for (name in predictors) {
    x[[name]] <- pmin(pmax(x[[name]], limits["lower", name]),
                      limits["upper", name])
  }

  invalid_logs <- log_features[
    !log_features %in% predictors |
      vapply(log_features, function(name) any(x[[name]] < 0), logical(1))
  ]
  if (length(invalid_logs) > 0L) {
    abort_run("Cannot log1p-transform: ", paste(invalid_logs, collapse = ", "))
  }
  for (name in log_features) x[[name]] <- log1p(x[[name]])

  centers <- vapply(x, mean, numeric(1))
  scales <- vapply(x, stats::sd, numeric(1))
  if (any(!is.finite(scales) | scales <= 0)) {
    abort_run("Preprocessor found a zero-variance or non-finite predictor")
  }

  structure(list(
    predictors = predictors,
    medians = medians,
    limits = limits,
    log_features = log_features,
    centers = centers,
    scales = scales,
    winsor_probs = winsor_probs
  ), class = "wine_preprocessor")
}

apply_preprocessor <- function(data, recipe) {
  x <- as.data.frame(data[recipe$predictors], check.names = FALSE)
  for (name in recipe$predictors) {
    missing <- is.na(x[[name]]) | !is.finite(x[[name]])
    x[[name]][missing] <- recipe$medians[[name]]
    x[[name]] <- pmin(pmax(x[[name]], recipe$limits["lower", name]),
                      recipe$limits["upper", name])
  }
  for (name in recipe$log_features) x[[name]] <- log1p(x[[name]])
  x <- sweep(as.matrix(x), 2L, recipe$centers, FUN = "-")
  x <- sweep(x, 2L, recipe$scales, FUN = "/")
  colnames(x) <- recipe$predictors
  x
}

score_regression <- function(observed, predicted) {
  observed <- as.numeric(observed)
  predicted <- as.numeric(predicted)
  if (length(observed) != length(predicted) ||
      any(!is.finite(c(observed, predicted)))) {
    abort_run("Regression scores require equal-length finite vectors")
  }
  residual <- observed - predicted
  ss_total <- sum((observed - mean(observed))^2)
  c(
    RMSE = sqrt(mean(residual^2)),
    MAE = mean(abs(residual)),
    R2 = if (ss_total == 0) NA_real_ else 1 - sum(residual^2) / ss_total
  )
}

select_lambda <- function(lambda, fold_mse) {
  cv_mse <- colMeans(fold_mse)
  cv_se <- apply(fold_mse, 2L, stats::sd) / sqrt(nrow(fold_mse))
  min_index <- which.min(cv_mse)
  eligible <- which(cv_mse <= cv_mse[min_index] + cv_se[min_index])
  one_se_index <- eligible[which.max(lambda[eligible])]
  list(
    cv_mse = cv_mse,
    cv_se = cv_se,
    lambda_min = lambda[min_index],
    lambda_1se = lambda[one_se_index],
    min_index = min_index,
    one_se_index = one_se_index
  )
}

cv_regularized_foldclean <- function(train_data, foldid, alpha, lambda,
                                     log_features = NULL) {
  lambda <- sort(as.numeric(lambda), decreasing = TRUE)
  folds <- sort(unique(foldid))
  fold_mse <- matrix(NA_real_, nrow = length(folds), ncol = length(lambda))
  fold_log_features <- vector("list", length(folds))

  for (i in seq_along(folds)) {
    validation <- which(foldid == folds[[i]])
    analysis <- which(foldid != folds[[i]])
    recipe <- fit_preprocessor(train_data[analysis, , drop = FALSE],
                               log_features = log_features)
    fold_log_features[[i]] <- recipe$log_features
    x_analysis <- apply_preprocessor(train_data[analysis, , drop = FALSE], recipe)
    x_validation <- apply_preprocessor(train_data[validation, , drop = FALSE], recipe)
    fit <- glmnet::glmnet(
      x_analysis, train_data[[TARGET]][analysis], alpha = alpha,
      lambda = lambda, family = "gaussian", standardize = FALSE,
      intercept = TRUE
    )
    prediction <- stats::predict(fit, newx = x_validation, s = lambda)
    errors <- sweep(prediction, 1L, train_data[[TARGET]][validation], FUN = "-")
    fold_mse[i, ] <- colMeans(errors^2)
  }

  selected <- select_lambda(lambda, fold_mse)
  c(list(alpha = alpha, lambda = lambda, fold_mse = fold_mse,
         fold_log_features = fold_log_features), selected)
}

cv_ols_foldclean <- function(train_data, foldid, log_features = NULL) {
  folds <- sort(unique(foldid))
  fold_scores <- matrix(NA_real_, nrow = length(folds), ncol = 3L,
                        dimnames = list(NULL, c("RMSE", "MAE", "R2")))
  squared_error <- numeric(nrow(train_data))
  absolute_error <- numeric(nrow(train_data))

  for (i in seq_along(folds)) {
    validation <- which(foldid == folds[[i]])
    analysis <- which(foldid != folds[[i]])
    recipe <- fit_preprocessor(train_data[analysis, , drop = FALSE],
                               log_features = log_features)
    x_analysis <- apply_preprocessor(train_data[analysis, , drop = FALSE], recipe)
    x_validation <- apply_preprocessor(train_data[validation, , drop = FALSE], recipe)
    fit <- stats::lm.fit(cbind(`(Intercept)` = 1, x_analysis),
                         train_data[[TARGET]][analysis])
    prediction <- as.numeric(cbind(1, x_validation) %*% fit$coefficients)
    observed <- train_data[[TARGET]][validation]
    fold_scores[i, ] <- score_regression(observed, prediction)
    squared_error[validation] <- (observed - prediction)^2
    absolute_error[validation] <- abs(observed - prediction)
  }

  c(
    RMSE = sqrt(mean(squared_error)),
    MAE = mean(absolute_error),
    R2 = 1 - sum(squared_error) /
      sum((train_data[[TARGET]] - mean(train_data[[TARGET]]))^2)
  )
}

cv_mean_baseline <- function(y, foldid) {
  prediction <- numeric(length(y))
  for (fold in sort(unique(foldid))) {
    validation <- which(foldid == fold)
    prediction[validation] <- mean(y[-validation])
  }
  score_regression(y, prediction)
}

compute_vif <- function(x) {
  x <- as.data.frame(x, check.names = FALSE)
  vapply(names(x), function(name) {
    others <- setdiff(names(x), name)
    fit <- stats::lm(x[[name]] ~ ., data = x[others])
    r_squared <- summary(fit)$r.squared
    1 / (1 - r_squared)
  }, numeric(1))
}

nonzero_count <- function(fit, lambda, tolerance = 1e-8) {
  coefficients <- as.matrix(stats::coef(fit, s = lambda))[-1, 1]
  sum(abs(coefficients) > tolerance)
}

save_table_tex <- function(x, filename, caption, label, digits = 3,
                           align = NULL) {
  ensure_dirs()
  path <- file.path(TABLE_DIR, filename)
  tex <- knitr::kable(
    x, format = "latex", booktabs = TRUE, caption = caption,
    label = label, digits = digits, escape = TRUE, align = align,
    row.names = FALSE
  )
  tex <- as.character(tex)
  tex <- sub("\\begin{table}", "\\begin{table}[H]", tex, fixed = TRUE)
  wide_tables <- c(
    "tab_p1_data_dictionary.tex", "tab_p3_feature_screening.tex",
    "tab_p5_holdout_display.tex"
  )
  if (filename %in% wide_tables) {
    tex <- sub(
      "\\begin{tabular",
      "\\resizebox{\\linewidth}{!}{%\n\\begin{tabular",
      tex, fixed = TRUE
    )
    tex <- sub(
      "\\end{tabular}",
      "\\end{tabular}%\n}",
      tex, fixed = TRUE
    )
  }
  writeLines(tex, path, useBytes = TRUE)
  invisible(path)
}

save_table_artifacts <- function(x, stem, caption, label, digits = 3,
                                 align = NULL) {
  ensure_dirs()
  utils::write.csv(x, file.path(TABLE_DIR, paste0(stem, ".csv")),
                   row.names = FALSE, na = "")
  save_table_tex(x, paste0(stem, ".tex"), caption, label, digits, align)
}

open_pdf <- function(filename, width = 7, height = 5) {
  ensure_dirs()
  grDevices::pdf(file.path(FIGURE_DIR, filename), width = width, height = height,
                 family = "serif", useDingbats = FALSE)
  graphics::par(
    mar = c(4.3, 4.4, 2.7, 1.0), mgp = c(2.5, 0.8, 0),
    tcl = -0.25, las = 1, bty = "l", col.axis = "#25313C",
    col.lab = "#25313C", col.main = "#17212B"
  )
}

MODEL_COLORS <- c(
  "Mean" = "#7F8C8D", "OLS" = "#2C3E50", "Ridge" = "#2878B5",
  "Lasso" = "#D1495B", "Elastic Net" = "#2A9D8F"
)


ensure_dirs()
log_info(
  "Canonical Part 1 helpers loaded | root=", PROJECT_ROOT,
  " | R=", as.character(getRversion()),
  " | glmnet=", as.character(utils::packageVersion("glmnet"))
)
