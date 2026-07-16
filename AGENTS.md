# AGENTS.md — AI Assistant Instructions

> Instructions specifically for AI assistants (like ChatGPT, Claude, Antigravity) working on this project. Read this first to understand code conventions and tasks.

## Project Identity
- **Task:** Applied Statistics II Midterm Project
- **Goal:** Predict body fat (`brozek`) using Ridge, Lasso, Elastic Net, and random Neural Features.
- **Context:** Check `README.md` for rules, `CONTRIBUTING.md` for task assignments, and `MEMORY.md` for technical context and status.

## AI Code Style (R)
- **Shared Config:** Always source `setup.R` at the top of scripts.
- **Shared Data:** Load processed data using `load("output/shared_data.RData")`.
- **Plotting:** Save figures as PDFs: `pdf("output/figures/fig_name.pdf", width=7, height=5)`.
- **Tables:** Use `save_table_tex()` (from `setup.R`) or `knitr::kable(format="latex")`.
- **Logging:** Print progress with `cat(">>> Step description\n")`.
- **Incomplete Work:** Mark with `# TODO: description`.

## AI Code Style (LaTeX)
- **Figures:** Use the custom `\includefigure{filename}{caption}{label}` macro (it generates placeholders if the PDF is missing).
- **Tables:** Input them safely: `\input{../output/tables/tab_name}` (comment out if not yet generated).
- **Cross-refs:** Use standard `\ref{fig:name}`, `\ref{tab:name}`, `\ref{sec:name}`.
- **Citations:** Use `\citet{Key}` for inline and `\citep{Key}` for parenthetical.
- **Math:** Use `\bx`, `\by`, `\bbeta`, `\bX`, `\norm{}`, `\argmin` (defined in preamble).
- **Incomplete Work:** Mark with `% TODO: description`.

## File Naming Conventions
| Type | Pattern | Example |
|------|---------|---------|
| R scripts | `NN_description.R` | `02_ridge.R` |
| Figures | `fig_description.pdf` | `fig_p2_ridge_cv.pdf` |
| Tables | `tab_description.tex` | `tab_p2_comparison.tex` |
| LaTeX sections | `NN_topic.tex` | `03_math_mechanisms.tex` |
| Saved models | `model_fit.RData` | `ridge_fit.RData` |

## Common AI Tasks
1. **Writing R Code:** Respect train/test splitting rules. Do not use `y_test` unless in `04_holdout.R`.
2. **Drafting LaTeX:** Follow math conventions, reference generated output files.
3. **Explaining Output:** Interpret statistical model outputs (e.g., coefficient shrinkage, selected variables) when requested.
4. **Math Derivations:** Formally derive solutions (e.g., Ridge closed-form, Lasso subgradients).
