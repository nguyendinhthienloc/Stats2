# ASESII 24A02 — Project-Based Quiz 1: Group 01

> Ridge, Lasso, and Regularization for Neural Features

## Project Overview
This project predicts body fat percentage (`brozek`) from the `fat.csv` dataset using linear and regularized models, exploring their mathematical properties and connection to deep learning.

## Prerequisites
- **R** (>= 4.0) with: `tidyverse`, `glmnet`, `broom`, `knitr`, `xtable`, `corrplot`
- **LaTeX** distribution with `latexmk`
- **GNU Make** (optional, for automated builds)

## Quick Start
```bash
# Full automated build
make all

# Clean outputs
make clean
```

For step-by-step execution, see `CONTRIBUTING.md`.

## Key Rules (DO NOT VIOLATE)
1. **No Test Leakage:** `y_test` must ONLY be used in `04_holdout.R`.
2. **Train-Only Scaling:** Fit scaler on training data, apply to test.
3. **Shared Folds:** Use the shared `foldid` from `shared_data.RData` for fair CV.
4. **Fixed Seeds:** 240201 (split), 240301 (CV), 240401 (features).

## Repository Map
- `data/` — Raw dataset
- `R_models/` — R scripts for analysis
- `LaTeX_report/` — LaTeX source files
- `output/` — Generated figures and tables
- `CONTRIBUTING.md` — Team roster, workflow, and tasks
- `MEMORY.md` — Project context, status, and decisions
- `AGENTS.md` — AI assistant instructions
