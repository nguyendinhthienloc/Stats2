# MEMORY.md — Project Context & Status

> Persistent memory for AI assistants. Update this file as the project evolves.
> Last updated: 2026-07-14

## Project Status

| Component | Status | Notes |
|-----------|--------|-------|
| Repo structure | ✅ Done | All directories, Makefile, .gitignore created |
| `setup.R` | ✅ Scaffolded | Helpers + config ready, needs team review |
| `01_data_prep_eda.R` | ✅ Scaffolded | TODO: run and verify EDA plots |
| `02_ols.R` | ✅ Scaffolded | TODO: Tuan to run and interpret |
| `02_ridge.R` | ✅ Scaffolded | TODO: Tuan to run and interpret |
| `02_lasso.R` | ✅ Scaffolded | TODO: Thuan to run and interpret |
| `02_comparison.R` | ✅ Scaffolded | TODO: Thuan to run after OLS/Ridge/Lasso |
| `04_enet.R` | ✅ Scaffolded | TODO: Tai to run and interpret |
| `04_neural.R` | ✅ Scaffolded | TODO: Tai to run and interpret |
| `04_holdout.R` | ✅ Scaffolded | TODO: Tai to run LAST |
| LaTeX report | ✅ Scaffolded | All sections have structure + TODO markers |
| Math derivations | ✅ Partial | Ridge derivation pre-written, Lasso needs review |
| Bibliography | ✅ Done | 10 key references added |
| AI Log | ✅ Template | Team must fill in as they go |

## Current Phase

**Phase 1 — Foundation** (Loc/P1 must complete first)
- [ ] Run `01_data_prep_eda.R` successfully
- [ ] Verify `shared_data.RData` is generated
- [ ] Review EDA figures
- [ ] Push to repo so team can pull

## Key Decisions Made

1. **LaTeX over RMarkdown** — Chose separate R scripts + LaTeX (compiled via
   latexmk) instead of RMarkdown, for cleaner separation of code and report.
2. **Makefile build system** — Dependencies ensure scripts run in correct order.
3. **fat.csv dataset** — Group 01 is odd → uses fat.csv, predicts `brozek`.
4. **Excluded columns** — `siri`, `density`, `free` removed to prevent leakage
   (they are alternative body fat calculations or directly derived from density).
5. **14 predictors** — age, weight, height, adipos, neck, chest, abdom, hip,
   thigh, knee, ankle, biceps, forearm, wrist.
6. **80/20 split** — ~201 training, ~51 test rows (exact counts depend on seed).
7. **5-fold CV** — shared `foldid` for all `cv.glmnet()` comparisons.

## Dataset Quick Reference

- **File:** `data/fat.csv`
- **Rows:** 252
- **Columns:** 18 (4 excluded → 14 predictors + 1 response)
- **Response:** `brozek` (continuous, body fat %)
- **Known issues:** Possible outlier(s) in body measurements; multicollinearity
  between circumference measurements (chest, abdom, hip, thigh).

## Seeds

| Purpose | Seed Value | Used In |
|---------|-----------|---------|
| Train/test split | `240201` | `01_data_prep_eda.R` → `split_rows()` |
| Cross-validation folds | `240301` | `01_data_prep_eda.R` → `make_foldid()` |
| Random ReLU features | `240401` | `04_neural.R` |

## Dependencies Between Scripts

```
setup.R ◄── sourced by ALL scripts
     │
01_data_prep_eda.R ──► shared_data.RData
     │
     ├── 02_ols.R ──► ols_fit.RData
     ├── 02_ridge.R ──► ridge_fit.RData
     ├── 02_lasso.R ──► lasso_fit.RData
     │        │
     │        └── 02_comparison.R (needs all three fits)
     │
     ├── 04_enet.R ──► enet_fits.RData
     ├── 04_neural.R ──► neural_fits.RData
     │
     └── 04_holdout.R (needs ALL fits, FIRST use of y_test)
```

## Gotchas & Warnings

- **`glmnet` standardize=FALSE** — We pre-standardize manually via `fit_scaler()`,
  so pass `standardize=FALSE` to `cv.glmnet()`. This is already set in the
  `fit_cv_glmnet()` helper.
- **Condition number can be Inf** — If `X'X` is singular (rare with fat data but
  check), `safe_condition_numbers()` returns `Inf` for the Gram matrix.
- **ReLU features dimension** — After `relu(x_train %*% A + bias)`, some columns
  may be all-zero. The scaler drops constant columns automatically.
- **LaTeX compile order** — Must run `latexmk -pdf` (not just `pdflatex`) to
  resolve cross-references and bibliography in one command.

## Changelog

| Date | Who | What |
|------|-----|------|
| 2026-07-14 | Loc (AI-assisted) | Initial repo scaffolding: all R scripts, LaTeX report, Makefile, AGENTS.md, MEMORY.md |
