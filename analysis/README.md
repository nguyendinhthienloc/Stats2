# Analysis pipeline

Open `Stats2.Rproj` with R 4.5.2, restore once with `renv::restore()`, then run the complete workflow in the RStudio Console:

```r
source('analysis/00_run_all.R')
```

The terminal equivalent is:

```text
Rscript --vanilla analysis/00_run_all.R
```

`00_run_all.R` is the only supported full-run entry point. It runs these stages in order:

1. `01_eda_cleaning.R` -- Part 1 sections 1 and 2: training-only EDA, cleaning, the locked split, preprocessing, and shared folds.
2. `02_feature_selection.R` -- Part 1 section 3: baseline and feature-selection diagnostics.
3. `03_regularized_models.R` -- Part 1 section 4: Ridge, Lasso, Elastic Net, and the pre-holdout model lock.
4. `04_holdout_evaluation.R` -- Part 1 section 5: the only stage allowed to inspect holdout outcomes.
5. `05_part2_experimental_design.R` -- Part 2 scaffold; dataset choice and analysis remain TODO.

The root stages are the canonical integration of the completed Part 1 work under `finals/part1/`. Individual numbered files may be run during development only after their upstream artifacts exist. Generated files in `data/processed/` and `output/` are disposable build artifacts: never hand-edit them.
