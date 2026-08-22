# STAT452 Final Project TODO

Project: Group 8, Project 03 — Wine Quality (Red)
Course: STAT452, Academic Year 2025–2026
Locked Part 1 protocol: regression on `quality`; seed `4520803`; 80/20 quality-stratified train/holdout split; five shared cross-validation folds; RMSE primary, with MAE and R-squared secondary.

## Status key

- [ ] External or human action still required
- [x] Completed and locally verified
- [~] Deliverable is ready; final human/external confirmation remains

## Current project status

- [x] Parts 1 and 2 run through the canonical pipeline and pass output validation under R 4.5.2.
- [x] The final report source, retained LaTeX, and MiKTeX/XeLaTeX PDF are complete.
- [x] The substantive report ends on PDF page 19; appendices occupy pages 20–23 and references pages 24–25.
- [x] A ten-slide editable presentation is complete; speaker-note timings total 10:00 and every slide contains a `[Sources]` block.
- [x] Local submission artifacts are assembled under `submission/`.
- [~] Technical integration review is complete; the five students must still confirm the contribution statement and second-person review sign-off.

## Repository and reproducibility

- [x] Preserve the legacy midterm project under `legacy/midterm/`.
- [x] Keep the Wine Quality and Student Performance source files immutable under `data/raw/`.
- [x] Validate the Wine Quality contract: 1,599 rows, 11 predictors, and numeric `quality`.
- [x] Validate the Student Performance contract: 1,000 rows, eight variables, valid scores/factor levels, and tracked MD5 checksum.
- [x] Keep `renv.lock`, `DESCRIPTION`, and the R 4.5.2 library synchronized.
- [x] Run `scripts/ci_check.R`, the full canonical pipeline, and `scripts/validate_outputs.R` locally.
- [x] Verify that no serialized or processed holdout outcome is exposed before Stage 4.
- [x] Generate an artifact manifest with sizes and MD5 checksums.
- [ ] Confirm the final commit passes every configured GitHub Actions platform.
- [ ] Enable/confirm branch protection requiring CI before merge.

## Part 1 — Wine Quality supervised learning

### Exploratory data analysis

- [x] Review the variable dictionary, types, units, ranges, and target definition.
- [x] Review duplicates, impossible/non-finite values, missingness, and score frequencies.
- [x] Review predictor/target distributions, pairwise relationships, and the correlation structure.
- [x] Document skew, multicollinearity, overlap, rare scores, and modelling implications.

### Cleaning and preprocessing

- [x] Remove exact duplicate profiles before splitting and document the provenance limitation.
- [x] Retain scientifically plausible IQR outliers; winsorize predictors at training 1st/99th percentiles.
- [x] Select log transformations from training data and reselect them inside each CV analysis fold.
- [x] Fit imputation, clipping, centering, and scaling inside each CV analysis fold and apply unchanged to validation data.
- [x] Fit the final preprocessor on all training predictors and apply it unchanged to predictor-only holdout data.

### Feature selection and baselines

- [x] Review marginal correlations, VIFs, AIC sensitivity, and embedded Lasso selection.
- [x] Keep screening/AIC as interpretation sensitivity rather than a holdout-tuned subset.
- [x] Use fold-clean mean and OLS baselines.
- [x] Add and review OLS Cook's-distance and leverage diagnostics.

### Regularized models

- [x] Fit Ridge, Lasso, and Elastic Net with a shared five-fold design and 120-value lambda grid.
- [x] Tune Elastic Net alpha on the same folds.
- [x] Review CV curves, coefficient paths, shrinkage, and one-SE sparsity.
- [x] Lock Ridge by minimum CV RMSE before reconstructing holdout outcomes.

### Held-out evaluation

