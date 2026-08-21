###############################################################################
# Part 2 / Section 4: assumptions, diagnostics, robust sensitivity, follow-up.
###############################################################################

source(file.path("R", "setup.R"))
source(file.path(PROJECT_ROOT, "finals", "part2", "R", "part2_helpers.R"))

log_step("Part 2 / Section 4: model diagnostics and multiplicity control")
part2_require_file(PART2_MODEL_FILE)
load(PART2_MODEL_FILE)

model_residuals <- stats::residuals(anova_fit)
model_fitted <- stats::fitted(anova_fit)
shapiro <- stats::shapiro.test(model_residuals)

cell_group <- student$design_cell
cell_median <- ave(student$math_score, cell_group, FUN = stats::median)
brown_forsythe_fit <- stats::lm(abs(student$math_score - cell_median) ~ cell_group)
brown_forsythe <- stats::anova(brown_forsythe_fit)[1L, ]

cook <- stats::cooks.distance(anova_fit)
cook_threshold <- 4 / nrow(student)
assumptions <- data.frame(
  Assumption = c(
    "Residual normality", "Homogeneity of variance", "Independence",
    "Influential observations"
  ),
  Assessment = c(
    "Shapiro-Wilk test (sensitive at n=1,000)",
    "Brown-Forsythe median-based test across four cells",
    "Not testable: source lacks school, class, or sampling-cluster IDs",
    paste0("Cook's distance > 4/n: ", sum(cook > cook_threshold),
           "; maximum = ", formatC(max(cook), digits = 4L, format = "f"))
  ),
  Statistic = c(
    unname(shapiro$statistic), unname(brown_forsythe$`F value`), NA_real_,
    max(cook)
  ),
  P_value = c(
    shapiro$p.value, unname(brown_forsythe$`Pr(>F)`), NA_real_, NA_real_
  ),
  stringsAsFactors = FALSE
)
save_part2_table(
  assumptions, "tab_part2_assumptions",
  "Assumption and model-adequacy checks.",
  "tab:part2-assumptions", digits = 4L
)

open_part2_pdf("fig_part2_diagnostics.pdf", width = 8, height = 7)
graphics::par(mfrow = c(2, 2), mar = c(3.7, 4.0, 2.5, 0.8))
graphics::plot(
  model_fitted, model_residuals, pch = 16, cex = 0.55,
  col = grDevices::adjustcolor("#4477AA", alpha.f = 0.55),
  xlab = "Fitted value", ylab = "Residual", main = "Residuals vs fitted"
)
graphics::abline(h = 0, lty = 2, col = "#CC6677")
stats::qqnorm(
  model_residuals, pch = 16, cex = 0.48,
  col = grDevices::adjustcolor("#4477AA", alpha.f = 0.55),
  main = "Normal Q-Q"
)
stats::qqline(model_residuals, col = "#CC6677", lwd = 2)
graphics::plot(
  model_fitted, sqrt(abs(stats::rstandard(anova_fit))), pch = 16, cex = 0.55,
  col = grDevices::adjustcolor("#4477AA", alpha.f = 0.55),
  xlab = "Fitted value", ylab = expression(sqrt("|standardized residual|")),
  main = "Scale-location"
)
graphics::abline(h = mean(sqrt(abs(stats::rstandard(anova_fit)))),
                 lty = 2, col = "#CC6677")
graphics::plot(
  cook, type = "h", col = "#4477AA", xlab = "Observation index",
  ylab = "Cook's distance", main = "Influence"
)
graphics::abline(h = cook_threshold, lty = 2, col = "#CC6677")
grDevices::dev.off()

matrix_by_cell <- part2_model_matrix(anova_fit)
simple_contrasts <- list(
  `Preparation effect | free/reduced lunch` =
    matrix_by_cell[3L, ] - matrix_by_cell[1L, ],
  `Preparation effect | standard lunch` =
    matrix_by_cell[4L, ] - matrix_by_cell[2L, ],
  `Lunch effect | no preparation` =
    matrix_by_cell[2L, ] - matrix_by_cell[1L, ],
  `Lunch effect | completed preparation` =
    matrix_by_cell[4L, ] - matrix_by_cell[3L, ]
)
simple_matrix <- do.call(
  rbind,
  lapply(simple_contrasts, function(contrast) {
    linear_contrast(anova_fit, contrast)
  })
)
simple_effects <- data.frame(
  Contrast = rownames(simple_matrix), simple_matrix,
  Holm_P_value = stats::p.adjust(simple_matrix[, "P_value"], method = "holm"),
  row.names = NULL, check.names = FALSE
)
save_part2_table(
  simple_effects[, c("Contrast", "Estimate", "SE", "t", "P_value",
                     "Holm_P_value", "CI_low", "CI_high")],
  "tab_part2_simple_effects",
  "Simple two-level contrasts with Holm-adjusted p-values.",
  "tab:part2-simple-effects", digits = 4L
)
simple_display <- data.frame(
  Contrast = simple_effects$Contrast,
  Estimate = simple_effects$Estimate,
  `Holm p` = vapply(simple_effects$Holm_P_value, format_part2_p, character(1L)),
  check.names = FALSE,
  stringsAsFactors = FALSE
)
save_part2_table(
  simple_display, "tab_part2_simple_effects_display",
  "Follow-up simple effects with Holm-adjusted p-values.",
  "tab:part2-simple-display", digits = 3L
)

robust_covariance <- hc3_vcov(anova_fit)
effect_contrasts <- part2_effect_contrasts(anova_fit)
robust_matrix <- do.call(
  rbind,
  lapply(effect_contrasts, function(contrast) {
    linear_contrast(anova_fit, contrast, covariance = robust_covariance)
  })
)
robust_sensitivity <- data.frame(
  Effect = rownames(robust_matrix), robust_matrix,
  row.names = NULL, check.names = FALSE
)
save_part2_table(
  robust_sensitivity[, c("Effect", "Estimate", "SE", "t", "P_value",
                         "CI_low", "CI_high")],
  "tab_part2_robust_sensitivity",
  "HC3 heteroskedasticity-robust sensitivity analysis.",
  "tab:part2-robust", digits = 4L
)

save(
  assumptions, simple_effects, robust_sensitivity, cook_threshold,
  file = file.path(paths$models, "part2_diagnostics.RData")
)
log_step("Part 2 Section 4 complete: diagnostics and follow-up contrasts saved")
