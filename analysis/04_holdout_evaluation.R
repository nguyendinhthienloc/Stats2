###############################################################################
# Part 1 section 5: one-time evaluation of the pre-locked models.
# This is the only active analysis file that reconstructs held-out outcomes.
###############################################################################

source_candidates <- c(file.path("R", "setup.R"), file.path("..", "R", "setup.R"))
script_arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
if (length(script_arg)) {
  script_file <- normalizePath(sub("^--file=", "", script_arg[[1L]]),
                               winslash = "/", mustWork = TRUE)
  source_candidates <- c(file.path(dirname(script_file), "..", "R", "setup.R"),
                         source_candidates)
}
source(source_candidates[file.exists(source_candidates)][[1L]])
source(file.path(PROJECT_ROOT, "R", "part1_helpers.R"))
load(SHARED_DATA_FILE)
load(file.path(MODEL_DIR, "baseline_fits.RData"))
load(file.path(MODEL_DIR, "regularized_fits.RData"))

lock_file <- file.path(OUTPUT_DIR, "model_lock.csv")
if (!file.exists(lock_file)) {
  abort_run("Pre-holdout model lock is missing")
}
disk_lock <- utils::read.csv(lock_file, stringsAsFactors = FALSE)
lock_matches <- nrow(disk_lock) == 1L &&
  identical(disk_lock$Locked_model[[1L]], model_lock$Locked_model[[1L]]) &&
  identical(disk_lock$Selection_metric[[1L]],
            model_lock$Selection_metric[[1L]]) &&
  isTRUE(all.equal(disk_lock$CV_RMSE[[1L]], model_lock$CV_RMSE[[1L]],
                   tolerance = 1e-12))
if (!lock_matches) {
  abort_run(
    "On-disk model lock does not match regularized_fits.RData; ",
    "rerun analysis/03_regularized_models.R before holdout evaluation"
  )
}
log_step("P5: reconstructing the locked holdout response for one-time evaluation")

wine_reloaded <- deduplicate_wine(read_red_wine())
if (!identical(wine_reloaded$record_id[holdout_index], holdout_predictors$record_id)) {
  abort_run("Holdout record IDs do not match the locked split")
}

# AGENTS.md contract: y_test is created and used only in this file.
y_test <- wine_reloaded[[TARGET]][holdout_index]

prediction_list <- list(
  "Mean" = rep(mean(y_train), length(y_test)),
  "OLS" = as.numeric(stats::predict(
    ols_fit, newdata = data.frame(x_holdout, check.names = FALSE)
  )),
  "Ridge" = as.numeric(stats::predict(
    ridge_fit, newx = x_holdout, s = ridge_cv$lambda_min
  )),
  "Lasso" = as.numeric(stats::predict(
    lasso_fit, newx = x_holdout, s = lasso_cv$lambda_min
  )),
  "Elastic Net" = as.numeric(stats::predict(
    enet_fit, newx = x_holdout, s = enet_cv$lambda_min
  ))
)

holdout_scores <- do.call(rbind, lapply(names(prediction_list), function(name) {
  score <- score_regression(y_test, prediction_list[[name]])
  data.frame(Model = name, RMSE = score[["RMSE"]], MAE = score[["MAE"]],
             R2 = score[["R2"]], stringsAsFactors = FALSE)
}))
rownames(holdout_scores) <- NULL

log_step("P5: bootstrapping metric uncertainty with a fixed seed")
set.seed(SEED_BOOTSTRAP)
n_bootstrap <- 1000L
bootstrap_rmse <- matrix(
  NA_real_, nrow = n_bootstrap, ncol = length(prediction_list),
  dimnames = list(NULL, names(prediction_list))
)
for (b in seq_len(n_bootstrap)) {
  index <- sample.int(length(y_test), replace = TRUE)
  for (name in names(prediction_list)) {
    bootstrap_rmse[b, name] <- sqrt(mean(
      (y_test[index] - prediction_list[[name]][index])^2
    ))
  }
}
rmse_intervals <- t(apply(
  bootstrap_rmse, 2L, stats::quantile, probs = c(0.025, 0.975),
  names = FALSE, type = 7
))

training_cv_lookup <- all_model_cv
holdout_performance <- merge(
  training_cv_lookup, holdout_scores, by = "Model", sort = FALSE
)
holdout_performance$RMSE_CI_Lower <- rmse_intervals[
  match(holdout_performance$Model, rownames(rmse_intervals)), 1
]
holdout_performance$RMSE_CI_Upper <- rmse_intervals[
  match(holdout_performance$Model, rownames(rmse_intervals)), 2
]
holdout_performance$Locked_by_CV <- ifelse(
  holdout_performance$Model == model_lock$Locked_model, "Yes", "No"
)
holdout_performance$Holdout_rank <- rank(
  holdout_performance$RMSE, ties.method = "min"
)
holdout_performance <- holdout_performance[
  order(holdout_performance$Holdout_rank),
  c("Model", "Training_RMSE", "CV_RMSE", "RMSE", "RMSE_CI_Lower",
    "RMSE_CI_Upper", "MAE", "R2", "Locked_by_CV", "Holdout_rank")
]
names(holdout_performance)[names(holdout_performance) == "RMSE"] <- "Holdout_RMSE"
names(holdout_performance)[names(holdout_performance) == "MAE"] <- "Holdout_MAE"
names(holdout_performance)[names(holdout_performance) == "R2"] <- "Holdout_R2"

