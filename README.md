# ASESII 24A02 — Project-Based Quiz 1: Group 01

> Ridge, Lasso, and Regularization for Neural Features

## Project Overview
This project predicts body fat percentage (`brozek`) from the `fat.csv` dataset using linear and regularized models, exploring their mathematical properties and connection to deep learning.

## Prerequisites
- **R 4.5.x** (the lockfile was created with R 4.5.2)
- **LaTeX** distribution with `latexmk`
- **GNU Make** (optional, for automated builds)

Restore the exact R package versions recorded in `renv.lock`:

```bash
Rscript -e "renv::restore(prompt = FALSE)"
```

The tracked `.Rprofile` activates the project library automatically. Analysis
scripts also activate it through `R_models/setup.R` if the startup profile is
bypassed, and stop with a clear restore command if a locked dependency is
unavailable.

## Quick Start
```bash
# Full automated build
make all

# Clean outputs
make clean
```

`make all` restores `renv.lock` before running the analysis. After intentionally
adding or upgrading an R package, run `renv::snapshot()` and commit the updated
lockfile; never commit the generated `renv/library/` directory.

For step-by-step execution, see `CONTRIBUTING.md`.

## Key Rules (DO NOT VIOLATE)
1. **No Test Leakage:** `y_test` must ONLY be used in `04_holdout.R`.
2. **Train-Only Scaling:** Fit scaler on training data, apply to test.
3. **Shared Folds:** Use the shared `foldid` from `shared_data.RData` for fair CV.
4. **Fixed Seeds:** 240201 (split), 240301 (CV), 240401 (features).


## Repository Map
- `data/` — Raw dataset
- `R_models/` — R scripts for analysis
- `report/` — LaTeX source files
- `output/` — Generated figures and tables
- `ASESII_24A02_ProjectQuiz1_Group01/` — Package folder ready for submission containing:
  - `Group01_ProjectQuiz1.Rmd` (self-contained reproducible report)
  - `references.bib` (bibliography database)
  - `README.txt` (replication instructions)
- `CONTRIBUTING.md` — Team roster, workflow, and tasks
- `MEMORY.md` — Project context, status, and decisions
- `AGENTS.md` — AI assistant instructions
