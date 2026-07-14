# AGENTS.md — AI Assistant Instructions

> Read this file first when working on this project.
> It saves tokens by giving you the full context upfront.

## Project Identity

- **What:** Midterm (Project-Based Quiz 1) for Applied Statistics II
- **Topic:** Ridge, Lasso, Elastic Net regularization + neural-feature bridge
- **Dataset:** `fat.csv` — 252 rows, 14 predictors → predict `brozek` (body fat %)
- **Group:** 01 (odd → fat.csv)
- **Language:** R code, LaTeX report, English text

## Architecture

```
R scripts (R_models/*.R)  ──►  output/ (figures + tables)  ──►  LaTeX (LaTeX_report/)  ──►  PDF
     │                        │                              │
  setup.R              .RData files                    main.tex
  (sourced by all)        .pdf figures                    (inputs sections/)
                          .tex tables
```

**Build:** `make all` or step-by-step via `Rscript` then `latexmk -pdf`.

## File Naming Conventions

| Type | Pattern | Example |
|------|---------|---------|
| R scripts | `NN_description.R` or `NNx_description.R` | `02_ridge.R` |
| Figures | `fig_description.pdf` | `fig_p2_ridge_cv.pdf` |
| Tables | `tab_description.tex` | `tab_p2_comparison.tex` |
| LaTeX sections | `NN_topic.tex` | `03_math_mechanisms.tex` |
| Saved models | `model_fit.RData` | `ridge_fit.RData` |

## Key Technical Constraints

1. **NO test leakage.** `y_test` is used ONLY in `R_models/04_holdout.R`. Every other
   script must use only `x_train`, `y_train`, and `foldid` for fitting/selection.
2. **Train-only scaling.** `fit_scaler()` on training data, then `apply_scaler()`
   to both train and test using training statistics.
3. **Shared `foldid`.** All `cv.glmnet()` calls use the same `foldid` vector for
   fair comparison. Generated once in `01_data_prep_eda.R`, saved in `shared_data.RData`.
4. **Fixed seeds.** `split=240201`, `cv=240301`, `features=240401`. Never change these.

## Code Style (R)

- Source `setup.R` at the top of every script
- Load shared data: `load("output/shared_data.RData")`
- Save figures as PDF: `pdf("output/figures/fig_name.pdf", width=7, height=5)`
- Save tables using `save_table_tex()` helper or `knitr::kable(format="latex")`
- Print progress with `cat(">>> Step description\n")`
- Mark unfinished sections with `# TODO: description`

## Code Style (LaTeX)

- Use `\includefigure{filename}{caption}{label}` macro (auto-placeholder if missing)
- Table inputs: `\input{../output/tables/tab_name}` (comment out until generated)
- Cross-references: `\ref{fig:name}`, `\ref{tab:name}`, `\ref{sec:name}`
- Citations: `\citet{Key}` (textual) or `\citep{Key}` (parenthetical)
- Math vectors bold: `\bx`, `\by`, `\bbeta`; matrices: `\bX`
- Use `% TODO:` for incomplete sections

## Work Ownership

| Person | Files Owned | Don't Touch Without Asking |
|--------|------------|---------------------------|
| P1 Loc | `setup.R`, `01_data_prep_eda.R`, `00_authorship.tex`, `01_prediction_design.tex` | Shared helpers, data pipeline |
| P2 Tuan | `02_ols.R`, `02_ridge.R`, OLS & Ridge parts of `02_ols_ridge_lasso.tex` | OLS and Ridge model code |
| P3 Thuan | `02_lasso.R`, `02_comparison.R`, Lasso & comparison parts of `02_ols_ridge_lasso.tex` | Lasso and comparison code |
| P4 Triet | `03_math_mechanisms.tex` | Math derivations |
| P5 Tai | `04_enet.R`, `04_neural.R`, `04_holdout.R`, `04_elastic_net.tex`, `05_report_quality.tex`, `00_abstract.tex` | Elastic net, neural, holdout |

## Common AI Tasks

When asked to help with this project, you'll likely be:

1. **Writing/debugging R code** — always source `setup.R`, load `shared_data.RData`
2. **Writing LaTeX sections** — use the macros from `preamble.sty`, check existing structure
3. **Interpreting results** — explain statistical output, create tables/plots
4. **Math derivations** — use the custom math commands (`\bbeta`, `\norm{}`, `\argmin`)
5. **Reviewing for leakage** — check that `y_test` is never used before `04_holdout.R`

## References for Context

- Problem statement: `../midterm_resources/ASESII_24A02_ProjectExam_Ridge_Lasso_ProblemStatement.pdf`
- RMarkdown template (reference): `../midterm_resources/templates/ASESII_24A02_ProjectExam_SampleSubmission.Rmd`
- Course notes: `../Notes/Chap1_Notes.pdf` through `Chap4_Notes.pdf`
- Project plan: See MEMORY.md
