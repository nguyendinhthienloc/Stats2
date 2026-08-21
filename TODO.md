# STAT452 Final Project TODO

Project: Group 8, Project 03 - Wine Quality (Red)  
Course: STAT452, Academic Year 2025-2026  
Locked Part 1 protocol: regression on `quality`; seed `4520803`; 80/20 stratified train/holdout split; five shared cross-validation folds; RMSE primary, with MAE and R-squared secondary.

## Status key

- [ ] Not started
- [x] Complete
- [~] Implemented or in progress, but still awaiting review or a decision

## Current project status

- [x] Nguyễn Đình Thiên Lộc created and organized the final-project framework, including the reproducible repository structure, canonical analysis stages, shared setup, CI configuration, report scaffold, and archived midterm history (`3f56e2d`).
- [x] Nguyễn Bảo Minh Triết integrated the Part 1 modules into the canonical workflow and ran Part 1 successfully under the locked R 4.5.2 environment (`af46786`; completed 2026-08-19).
- [x] The successful Part 1 run generated the expected processed data, figures, tables, fitted models, holdout summary, and artifact manifest. The holdout boundary and generated artifacts passed local validation.
- [~] Part 1 is computationally complete. Section leads and second reviewers still need to check the statistical interpretation, refine the report prose, and record their sign-off.
- [ ] Part 2, the final report review, and the presentation remain to be completed.

## Milestone 0 - Repository and reproducibility

- [x] Archive the legacy midterm project under `legacy/midterm/`.
- [x] Place the supplied Wine Quality archive and extracted source files under `data/raw/`.
- [x] Validate the red-wine file contract: 1,599 rows, 11 predictors, and the `quality` target.
- [x] Add CI for cross-platform analysis checks, MiKTeX PDF rendering, and artifact upload.
- [x] Standardize the PDF toolchain on MiKTeX and document direct terminal commands for every workflow.
- [x] Add the R language server to the reproducible `renv` environment for editor support.
- [x] Document Fedora 43/44 setup.
- [x] Keep `renv.lock` current whenever an R dependency is added or upgraded; automated checks enforce synchronization.
- [x] Verify the pre-integration scaffold could restore from a clean library (2026-08-18 historical setup test).
- [x] Run the integrated Part 1 workflow under locked R 4.5.2; Triet's local run and artifact validation passed on 2026-08-19.
- [~] Confirm the integrated Part 1 workflow passes on every configured CI platform.
- [ ] Require CI to pass before merging changes.

## Decisions needed before analysis

- [x] Model the 0-10 quality score as a regression response.
- [x] Use project seed `4520803` and an 80/20 split stratified by observed quality score; keep holdout outcomes inaccessible before Stage 4.
- [x] Use RMSE as the primary metric, with MAE and R-squared as secondary metrics.
- [x] Use five fixed shared cross-validation folds; repeated cross-validation is not part of the locked primary workflow.
- [ ] Select a separate real-world dataset for Part 2 with at least two categorical factors and a continuous response, or at least two two-level factors for a factorial design.

## Part 1 - Wine Quality supervised-learning workflow

The canonical scripts implement and successfully run every Part 1 section.
The `[~]` items below have working code and generated outputs, but remain open
until the assigned lead and a second member review the result and its
interpretation. Change an item to `[x]` only after that human sign-off.

### 1. Exploratory data analysis

- [~] Create and review a variable dictionary with units, types, ranges, and target definition.
- [~] Review the audit of duplicates, impossible values, missing values, and score frequencies.
- [~] Review the predictor and target distribution plots.
- [~] Review pairwise relationships and the predictor correlation structure.
- [~] Refine and approve the modelling implications, including skew, collinearity, nonlinear patterns, and rare quality scores.

### 2. Data cleaning and preprocessing

- [~] Review the training-only outlier rules and distinction between measurement errors and valid extreme wines.
- [~] Review and approve the justification for removals, winsorization, or robust treatment.
- [~] Review the transformation choices for skewed variables.
- [~] Verify that centering/scaling parameters are fitted on training data only and applied unchanged to validation/holdout data.
- [~] Review the generated processed analysis data and machine-readable preprocessing summary.

