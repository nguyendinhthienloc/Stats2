# Prompt: Fix Report Template Compliance

You are working in the `D:\Stats2` project for the Applied Statistics II midterm project.

Your task is to make the report follow the official project template and rubric more closely, without changing the statistical intent of the existing work.

## Context

The project predicts `brozek` body fat percentage from `fat.csv` for Group 01.

The official problem statement expects:

- an RMarkdown-style reproducible report, or at minimum a report that clearly includes reproducible R code;
- declared packages;
- fixed seeds;
- a clean train/test split;
- train-only preprocessing;
- shared 5-fold cross-validation folds;
- no use of `y_test` until the final holdout section;
- a contribution statement;
- AI use documentation;
- `sessionInfo()`;
- exact reproduction instructions.

The current repository uses separate R scripts in `R_models/` and a LaTeX report in `report/`.
This is acceptable only if the report clearly documents how the scripts reproduce the results.

## Important Rules

Do not use `y_test` outside `R_models/04_holdout.R`.

Do not fit scalers on the test set.

Do not change the response or predictor set.

Use:

- response: `brozek`
- excluded variables: `brozek`, `siri`, `density`, `free`
- candidate predictors: `age`, `weight`, `height`, `adipos`, `neck`, `chest`, `abdom`, `hip`, `thigh`, `knee`, `ankle`, `biceps`, `forearm`, `wrist`
- split seed: `240201`
- CV seed: `240301`
- random feature seed: `240401`
- 5-fold cross-validation, not 10-fold.

## Fixes Needed

1. Check that `R_models/01_data_prep_eda.R` uses:

```r
foldid <- make_foldid(n = nrow(x_train), nfolds = 5L, seed = seeds$cv)
```

Then rerun the pipeline so `output/shared_data.RData` actually contains 5 folds.

2. Update `report/sections/01_prediction_design.tex`:

- replace any mention of `K = 10` or `10-fold` with `K = 5` or `5-fold`;
- state exact split sizes: 201 training observations and 51 test observations;
- state missing values: 0 missing values found;
- cite Johnson (1996) as the source of the body-fat dataset;
- explicitly state the unit of observation: one adult male subject/body measurement record;
- explain why `siri`, `density`, and `free` are leakage variables;
- include one anomaly, for example original row 39 has an unusually high `hip` z-score around 6.75;
- end the EDA subsection with a specific question regularized models will answer, such as:
  "Since several body measurements are highly correlated, can regularized regression improve prediction stability and identify which measurements are most useful for predicting `brozek`?"

3. Fix report figure and table filenames so they match generated outputs:

- `fig_corr_heatmap` should be `fig_p1_correlation`;
- `fig_p2_ridge_coef_bar` should be `fig_p2_ridge_coef`;
- `fig_enet_alpha_comparison` should be `fig_p4_enet_cv`;
- `fig_neural_cv` does not currently exist, so either create a combined figure or reference existing neural figures:
  - `fig_p4_neural_ridge_cv`
  - `fig_p4_neural_lasso_cv`
  - `fig_p4_neural_active`
- `tab_holdout_comparison` should be `tab_p4_holdout`.

4. Fix misleading comments in `report/main.tex`:

- `02_ols_ridge_lasso` is Problem 2;
- `03_math_mechanisms` is Problem 3;
- `04_elastic_net` is Problem 4;
- `05_report_quality` is Problem 5.

5. Remove or fill all visible TODOs before submission:

- authorship section;
- abstract;
- Problem 2 interpretations and core model declaration;
- Problem 3 numerical connection;
- Problem 4 research question, source map, Elastic Net/ReLU interpretation, locked declaration, deep-learning limitations;
- Problem 5 final recommendation, limitations, reproduction record;
- AI log.

6. Add reproducibility content to the report:

- list required R packages;
- include exact script execution order;
- include fixed seeds;
- include where `y_test` first enters the computation;
- include `sessionInfo()` output, either generated into the report or included as an appendix/table.

7. Verify after changes:

- run `Rscript R_models/01_data_prep_eda.R`;
- rerun downstream scripts that depend on `foldid`;
- compile the report;
- confirm there are no missing figure placeholders caused by filename mismatches;
- confirm no visible `TODO` remains in the final PDF;
- confirm `output/shared_data.RData` has exactly 5 CV folds.

## Expected Output

Make the smallest safe edits needed to bring the report into template/rubric compliance.

At the end, report:

- which files were changed;
- whether the R pipeline was rerun;
- whether the PDF compiled;
- any remaining limitations or unresolved items.
