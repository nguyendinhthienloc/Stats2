# MEMORY.md — Project Context & Status

> Persistent memory and technical details. Update as the project evolves.

## Project Status
| Component | Status | Notes |
|-----------|--------|-------|
| Repo structure | ✅ Done | Makefile, directories ready |
| `setup.R` | ✅ Done | Helpers ready |
| `01_data_prep_eda.R` | ✅ Done | Shared data and EDA generated |
| R Model Scripts | ✅ Scaffolded | P2/P3/P5 need to execute |
| LaTeX report | 🚧 In Progress | P1 section done, needs more content |
| Math derivations | ✅ Partial | P4 needs to complete |

**Current Phase:** Phase 2 — Core Models (Tuan/P2 and Thuan/P3 are up next).

## Key Decisions
1. **Separate Workflow:** R scripts + LaTeX compiled via `latexmk` (not RMarkdown).
2. **Excluded Columns:** `siri`, `density`, `free` dropped to prevent test leakage.
3. **Data Splitting:** 80/20 train/test split.
4. **Cross-Validation:** 5-fold CV, shared `foldid`.

## Dataset Quick Reference
- **File:** `data/fat.csv` (252 rows, Group 01)
- **Response:** `brozek` (body fat %)
- **Predictors (14):** age, weight, height, adipos, neck, chest, abdom, hip, thigh, knee, ankle, biceps, forearm, wrist.

## Technical Details & Gotchas
- **Reproducibility:** R package names are declared in `requirements.txt`; `setup.R` and `R_models/install_requirements.R` install missing packages from that list. This is lightweight dependency declaration, not exact version pinning. Use `renv.lock` later if exact package versions must be frozen.
- **Seeds:** `240201` (split), `240301` (CV folds), `240401` (random ReLU features).
- **`glmnet` standardize:** Set `standardize=FALSE` since `fit_scaler()` is used manually.
- **Condition number:** `safe_condition_numbers()` may return `Inf` if `X'X` is singular.
- **ReLU features:** `relu(x_train %*% A + bias)` may yield all-zero columns.

## Script Dependency Graph
```
setup.R ◄── sourced by ALL scripts
     │
01_data_prep_eda.R ──► shared_data.RData
     │
     ├── 02_ols.R ──► ols_fit.RData
     ├── 02_ridge.R ──► ridge_fit.RData
     ├── 02_lasso.R ──► lasso_fit.RData
     │        │
     │        └── 02_comparison.R (needs previous three)
     │
     ├── 04_enet.R ──► enet_fits.RData
     ├── 04_neural.R ──► neural_fits.RData
     │
     └── 04_holdout.R (FIRST use of y_test, needs ALL previous fits)
```
