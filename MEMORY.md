# MEMORY.md — Project Context & Status

> Persistent memory and technical details. Update as the project evolves.

## Project Status
| Component | Status | Notes |
|-----------|--------|-------|
| Repo structure | ✅ Done | Makefile, directories ready |
| `setup.R` | ✅ Done | Robust paths, renv activation, namespace checks, and clear logs |
| `01_data_prep_eda.R` | ✅ Done | Shared data and EDA regenerated on 2026-07-16 |
| R Model Scripts | ✅ Done | Full eight-script pipeline verified via `00_run_all.R` |
| LaTeX report | ✅ Done | Clean English XeLaTeX build with fixed TOC and refined title page aesthetics |
| Math derivations | ✅ Done | Completed and checked against numeric training eigenvalues |
| Submission folder | ✅ Done | Prepared `Group01_ProjectQuiz1.Rmd`, references, and replication README |
| Final holdout | ✅ Done | Predeclared Lasso had the best RMSE: 4.2514 |

**Current Phase:** Phase 5 — completed and ready for submission packaging.

## Latest Verified Run (2026-07-16)
- `Rscript R_models/00_run_all.R` completed all eight scripts successfully in dependency order.
- Expected model files, LaTeX tables, and PDF figures were regenerated and verified as non-empty.
- Final holdout ranking was led by the predeclared Lasso: RMSE 4.2514, MAE 3.5237, $R^2$ 0.6834.
- `y_test` remains used only in `04_holdout.R`.

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
- **Reproducibility:** `renv.lock` freezes the verified R 4.5.2 package environment. The tracked `.Rprofile` and `renv/activate.R` select an ignored project library, `renv::restore()` reconstructs it, and `setup.R` verifies the two direct runtime dependencies (`glmnet` and `xtable`) before analysis scripts run. Archived course examples and generated submission files are excluded from dependency discovery through `.renvignore`. The working Windows environment locks `glmnet` 4.1-10 because the installed 5.0 DLL was blocked by Windows Application Control.
- **Pipeline runner:** `R_models/00_run_all.R` executes the analysis in dependency order and reports timestamped `STEP`, `INFO`, and `ERROR` messages.
- **LaTeX language support:** `report/main.tex` loads English Babel only. `preamble.sty` uses explicit Windows Times New Roman font files under XeLaTeX so Unicode author names are embedded correctly without adding a second document language or relying on MiKTeX's incomplete font-name database.
- **Seeds:** `240201` (split), `240301` (CV folds), `240401` (random ReLU features).
- **Cross-validation:** One shared five-fold `foldid` is reused by OLS comparison, Ridge, Lasso, Elastic Net, and all random-feature models.
- **`glmnet` standardize:** Set `standardize=FALSE` since `fit_scaler()` is used manually.
- **Condition number:** `safe_condition_numbers()` evaluates $G=X^TX/n$ on the same scale as the `glmnet` Gaussian objective and may return `Inf` when its smallest eigenvalue is numerically zero.
- **ReLU features:** $A_{jm}\sim N(0,1/p)$ and $c_m\sim N(0,0.5^2)$ are generated once; constant hidden features are detected using `H_train` only and removed from both matrices.

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
