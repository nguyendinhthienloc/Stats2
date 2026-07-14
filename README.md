# ASESII 24A02 — Project-Based Quiz 1: Group 01

> Ridge, Lasso, and Regularization for Neural Features

## Team

| Name   | Student ID | Role |
|--------|-----------|------|
| Loc    | 24125093  | P1 — Data & EDA (Problem 1) |
| Tuan   | 24125107  | P2 — OLS & Ridge (Problem 2A-2B) |
| Thuan  | 24125105  | P3 — Lasso & Comparison (Problem 2C-2E) |
| Triet  | 24125047  | P4 — Math Derivations (Problem 3) |
| Tai    | 24125078  | P5 — Elastic Net, Neural Features & Report (Problem 4-5) |

## Prerequisites

- **R** (>= 4.0) with packages: `tidyverse`, `glmnet`, `broom`, `knitr`, `xtable`, `corrplot`
- **LaTeX** distribution with `latexmk` (e.g., TeX Live, MiKTeX)
- **GNU Make** (optional, for automated builds)

### Install R packages

```r
install.packages(c("tidyverse", "glmnet", "broom", "knitr", "xtable", "corrplot"))
```

## Repository Structure

```

├── Makefile                  # Build automation
├── data/fat.csv              # Raw dataset (read-only)
├── CONTRIBUTING.md           # Git workflow, roles, and task tracker
├── MEMORY.md                 # Project status and decisions log
├── R_models/                        # R scripts (numbered by problem)
│   ├── setup.R            # Shared config & helpers
│   ├── 01_data_prep_eda.R         # P1: Data prep & EDA
│   ├── 02_ols.R             # P2: OLS baseline
│   ├── 02_ridge.R           # P2: Ridge regression
│   ├── 02_lasso.R           # P3: Lasso regression
│   ├── 02_comparison.R      # P3: Model comparison & perturbation
│   ├── 04_enet.R     # P5: Elastic net
│   ├── 04_neural.R # P5: Random ReLU features
│   └── 04_holdout.R         # P5: Final holdout evaluation
├── output/                   # Generated outputs (gitignored)
│   ├── figures/              # PDF plots
│   └── tables/               # LaTeX tables
├── LaTeX_report/                   # LaTeX source
│   ├── main.tex              # Master document
│   ├── preamble.sty          # Packages & macros
│   ├── references.bib        # Bibliography
│   ├── sections/             # One .tex per problem
│   └── appendices/           # AI log appendix
└── Group01_AI_Log.csv        # AI usage log
```

## How to Build

### Option 1: Full automated build (recommended)

```bash
cd .
make all
```

This runs all R scripts in dependency order, then compiles the LaTeX report.

### Option 2: Step-by-step

```bash
# Step 1: Generate shared data + EDA (must run first)
Rscript R_models/01_data_prep_eda.R

# Step 2: Run model scripts (can be run in parallel after Step 1)
Rscript R_models/02_ols.R
Rscript R_models/02_ridge.R
Rscript R_models/02_lasso.R
Rscript R_models/02_comparison.R    # needs OLS, Ridge, Lasso fits
Rscript R_models/04_enet.R
Rscript R_models/04_neural.R
Rscript R_models/04_holdout.R       # needs ALL model fits

# Step 3: Compile report
cd LaTeX_report
latexmk -pdf main.tex
```

### Option 3: Report only (if outputs already exist)

```bash
make report
```

## Important Rules

1. **Never use `y_test` outside `04_holdout.R`** — this is the holdout set
2. **Scaling is train-only** — fit on training data, apply to test
3. **Use the shared `foldid`** — ensures fair CV comparison across models
4. **Seeds are fixed** — split=240201, cv=240301, features=240401

## Clean

```bash
make clean
```
