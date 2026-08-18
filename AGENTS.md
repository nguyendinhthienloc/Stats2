# AGENTS.md - Final Project Instructions

## Project identity

- Task: STAT452 Applied Statistics II Final Project.
- Group: 8.
- Part 1 dataset: Project 03, Wine Quality (Red).
- Goal: complete the required supervised-learning workflow and a separate experimental-design extension.
- Read `README.md` and `TODO.md` before making project changes.
- The previous midterm project is read-only history under `legacy/midterm/`.

## R conventions

- Every active analysis script must source `R/setup.R` near the top.
- Never hardcode a machine-specific project directory. Resolve paths from the script location or project root.
- Treat `data/raw/` as immutable. Write reproducible derived data to `data/processed/`.
- Use the shared seed and paths defined in `R/setup.R`.
- Fit transformations, feature selection, and tuning on training/resampling data only.
- Do not inspect or use held-out test outcomes outside `analysis/04_holdout_evaluation.R`.
- Save figures as PDF files under `output/figures/`.
- Save LaTeX-ready tables with `save_table_tex()` under `output/tables/`.
- Print progress with `cat(">>> Step description\n")` or the shared logging helpers.
- Mark unfinished work as `# TODO: description`.

## Analysis order

1. `analysis/01_eda_cleaning.R`
2. `analysis/02_feature_selection.R`
3. `analysis/03_regularized_models.R`
4. `analysis/04_holdout_evaluation.R`
5. `analysis/05_part2_experimental_design.R`

`analysis/00_run_all.R` is the only supported full-run entry point.

## Report conventions

- The final report must remain within 20 pages excluding appendices.
- Use XeLaTeX for Unicode member names.
- Cite datasets, methods, packages, and external claims.
- Reference generated files; do not paste manually edited numerical results into the report.
- Mark unfinished prose as `TODO:` so validation can find it.

## Before merging

- Run `make check`.
- Run the affected analysis stages.
- Render the report when report or output changes.
- Update `TODO.md`, documentation, and `renv.lock` when applicable.
- Preserve unrelated work and do not modify `legacy/midterm/` unless explicitly asked.
