# STAT452 Final Project TODO

Project: Group 8, Project 03 - Wine Quality (Red)  
Course: STAT452, Academic Year 2025-2026  
Locked Part 1 protocol: regression on `quality`; seed `4520803`; 80/20 stratified train/holdout split; five shared cross-validation folds; RMSE primary, with MAE and R-squared secondary.

## Status key

- [ ] Not started
- [x] Complete
- [~] In progress or awaiting a decision

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
- [x] Re-run the integrated Part 1 workflow under locked R 4.5.2 and locally validate the generated artifacts.
- [ ] Require CI to pass before merging changes.

## Decisions needed before analysis

- [x] Model the 0-10 quality score as a regression response.
- [x] Use project seed `4520803` and an 80/20 split stratified by observed quality score; keep holdout outcomes inaccessible before Stage 4.
- [x] Use RMSE as the primary metric, with MAE and R-squared as secondary metrics.
- [x] Use five fixed shared cross-validation folds; repeated cross-validation is not part of the locked primary workflow.
- [ ] Select a separate real-world dataset for Part 2 with at least two categorical factors and a continuous response, or at least two two-level factors for a factorial design.

## Part 1 - Wine Quality supervised-learning workflow

The canonical scripts now implement every Part 1 item below. Items remain
unchecked until the assigned lead and a second member review the generated
result and interpretation; checking a box records human sign-off, not merely
the presence of code.

### 1. Exploratory data analysis

- [ ] Create a variable dictionary with units, types, ranges, and target definition.
- [ ] Audit duplicates, impossible values, missing values, and class/score frequencies.
- [ ] Plot predictor and target distributions.
- [ ] Examine pairwise relationships and the predictor correlation structure.
- [ ] Summarize modelling implications, including skew, collinearity, nonlinear patterns, and rare quality scores.

### 2. Data cleaning and preprocessing

- [ ] Define outlier rules using training data only; distinguish measurement errors from valid extreme wines.
- [ ] Justify any removals, winsorization, or robust treatment.
- [ ] Evaluate transformations for skewed variables.
- [ ] Fit centering/scaling parameters on training data only and apply them unchanged to validation/test data.
- [ ] Save the processed analysis data and a machine-readable preprocessing summary.

### 3. Feature selection

- [ ] Use at least one principled method, such as VIF/correlation screening or embedded Lasso selection.
- [ ] Perform selection inside resampling to avoid optimistic estimates.
- [ ] Report selected predictors, stability, and substantive interpretation.

### 4. Baseline and regularized models

- [ ] Fit a defensible baseline model.
- [ ] Fit Ridge regression with cross-validated regularization strength.
- [ ] Fit Lasso regression with the same resampling folds.
- [ ] Fit Elastic Net or justify why two regularized models are sufficient.
- [ ] Plot coefficient paths and compare shrinkage/selection behaviour.
- [ ] Record seeds, folds, tuning grids, fitted preprocessing objects, and model objects.

### 5. Held-out evaluation

- [x] Keep the held-out test target unused until every modelling decision is locked.
- [x] Compare all models on the identical test rows and metrics.
- [x] Add uncertainty estimates where practical.
- [x] Diagnose residual patterns and influential observations.
- [x] Discuss the bias-variance trade-off, practical error size, limitations, and honest negative results.

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
- [x] The complete analysis runs top-to-bottom with fixed seeds.
- [x] No preprocessing, feature selection, or tuning uses held-out test outcomes.
- [ ] The report PDF, source bundle, and presentation are generated and reviewed.
- [x] Every claim is traceable to code, output, or a cited source.
