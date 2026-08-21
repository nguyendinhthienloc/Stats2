###############################################################################
# Part 2 / Section 5: practical interpretation, limitations, and integration.
###############################################################################

source(file.path("R", "setup.R"))
source(file.path(PROJECT_ROOT, "finals", "part2", "R", "part2_helpers.R"))

log_step("Part 2 / Section 5: integrating findings and limitations")
part2_require_file(PART2_MODEL_FILE)
diagnostic_file <- file.path(paths$models, "part2_diagnostics.RData")
part2_require_file(diagnostic_file)
load(PART2_MODEL_FILE)
load(diagnostic_file)

effect_lookup <- setNames(seq_len(nrow(effects)), effects$Effect)
eta_lookup <- setNames(
  anova_table$Partial_eta_squared[seq_len(3L)], anova_table$Term[seq_len(3L)]
)
effect_labels <- c(
  "Preparation: completed - none",
  "Lunch: standard - free/reduced",
  "Interaction: difference in preparation effects"
)
plain_labels <- c(
  "Test-preparation association", "Lunch-group association",
  "Preparation-by-lunch interaction"
)
key_findings <- do.call(
  rbind,
  lapply(seq_along(effect_labels), function(i) {
    row <- effects[effect_lookup[[effect_labels[[i]]]], ]
    data.frame(
      Finding = plain_labels[[i]],
      Contrast = effect_labels[[i]],
      Estimate_points = row$Estimate,
      CI_low = row$CI_low,
      CI_high = row$CI_high,
      P_value = row$P_value,
      Partial_eta_squared = eta_lookup[[effect_labels[[i]]]],
      Decision = if (row$P_value < PART2_ALPHA) "Reject H0" else "Do not reject H0",
      stringsAsFactors = FALSE
    )
  })
)
save_part2_table(
  key_findings, "tab_part2_key_findings",
  "Confirmatory results, raw-point effects, and practical effect sizes.",
  "tab:part2-key-findings", digits = 4L
)
key_findings_display <- data.frame(
  Effect = key_findings$Finding,
  `Estimate (95% CI)` = sprintf(
    "%.2f [%.2f, %.2f]", key_findings$Estimate_points,
    key_findings$CI_low, key_findings$CI_high
  ),
  F = anova_table$F_value[seq_len(3L)],
  p = vapply(key_findings$P_value, format_part2_p, character(1L)),
  `Partial eta2` = key_findings$Partial_eta_squared,
  check.names = FALSE,
  stringsAsFactors = FALSE
)
save_part2_table(
  key_findings_display, "tab_part2_key_findings_display",
  "Two-factor ANOVA results with point-scale and standardized effect sizes.",
  "tab:part2-key-findings-display", digits = 3L
)

limitations <- data.frame(
  Limitation = c(
    "Observational exposure assignment", "Undocumented dependence",
    "Unmeasured confounding", "Bounded discrete response",
    "Public-source provenance"
  ),
  Consequence = c(
    "Associations cannot be interpreted as causal effects",
    "School/class clustering cannot be checked or modelled",
    "Prior attainment, income, attendance, and school quality are absent",
    "Gaussian residual normality may be imperfect near 0 and 100",
    "The Kaggle file does not document a randomized collection protocol"
  ),
  Improvement = c(
    "Use a randomized preparation intervention",
    "Collect school and classroom identifiers and use multilevel analysis",
    "Collect a pre-test and key contextual covariates",
    "Pre-specify a robust or ordinal sensitivity model",
    "Use a dataset with a study protocol and data dictionary"
  ),
  stringsAsFactors = FALSE
)
save_part2_table(
  limitations, "tab_part2_limitations",
  "Limitations and design improvements.",
  "tab:part2-limitations", digits = 0L
)

part2_summary <- list(
  design = list(
    response = "math_score",
    factor_a = "test_preparation",
    factor_b = "lunch",
    observations = nrow(student),
    alpha = PART2_ALPHA,
    causal = FALSE
  ),
  descriptive = utils::read.csv(
    file.path(paths$tables, "tab_part2_descriptive_statistics.csv"),
    stringsAsFactors = FALSE
  ),
  anova = anova_table,
  effects = effects,
  cell_estimates = cell_estimates,
  assumptions = assumptions,
  simple_effects = simple_effects,
  robust_sensitivity = robust_sensitivity,
  key_findings = key_findings,
  limitations = limitations
)
save(part2_summary, file = PART2_SUMMARY_FILE)

log_step("Part 2 complete: report-ready summary saved to output/part2_summary.RData")
