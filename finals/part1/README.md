# Part 1 implementation modules

This directory preserves the five Part 1 workstreams and report sections
integrated by the root project. It is not a standalone project and does not
define a second reproducibility contract.

## Canonical run

Open `Stats2.Rproj` and run:

```r
source('analysis/00_run_all.R')
```

The terminal equivalent is:

```text
Rscript --vanilla analysis/00_run_all.R
```

The canonical runner reads immutable inputs from root `data/raw/`, writes
derived interfaces to `data/processed/`, and writes figures, tables,
models, logs, and manifests to root `output/`. The pre-merge nested runners
and duplicate holdout script have been removed; use the root entry point.

## Five reviewable workstreams

1. Exploratory data analysis and data audit.
2. Cleaning and training-only preprocessing.
3. Feature selection and the OLS baseline.
4. Ridge, Lasso, and Elastic Net with a pre-holdout model lock.
5. One-time held-out evaluation in
   `analysis/04_holdout_evaluation.R`.

Detailed ownership and cross-review expectations are in
`finals/part1/collaboration/WORK_SPLIT.md`. The labels organize work;
the final contribution statement must reflect what members actually completed
and reviewed.

## Generated artifacts

No data or generated results are stored in this module directory. The
canonical runner reads root `data/raw/`, writes derived interfaces to root
`data/processed/`, and writes every generated artifact to root `output/`.
Do not recreate `finals/part1/data/` or `finals/part1/output/`.
