# Part 1 — Red Wine Quality Regression

This folder is a self-contained, reproducible Part 1 submission for Group 08.
It follows `references/STAT452_FinalProject_Y2526.pdf` and intentionally uses
only the red-wine data from `final_resources/wine+quality.zip`.

## Reproduce everything

From the repository root, run:

```powershell
Rscript --vanilla finals/part1/R/00_build_part1.R
```

That command runs the five R workstreams in order, writes the audit log,
figures, tables, fitted models, shared data, and artifact manifest. It does not
require Pandoc, LaTeX, PowerPoint, or any document renderer.

The direct pipeline command is equivalent:

```powershell
Rscript --vanilla finals/part1/R/00_run_all.R
```

The first run extracts a portable copy of `winequality-red.csv` and its metadata
into `data/`.  Later runs can therefore use this folder independently of the
repository, provided the generated data files are retained.

## Analysis contract

- Task: regression on the numeric `quality` score; no arbitrary good/poor cutoff.
- Exact duplicate records are removed before splitting to prevent identical
  profiles from appearing in both training and holdout sets.
- The split is quality-stratified, 80/20, with fixed seeds.
- EDA and preprocessing decisions use training data only.
- Missing-value imputation, winsorization limits, centering, and scaling are fit
  without holdout outcomes.  CV refits those quantities inside every fold.
- OLS is the baseline. Ridge, Lasso, and Elastic Net use the same five folds and
  lambda grid. Elastic Net alpha is also selected by CV.
- The model preferred by CV is written to `output/model_lock.csv` before the
  holdout script is run.
- `y_test` is created and used only in `R/04_holdout.R`.

## Five-person work split

The project is divided into five independently reviewable workstreams:

1. P1 — Exploratory Data Analysis.
2. P2 — Data Cleaning.
3. P3 — Feature Selection.
4. P4 — Modelling with Regularization.
5. P5 — Evaluation.

Detailed ownership, interfaces, and cross-review expectations are in
`collaboration/WORK_SPLIT.md`. These labels organize the work; the final
authorship statement must be confirmed by the actual group members.

## Artifact layout

- `R/` — modular R analysis and build scripts.
- `report/` — master R Markdown content and five smaller owned sections.
- `presentation/` — 10-minute presentation content in R Markdown.
- `data/` — portable raw red-wine data and metadata copy.
- `output/figures/` — PDF figures.
- `output/tables/` — matching CSV and LaTeX tables.
- `output/models/` — serialized fitted models and summaries.
- `output/logs/` — pipeline log and session information.
- `output/shared_data.RData` — the shared train/holdout-predictor interface.
- `output/artifact_manifest.csv` — generated-file sizes and checksums.
