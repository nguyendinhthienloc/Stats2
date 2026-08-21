###############################################################################
# Part 2 / Section 3: two-factor ANOVA, marginal effects, and effect sizes.
###############################################################################

source(file.path("R", "setup.R"))
source(file.path(PROJECT_ROOT, "finals", "part2", "R", "part2_helpers.R"))

log_step("Part 2 / Section 3: fitting effect-coded two-factor ANOVA")
student <- load_part2_data()

anova_fit <- stats::lm(
  math_score ~ test_preparation * lunch, data = student,
  contrasts = list(test_preparation = "contr.sum", lunch = "contr.sum")
)
effect_contrasts <- part2_effect_contrasts(anova_fit)
effect_results <- do.call(
  rbind,
  lapply(effect_contrasts, function(contrast) {
    linear_contrast(anova_fit, contrast)
  })
)
effects <- data.frame(
  Effect = rownames(effect_results), effect_results,
  row.names = NULL, check.names = FALSE
)

residual_df <- stats::df.residual(anova_fit)
residual_ss <- stats::deviance(anova_fit)
residual_ms <- residual_ss / residual_df
anova_terms <- effects
anova_terms$F_value <- anova_terms$t^2
anova_terms$Sum_sq <- anova_terms$F_value * residual_ms
anova_terms$Partial_eta_squared <- anova_terms$F_value /
  (anova_terms$F_value + residual_df)
anova_table <- data.frame(
  Term = c(anova_terms$Effect, "Residuals"),
  Df = c(rep(1L, nrow(anova_terms)), residual_df),
  Sum_sq = c(anova_terms$Sum_sq, residual_ss),
  Mean_sq = c(anova_terms$Sum_sq, residual_ms),
  F_value = c(anova_terms$F_value, NA_real_),
  P_value = c(anova_terms$P_value, NA_real_),
  Partial_eta_squared = c(anova_terms$Partial_eta_squared, NA_real_),
  stringsAsFactors = FALSE
)
save_part2_table(
  anova_table, "tab_part2_anova",
  "Effect-coded two-factor ANOVA for math score.",
  "tab:part2-anova", digits = 4L
)
save_part2_table(
  effects[, c("Effect", "Estimate", "SE", "Df", "t", "P_value",
              "CI_low", "CI_high")],
  "tab_part2_effect_estimates",
  "Pre-specified marginal effects and interaction in math-score points.",
  "tab:part2-effects", digits = 3L
)

cell_grid <- part2_cell_grid()
cell_matrix <- part2_model_matrix(anova_fit, cell_grid)
cell_predictions <- t(vapply(
  seq_len(nrow(cell_grid)),
  function(i) linear_contrast(anova_fit, cell_matrix[i, ]),
  numeric(7L)
))
cell_estimates <- cbind(
  data.frame(
    Lunch = as.character(cell_grid$lunch),
    Test_preparation = as.character(cell_grid$test_preparation),
    stringsAsFactors = FALSE
  ),
  as.data.frame(cell_predictions, check.names = FALSE)
)
save_part2_table(
  cell_estimates[, c("Lunch", "Test_preparation", "Estimate", "SE",
                     "CI_low", "CI_high")],
  "tab_part2_cell_means",
  "Estimated means for the four observed factorial cells.",
  "tab:part2-cell-means", digits = 2L
)

model_fit <- data.frame(
  Metric = c("Observations", "Residual degrees of freedom", "R-squared",
             "Adjusted R-squared", "Residual standard error"),
  Value = c(
    stats::nobs(anova_fit), residual_df, summary(anova_fit)$r.squared,
    summary(anova_fit)$adj.r.squared, summary(anova_fit)$sigma
  )
)
save_part2_table(
  model_fit, "tab_part2_model_fit",
  "Two-factor model fit summary.", "tab:part2-model-fit", digits = 3L
)

save(
  anova_fit, effects, anova_table, cell_estimates, student,
  file = PART2_MODEL_FILE
)
log_step("Part 2 Section 3 complete: ANOVA and effect estimates saved")
