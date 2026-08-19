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
models, logs, and manifests to root `output/`. Do not invoke the nested
`R/00_run_all.R` or `R/00_build_part1.R`; those pre-merge entry
points are retired.

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

## Historical artifacts

Tracked files already present under `finals/part1/output/` are a
pre-merge snapshot made with the old nested configuration. They are retained
only as review history and are not canonical results. In particular, do not
mix their model lock or metrics with artifacts regenerated under root
`output/` and seed `4520803`.
