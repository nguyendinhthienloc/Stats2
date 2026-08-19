# Session changes - 2026-07-16

## Scope

This session repaired the R execution environment and statistical pipeline,
fixed LaTeX compilation and Unicode typesetting issues, regenerated the
analysis outputs, and documented what remains before submission.

## R changes

- Made `setup.R` locate the project reliably, prefer the project-local
  `.Rlib`, validate namespaces, and print timestamped progress messages.
- Added `R_models/00_run_all.R` as the reproducible eight-stage entry point.
- Standardized every analysis script on the shared setup and five-fold split.
- Corrected training-only scaling and constant-column handling.
- Configured all `glmnet` fits consistently for Gaussian regression with
  `standardize = FALSE` after explicit training-set scaling.
- Added both `lambda.min` and `lambda.1se` Ridge/Lasso coefficient results.
- Corrected OLS out-of-fold predictions and expanded the core comparison with
  tuning rule, CV error, coefficient norms, and nonzero counts.
- Added the required Lasso bootstrap selection-frequency analysis.
- Corrected condition numbers to use `G = X'X/n` and `G + lambda I`.
- Added the Elastic Net coefficient path and selected alpha using unrounded CV
  results.
- Corrected random neural-feature biases to `N(0, 0.5^2)` and reused the same
  random feature parameters for training and test data.
- Added a locked, training-only deployment declaration before holdout scoring.
- Saved `output/session_info.txt` and clearer logs for reproducibility.

## LaTeX changes

- Configured the report language as English, selected explicit Times New Roman
  font files with full Unicode coverage, and corrected the authors' names.
- Fixed an invalid nested table input in the prediction-design section.
- Corrected math-package ordering and table-column alignment warnings.
- Updated reproduction instructions to use `latexmk -xelatex`.
- Included the generated R session information in the report.
- Replaced the placeholder AI log with the work and verification performed in
  this session.

## Verification and current results

`Rscript R_models/00_run_all.R` completed all 8 stages successfully. The
predeclared deployment model was Lasso. Its holdout results were RMSE 4.2514,
MAE 3.5237, and R-squared 0.6834. The next-best holdout model was Elastic Net
with alpha 0.9 and RMSE 4.2711.

The 20-page report was rebuilt with XeLaTeX. The final build contains no LaTeX
errors or warnings, undefined references, undefined citations, missing
characters, box overflows, or undefined control sequences. Unicode author names
were checked in both a rendered page and the extracted PDF text layer.

## Has the R code done everything?

**Yes for the computational analysis required by the project specification.**
The code now performs the reproducible split, shared five-fold CV, training-only
preprocessing, OLS/Ridge/Lasso/Elastic Net analyses, perturbation study,
conditioning analysis, random ReLU-feature models, locked holdout comparison,
artifact generation, and session recording.

**No for the project as a complete submission.** The remaining work is mainly
human-authored report content and packaging:

- Complete the contribution and human-verification statements for every team
  member; these cannot be inferred from code activity.
- Finish the abstract, interpretations, mathematical explanation, research
  question and source map, deep-learning discussion, recommendation, and
  limitations where the TeX source still contains `TODO` markers.
- Add and verify the required primary references and dataset source citation.
- Confirm whether the instructor accepts the current R-script plus LaTeX
  workflow. The quiz specification requests a named `.Rmd` submission, while
  this repository currently generates the report from separate R and TeX
  files.
- Create the exact submission archive and any specifically named `README.txt`
  required by the quiz instructions.

The numerical pipeline is complete; the report and submission package are not
yet complete.