- [x] Compare Mean, OLS, Ridge, Lasso, and Elastic Net on the same 271 holdout rows.
- [x] Report RMSE, MAE, R-squared, and 1,000-replicate bootstrap RMSE intervals.
- [x] Review residual shape, large prediction errors, rare-score performance, and bias–variance implications.
- [x] Preserve the honest negative result: OLS and the regularized models are practically tied on holdout RMSE.

## Part 2 — Observational two-factor extension

- [x] Correct and review the Timothy Adeyemi Kaggle citation and immutable-source checksum.
- [x] Justify the observational 2×2 analysis and prohibit causal language.
- [x] Pre-specify mathematics score, preparation, lunch, and three two-sided hypotheses.
- [x] Review all four cell summaries, histograms, boxplots, and interaction plots.
- [x] Fit the effect-coded full interaction model and report marginal effects, interaction, confidence intervals, F tests, and partial eta-squared.
- [x] Review Shapiro–Wilk, Brown–Forsythe, independence limitations, Cook's distance, and graphical diagnostics.
- [x] Review HC3 sensitivity and Holm-adjusted simple contrasts.
- [x] Separate score-point/practical significance from statistical significance.
- [x] State non-causal limitations and propose a randomized preparation study with baseline blocking.

## Report, presentation, and submission

- [x] Keep the written report at or below 20 pages excluding appendices (19 substantive pages).
- [x] Cite datasets, regularization methods, CV/bootstrap, diagnostics, R, `glmnet`, `knitr`, and `rmarkdown`.
- [x] Generate all numerical statements from code/output rather than hand-edited report values.
- [x] Retain `report/final-report.tex` and compile `report/final-report.pdf` with MiKTeX XeLaTeX.
- [x] Visually inspect every report page for clipping, overlap, missing glyphs, and misplaced floats.
- [x] Add the five-member contribution statement based on repository history and module ownership.
- [x] Create `presentation/final-presentation.pptx` with ten slides, editable charts, source notes, and a 10:00 talk track.
- [x] Run slide overflow checks and inspect every rendered slide at full size.
- [x] Package the PDF report, LaTeX source, presentation, and reproducible source bundle under `submission/`.
- [ ] The five students confirm the contribution statement and required second-person reviews.
- [ ] The group performs and records an actual timed rehearsal.
- [ ] Upload the final package after GitHub CI is green.

## Ownership and assigned second review

| Section | Lead | Assigned reviewer |
|---|---|---|
| Part 1 EDA | Nguyễn Đình Thiên Lộc | Trần Lê Anh Tuấn |
| Part 1 cleaning | Trần Lê Anh Tuấn | Lê Minh Thuận |
| Part 1 feature selection | Lê Minh Thuận | Nguyễn Bảo Minh Triết |
| Part 1 regularized modelling | Nguyễn Bảo Minh Triết | Nguyễn Hồng Tấn Tài |
| Part 1 held-out evaluation | Nguyễn Hồng Tấn Tài | Nguyễn Đình Thiên Lộc |
| Part 2 data/design | Nguyễn Đình Thiên Lộc | Trần Lê Anh Tuấn |
| Part 2 descriptive analysis | Trần Lê Anh Tuấn | Lê Minh Thuận |
| Part 2 factorial ANOVA | Lê Minh Thuận | Nguyễn Hồng Tấn Tài |
| Part 2 diagnostics/follow-up | Nguyễn Hồng Tấn Tài | Nguyễn Bảo Minh Triết |
| Part 2 interpretation/integration | Nguyễn Bảo Minh Triết | Nguyễn Đình Thiên Lộc |

## Local definition of done

- [x] `Rscript --vanilla scripts/ci_check.R` passes.
- [x] `Rscript --vanilla analysis/00_run_all.R` passes.
- [x] `Rscript --vanilla scripts/validate_outputs.R` passes.
- [x] The final report PDF and retained LaTeX compile through Pandoc + MiKTeX XeLaTeX.
- [x] Every report claim is traceable to generated output or a cited source.
- [x] The report and presentation have completed automated and visual QA.
