# Contributing

## Working agreement

1. Start from an up-to-date branch and choose one bounded item from `TODO.md`.
2. Record modelling decisions before viewing held-out test outcomes.
3. Keep raw inputs immutable and generate every processed file from code.
4. Add or update validation whenever a data contract or pipeline stage changes.
5. Ask another member to review statistical reasoning as well as code.

## Branches and commits

- Use short branches such as `eda/outliers`, `model/ridge-lasso`, or `part2/anova`.
- Keep commits focused and describe the statistical decision, not only the file edit.
- Do not commit local R libraries, credentials, temporary files, or generated LaTeX intermediates.

## Reproducibility rules

- Source `R/setup.R` from every analysis script.
- Open `Stats2.Rproj`, select R 4.5.2, and run `renv::restore()` before the first RStudio run.
- Use `source('analysis/00_run_all.R')` for the complete RStudio pipeline; use the direct `Rscript` commands in `README.md` in a terminal.
- Use the shared split and resampling objects once they are created.
- Fit preprocessing and feature selection without held-out test data.
- Use `analysis/04_holdout_evaluation.R` as the single test-set boundary.
- Update `renv.lock` after intentional dependency changes.
- Never hand-edit files under `data/processed/` or `output/`; update their owning source and regenerate them.

## Review checklist

- The code runs from the repository root and from a clean environment.
- Seeds and resampling folds are explicit.
- Claims match generated output.
- Metrics are appropriate and computed on the same rows for every model.
- Tables and figures have labels, units, readable text, and captions.
- Limitations and alternative explanations are stated honestly.
- `Rscript --vanilla scripts/ci_check.R` passes. `make check` is an optional convenience wrapper for the same command.
