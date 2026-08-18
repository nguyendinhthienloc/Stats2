# STAT452 Final Project TODO

Project: Group 8, Project 03 - Wine Quality (Red)  
Course: STAT452, Academic Year 2025-2026  
Default planning assumption: treat `quality` as a regression target. Confirm this before model implementation.

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
- [x] Keep `renv.lock` current whenever an R dependency is added or upgraded; automated checks enforce synchronization.
- [x] Verify a clean clone can restore packages and run the analysis top-to-bottom (tested with a separate empty project library on 2026-08-18).
- [ ] Require CI to pass before merging changes.

## Decisions needed before analysis

- [ ] Confirm the primary task: regression on the 0-10 score (recommended) or a documented good/poor classification rule.
- [ ] Choose the held-out test proportion and document the split protocol before inspecting test outcomes.
- [ ] Confirm primary metrics. Suggested regression metrics: RMSE (primary), MAE, and R-squared.
- [ ] Decide whether repeated cross-validation is needed in addition to fixed shared folds.
- [ ] Select a separate real-world dataset for Part 2 with at least two categorical factors and a continuous response, or at least two two-level factors for a factorial design.

## Part 1 - Wine Quality supervised-learning workflow

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

- [ ] Keep the held-out test target unused until every modelling decision is locked.
- [ ] Compare all models on the identical test rows and metrics.
- [ ] Add uncertainty estimates where practical.
- [ ] Diagnose residual patterns and influential observations.
- [ ] Discuss the bias-variance trade-off, practical error size, limitations, and honest negative results.

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

## Suggested ownership discussion

| Member | Suggested lead | Reviewer |
|---|---|---|
| Trần Lê Anh Tuấn | Part 1 EDA and cleaning | To assign |
| Nguyễn Bảo Minh Triết | Feature selection and diagnostics | To assign |
| Nguyễn Đình Thiên Lộc | Regularized modelling and integration | To assign |
| Nguyễn Hồng Tấn Tài | Part 2 experimental design | To assign |
| Lê Minh Thuận | Report and presentation | To assign |

Every result should have a second-person review, regardless of lead ownership.

## Definition of done

- [x] A clean clone restores dependencies without manual fixes.
- [x] `Rscript --vanilla scripts/reproduce.R` passes locally.
- [ ] CI is green on GitHub and required before merging.
- [ ] The complete analysis runs top-to-bottom with fixed seeds.
- [ ] No preprocessing, feature selection, or tuning uses held-out test outcomes.
- [ ] The report PDF, source bundle, and presentation are generated and reviewed.
- [ ] Every claim is traceable to code, output, or a cited source.