holdout_display <- holdout_performance[
  , c("Model", "CV_RMSE", "Holdout_RMSE", "RMSE_CI_Lower",
      "RMSE_CI_Upper", "Holdout_MAE", "Holdout_R2", "Locked_by_CV")
]

locked_name <- model_lock$Locked_model
locked_prediction <- prediction_list[[locked_name]]
locked_residual <- y_test - locked_prediction
error_by_quality <- do.call(rbind, lapply(sort(unique(y_test)), function(score) {
  index <- which(y_test == score)
  data.frame(
    Quality = score, N = length(index),
    Mean_Error = mean(locked_residual[index]),
    MAE = mean(abs(locked_residual[index])),
    RMSE = sqrt(mean(locked_residual[index]^2)),
    stringsAsFactors = FALSE
  )
}))

save_table_artifacts(
  holdout_performance, "tab_p5_holdout_performance",
  "Locked holdout performance; RMSE intervals use 1,000 fixed-seed bootstrap samples.",
  "p5-holdout-performance", digits = 4
)
save_table_artifacts(
  holdout_display, "tab_p5_holdout_display",
  "Fair holdout comparison; the model lock was based only on five-fold CV RMSE.",
  "p5-holdout-display", digits = 4
)
save_table_artifacts(
  error_by_quality, "tab_p5_error_by_quality",
  paste0("Holdout error by observed score for the pre-locked ", locked_name, " model."),
  "p5-error-by-quality", digits = 4
)

log_step("P5: generating locked holdout diagnostic figures")
open_pdf("fig_p5_actual_vs_predicted.pdf", width = 9, height = 8)
graphics::par(mfrow = c(2, 2), mar = c(4, 4, 2.5, 0.8))
plot_models <- c("OLS", "Ridge", "Lasso", "Elastic Net")
common_range <- range(c(y_test, unlist(prediction_list[plot_models])))
for (name in plot_models) {
  graphics::plot(
    y_test, prediction_list[[name]], xlim = common_range, ylim = common_range,
    pch = 16, cex = 0.65,
    col = grDevices::adjustcolor(MODEL_COLORS[[name]], alpha.f = 0.55),
    xlab = "Observed quality", ylab = "Predicted quality",
    main = sprintf("%s (RMSE %.3f)", name,
                   holdout_performance$Holdout_RMSE[
                     match(name, holdout_performance$Model)
                   ])
  )
  graphics::abline(0, 1, lty = 2, lwd = 1.5, col = "#25313C")
}
grDevices::dev.off()

open_pdf("fig_p5_locked_residual_diagnostics.pdf", width = 10, height = 4.3)
graphics::par(mfrow = c(1, 3), mar = c(4.1, 4.1, 2.5, 0.8))
graphics::plot(
  locked_prediction, locked_residual, pch = 16, cex = 0.65,
  col = grDevices::adjustcolor(MODEL_COLORS[[locked_name]], alpha.f = 0.55),
  xlab = "Fitted quality", ylab = "Residual", main = "Residuals vs fitted"
)
graphics::abline(h = 0, lty = 2, col = "#25313C")
stats::qqnorm(
  locked_residual, pch = 16, cex = 0.55,
  col = grDevices::adjustcolor("#2878B5", alpha.f = 0.55),
  main = "Normal Q-Q"
)
stats::qqline(locked_residual, col = "#D1495B", lwd = 1.5)
graphics::hist(
  locked_residual, breaks = "FD", col = "#B9D7EA", border = "white",
  xlab = "Residual", ylab = "Count", main = "Residual distribution"
)
graphics::abline(v = 0, lty = 2, col = "#25313C")
grDevices::dev.off()

observed_holdout_winner <- holdout_performance$Model[[1]]
holdout_summary <- list(
  locked_model = locked_name,
  observed_holdout_winner = observed_holdout_winner,
  n_holdout = length(y_test),
  bootstrap_replicates = n_bootstrap,
  performance = holdout_performance,
  display = holdout_display,
  error_by_quality = error_by_quality
)

# Save aggregate results only; row-level holdout outcomes remain local to this script.
save(
  holdout_summary, holdout_performance, holdout_display, error_by_quality,
  file = file.path(MODEL_DIR, "holdout_summary.RData")
)

analysis_summary <- list(
  config = analysis_config,
  audit = data_audit,
  split = split_summary,
  log_features = log_features,
  rows_with_any_iqr_flag = rows_with_any_iqr_flag,
  descriptive_statistics = descriptive_statistics,
  quality_frequency = quality_frequency,
  correlations = correlation_quality,
  feature_screening = feature_screening,
  stepwise_features = stepwise_features,
  baseline_performance = baseline_performance,
  regularized_summary = regularized_summary,
  lasso_selection = lasso_selection,
  enet_alpha = enet_alpha,
  model_lock = model_lock,
  holdout = holdout_summary
)
save(analysis_summary, file = file.path(OUTPUT_DIR, "analysis_summary.RData"))

capture.output(sessionInfo(), file = file.path(LOG_DIR, "session_info.txt"))
writeLines(
  c(
    paste("Completed:", format(Sys.time(), tz = "UTC", usetz = TRUE)),
    paste("Locked model:", locked_name),
    paste("Observed holdout winner:", observed_holdout_winner),
    paste("Holdout rows:", length(y_test)),
    "Row-level holdout outcomes were not serialized."
  ),
  file.path(OUTPUT_DIR, "HOLDOUT_COMPLETE.txt")
)

log_info("P5 complete | locked=", locked_name,
         " | observed holdout winner=", observed_holdout_winner,
         " | best RMSE=", sprintf("%.4f", holdout_performance$Holdout_RMSE[[1]]))