### 3. Feature selection

- [x] Review the implemented principled feature-selection methods.
- [x] Verify that selection occurs inside resampling where required to avoid optimistic estimates.
- [x] Review the selected predictors, stability results, and substantive interpretation.

### 4. Baseline and regularized models

- [~] Review the fitted baseline model and its justification.
- [~] Review Ridge regression with cross-validated regularization strength.
- [~] Review Lasso regression fitted with the shared resampling folds.
- [~] Review Elastic Net and its tuning strategy.
- [~] Review the coefficient paths and comparison of shrinkage/selection behaviour.
- [~] Verify the recorded seeds, folds, tuning grids, fitted preprocessing objects, and model objects.

### 5. Held-out evaluation

- [~] Review the validation evidence that held-out outcomes remained unused until modelling decisions were locked.
- [~] Review the comparison of all models on identical holdout rows and metrics.
- [~] Review the uncertainty estimates and document any limitations.
- [~] Review the residual and influential-observation diagnostics.
- [~] Refine and approve the discussion of bias-variance trade-offs, practical error size, limitations, and honest negative results.

## Part 2 - Experimental-design extension

- [ ] Select and cite an appropriate external dataset.
- [ ] Justify two-factor ANOVA or a `2^k` factorial design with `k >= 2`.
- [ ] State research questions and null/alternative hypotheses before fitting models.
- [ ] Produce descriptive statistics, boxplots, histograms, and interaction plots.
- [ ] Check normality, homogeneity of variance, and independence assumptions.
- [ ] Fit the ANOVA/factorial model and interpret main and interaction effects.
- [ ] Perform residual and model-adequacy diagnostics.
- [ ] Run Tukey HSD, Bonferroni, or another justified post-hoc procedure when warranted.
- [ ] Separate statistical significance from practical significance.
- [ ] Summarize limitations, improvements, and actionable conclusions.

## Report, presentation, and submission

- [ ] Keep the written report at or below 20 pages, excluding appendices.
- [ ] Cite the UCI dataset, methods, packages, and every external source.
- [ ] Ensure the report can be rendered from a clean environment.
- [ ] Prepare a 10-minute presentation with a timed rehearsal.
- [ ] Add a concise contribution statement for all five group members.
- [ ] Package the PDF report, reproducible R Markdown/source code, and presentation.
- [ ] Assemble the final submission artifacts after CI passes.

## Part 1 ownership and review

The section leads below remain responsible for subject-matter review. In
addition, Loc completed the project framework and Triet completed the canonical
Part 1 integration and successful locked-environment run; these project-level
contributions should be reflected in the final contribution statement.

| Section | Lead | Canonical stage | Reviewer |
|---|---|---|---|
| 1. Exploratory data analysis | Nguyễn Đình Thiên Lộc (`24125093`) | `analysis/01_eda_cleaning.R` (EDA outputs) | To assign |
| 2. Data cleaning | Trần Lê Anh Tuấn (`24125107`) | `analysis/01_eda_cleaning.R` (cleaning/preprocessing outputs) | To assign |
| 3. Feature selection | Lê Minh Thuận (`24125105`) | `analysis/02_feature_selection.R` | To assign |
| 4. Modelling with regularization | Nguyễn Bảo Minh Triết (`24125047`) | `analysis/03_regularized_models.R` | To assign |
| 5. Held-out evaluation | Nguyễn Hồng Tấn Tài (`24125078`) | `analysis/04_holdout_evaluation.R` | To assign |

Every result should have a second-person review, regardless of lead ownership.

## Definition of done

- [x] A clean clone restores dependencies without manual fixes.
- [x] `Rscript --vanilla scripts/reproduce.R` passes locally.
- [ ] CI is green on GitHub and required before merging.
- [x] The complete Part 1 analysis runs top-to-bottom with fixed seeds under R 4.5.2.
- [x] Local validation confirms that preprocessing, feature selection, and tuning do not use held-out outcomes.
- [ ] The report PDF, source bundle, and presentation are generated and reviewed.
- [ ] Every claim is traceable to code, output, or a cited source.
