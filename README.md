# ASESII 24A02 — Project-Based Quiz 1: Group 01

> Ridge, Lasso, and Regularization for Neural Features

## Project Overview
This project predicts body fat percentage (`brozek`) from the `fat.csv` dataset using linear and regularized models, exploring their mathematical properties and connection to deep learning.

## Prerequisites
- **R 4.5.x** (the lockfile was created with R 4.5.2)
- **LaTeX** distribution with `latexmk` and XeLaTeX
- **GNU Make** (optional, for automated builds)

Restore the exact R package versions recorded in `renv.lock`:

```bash
Rscript -e "if (!requireNamespace('renv', quietly = TRUE)) install.packages('renv', repos = 'https://cloud.r-project.org'); renv::restore(prompt = FALSE)"
```

The tracked `.Rprofile` adds the restored project library to `.libPaths()` for
interactive tools such as VSCode-R. Analysis scripts also add the same library
through `R_models/setup.R` and stop with a clear restore command if a dependency
is unavailable.

## LaTeX Setup
The report must be compiled with XeLaTeX. pdfLaTeX is not supported because the
report contains Unicode Vietnamese names.

Recommended options:

- **TeX Live full install:** includes the needed packages.
- **MiKTeX:** enable automatic package installation, or install the packages
  listed in `report/latex-packages.txt`.

The report uses TeX-distribution fonts (`TeX Gyre Termes`) rather than local
system fonts, so it should not depend on `C:/Windows/Fonts` or any one user's
computer.

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

If GNU Make is not available, run the same workflow manually from the project
root:

```bash
Rscript -e "if (!requireNamespace('renv', quietly = TRUE)) install.packages('renv', repos = 'https://cloud.r-project.org'); renv::restore(prompt = FALSE)"
Rscript R_models/00_run_all.R
cd report
latexmk -C main.tex
latexmk -xelatex -interaction=nonstopmode -halt-on-error main.tex
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
- `report/` — LaTeX source files
- `output/` — Generated figures and tables
- `submission/ASESII_24A02_ProjectQuiz1_Group01/` — Package folder ready for submission containing:
  - `Group01_ProjectQuiz1.Rmd` (self-contained reproducible report)
  - `references.bib` (bibliography database)
  - `README.txt` (replication instructions)
- `CONTRIBUTING.md` — Team roster, workflow, and tasks
- `MEMORY.md` — Project context, status, and decisions
- `AGENTS.md` — AI assistant instructions
