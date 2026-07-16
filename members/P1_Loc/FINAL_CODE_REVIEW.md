# Final Code Review

**Reviewer status:** End-of-day final pass  
**Project status:** Approximately 90% complete  
**Date:** 16 July 2026

## Overall verdict

The core statistical implementation is credible and no fatal modeling bug was found. Ridge, Lasso, Elastic Net, random neural features, shared cross-validation folds, fixed seeds, and final holdout evaluation are implemented coherently. The test response is not used during model training or tuning.

The remaining work is not limited to LaTeX. There are several reproducibility, build, plotting, and methodological issues that should be addressed before submission.

## Review findings

### 1. Submission package is not self-contained - High priority

`submission/ASESII_24A02_ProjectQuiz1_Group01/Group01_ProjectQuiz1.Rmd` searches only its own directory and one parent directory for `fat.csv`. The actual project dataset is two levels above the Rmd, and no copy is included in the submission folder. A recipient following the supplied README therefore cannot render the submission as documented.

### 2. Submission dependencies are not fully captured by `renv` - High priority

The submission Rmd loads or requires `tidyverse`, `broom`, `knitr`, and `rmarkdown`, but these packages are not all recorded in the current `renv.lock`. The submission directory is also excluded by `.renvignore`. The Rmd dependencies should either be reduced to packages already used by the main pipeline or explicitly captured in the reproducible environment.

### 3. Authorship statement needs reconciliation - High priority

Repository history contains 15 commits, all authored by Loc. The report currently states that all members participated in design, implementation, and review. Git cannot rule out genuine offline contributions, but the final contribution statement should describe each person's work specifically and should not claim equal implementation without supporting evidence.

### 4. Report build can retain stale figures - Medium priority

The PDF target in the `Makefile` does not depend on the generated figures, tables, or final holdout outputs. Consequently, an R figure can be regenerated while `report/main.pdf` is still considered up to date. The report target should depend on the analysis outputs or force the required R stages before compilation.

### 5. Cross-validation preprocessing has minor fold leakage - Medium priority

The predictor scaler is fitted once using the complete training set before five-fold cross-validation. Each validation fold therefore contributes slightly to the means and standard deviations used by its corresponding training fold. This is not holdout-test leakage and does not invalidate the final results, but fold-specific preprocessing would provide cleaner CV estimates.

### 6. Submission text and disclosure need cleanup - Medium priority

- A control character corrupts an `\alpha` expression in the submission Rmd.
- Some report text gives Elastic Net RMSE as `4.274`, whereas the current result is approximately `4.2711`.
- The submission references `Group01_AI_Log.csv`, but that file is absent.
- The LaTeX AI log does not fully record the later `renv` migration, packaging work, and final closeout changes.

### 7. Holdout figure coloring is unfinished - Low priority

`R_models/04_holdout.R` calculates distinct colors for the models but does not pass those colors to the final bar plot. This is a real plotting-code issue and contributes to the current figure-quality problem.

## Checks that passed

- All ten R source files parse successfully.
- `y_test` is used for scoring only in `04_holdout.R`.
- Training/test separation, fixed seeds, and shared fold assignments are consistently applied.
- The main modular R pipeline is represented adequately by the current `renv` environment.
- The existing LaTeX report has no fatal compilation error, unresolved citation, or unresolved cross-reference.
- The member task files already assign the final figure-polishing work according to R-script ownership.

## Contribution assessment

Based on repository evidence, Loc performed essentially all committed implementation and integration work. Other members may have contributed outside Git, but those contributions are not currently visible in the repository history and should be documented precisely if they are included in the authorship statement.

## Recommended completion order

1. Make the submission package reproducible from its documented directory.
2. Reconcile the authorship statement and complete the AI-use disclosure.
3. Correct the report build dependencies.
4. Decide whether to implement fold-specific scaling and document that decision.
5. Complete the assigned figure-polishing work.
6. Regenerate all outputs, compile the final PDF, and perform one final consistency check.

No analysis files were changed as part of this review.
