# 👥 Contributing & Task Tracker — Group 01

This document outlines the Git workflow, guidelines, role assignments, and detailed tasks for Group 01.

---

## 👥 Roster & Main Roles

| Member | Student ID | Primary Role | Assigned R Files | Assigned Report Sections |
|:---|:---|:---|:---|:---|
| **Loc** (P1) | `24125093` | Data & EDA | `setup.R`, `01_data_prep_eda.R` | `00_authorship.tex`, `01_prediction_design.tex` |
| **Tuan** (P2) | `24125107` | OLS & Ridge | `02_ols.R`, `02_ridge.R` | `02_ols_ridge_lasso.tex` (Sec 2.1, 2.2) |
| **Thuan** (P3) | `24125105` | Lasso & Comparison | `02_lasso.R`, `02_comparison.R` | `02_ols_ridge_lasso.tex` (Sec 2.3, 2.4, 2.5) |
| **Triet** (P4) | `24125047` | Math Derivations | *(None)* | `03_math_mechanisms.tex` (Sec 3.1, 3.2, 3.3) |
| **Tai** (P5) | `24125078` | Elastic Net, Neural & Integration | `04_enet.R`, `04_neural.R`, `04_holdout.R` | `00_abstract.tex`, `04_elastic_net.tex`, `05_report_quality.tex` |

---

## 🐙 Git Workflow & Guidelines

### Workflow Steps
1. **Pull latest changes** before you start working:
   ```bash
   git pull origin main
   ```
2. **Commit daily** (or when a component works). Prefix your commit message with your role:
   ```bash
   git add -A
   git commit -m "P2: add ridge CV plot and lambda table"
   git push origin main
   ```

### Commit Message Prefix Format
- `P<number>: <short description>`
  - *Example:* `P1: generate EDA correlation heatmap`
  - *Example:* `P2: implement OLS baseline and residual plots`
  - *Example:* `P3: add lasso coefficient path analysis`
  - *Example:* `P4: derive soft-thresholding formula in LaTeX`
  - *Example:* `P5: elastic net alpha grid comparison`

---

## 🛠️ Development & Execution Guidelines

### File Access Permissions
- **Loc (P1)**: `R_models/setup.R`, `R_models/01_data_prep_eda.R`, `LaTeX_report/sections/00_authorship.tex`, `LaTeX_report/sections/01_prediction_design.tex`
- **Tuan (P2)**: `R_models/02_ols.R`, `R_models/02_ridge.R`, OLS/Ridge parts of `LaTeX_report/sections/02_ols_ridge_lasso.tex`
- **Thuan (P3)**: `R_models/02_lasso.R`, `R_models/02_comparison.R`, Lasso/comparison parts of `LaTeX_report/sections/02_ols_ridge_lasso.tex`
- **Triet (P4)**: `LaTeX_report/sections/03_math_mechanisms.tex`
- **Tai (P5)**: `R_models/04_enet.R`, `R_models/04_neural.R`, `R_models/04_holdout.R`, `LaTeX_report/sections/04_elastic_net.tex`, `LaTeX_report/sections/05_report_quality.tex`, `LaTeX_report/sections/00_abstract.tex`

### Shared Coordination Files
- `R_models/setup.R` — Shared configuration and helper functions (owned by P1, used by all).
- `LaTeX_report/main.tex` — Main document template (rarely needs editing).
- `LaTeX_report/preamble.sty` — Packages & macros (discuss with group before adding new packages).
- `LaTeX_report/references.bib` — Bibliography (anyone can add references).
- `Makefile` — Build automation.

### Step-by-step Execution Order
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
Rscript R_models/04_holdout.R       # needs ALL model fits, run LAST

# Step 3: Compile LaTeX report
cd LaTeX_report
latexmk -pdf main.tex
```

---

## 📅 Detailed Task List by Phase

Update the status (`[ ]` to `[x]`) as you complete each task.

### Phase 1: Environment Setup & Foundation
*Target: Days 1–2*

#### Loc (P1) — Project Foundation
- [ ] Run `01_data_prep_eda.R` to load `fat.csv`, perform the train/test split (80/20), standardise the data using `fit_scaler`/`apply_scaler`, and generate `shared_data.RData`.
- [ ] Ensure that `output/figures/` and `output/tables/` are populated with:
  - `fig_p1_correlation.pdf` (Correlation matrix heatmap)
  - `fig_p1_dist.pdf` (Histogram of `brozek`)
  - `fig_p1_boxplots.pdf` (Boxplots of training predictors)
  - `fig_p1_pairwise.pdf` (Scatter plot matrix of highly correlated predictors)
  - `tab_p1_summary.tex` (LaTeX table of training summary statistics)
- [ ] Write the first draft of `LaTeX_report/sections/01_prediction_design.tex` outlining tasks, dataset scaling, CV generation, and preventing data leakage.
- [ ] Populate student name and ID in `LaTeX_report/sections/00_authorship.tex`.

### Phase 2: Core Linear & Regularized Models
*Target: Days 3–5*

#### Tuan (P2) — OLS & Ridge Regression
- [ ] Run `02_ols.R` to fit OLS. Generate baseline coefficients, residuals plot, Q-Q diagnostics, and save model objects.
- [ ] Run `02_ridge.R` to fit Ridge. Generate CV curves vs lambda, coefficient shrinkage paths, condition numbers comparison, and coefficient bar charts.
- [ ] Draft OLS and Ridge subsections in `LaTeX_report/sections/02_ols_ridge_lasso.tex`.

#### Thuan (P3) — Lasso & Model Comparison
- [ ] Run `02_lasso.R` to fit Lasso. Generate CV curves vs lambda, coefficient paths, selected/nonzero coefficients summary table, and save model objects.
- [ ] Run `02_comparison.R` to aggregate training metrics and check stability. Generate comparison charts and perturbation plots.
- [ ] Draft Lasso, Model Selection, and Perturbation check subsections in `LaTeX_report/sections/02_ols_ridge_lasso.tex`.
- [ ] Nominate the **Core Model** inside the boxed environment with a clear training-data justification before testing.

### Phase 3: Theory & Math Proofs
*Target: Days 3–5 (Runs in parallel with Phase 2)*

#### Triet (P4) — Mathematical Mechanisms
- [ ] Draft Section 3 mathematical proofs in `LaTeX_report/sections/03_math_mechanisms.tex`:
  - **Ridge Derivation (3A):** Derivation of the closed-form Ridge solution. Explain invertibility and conditioning.
  - **Lasso Optimality (3B):** Derive subgradient optimality and soft-thresholding operator closed-form solutions for orthonormal designs.
  - **Connection to Evidence (3C):** Link mathematical properties to the empirical results generated in Phase 2.

### Phase 4: Elastic Net & Fixed ReLU Features
*Target: Days 5–7*

#### Tai (P5) — Elastic Net & Neural Features
- [ ] Run `04_enet.R` to fit Elastic Net on original predictors over a grid of alpha. Generate CV curves, coefficients list, and save model.
- [ ] Run `04_neural.R` to generate 200 random ReLU features. Fit Ridge, Lasso, and Elastic Net on these new features and compile CV metrics.
- [ ] Draft Elastic Net and Neural Features subsections in `LaTeX_report/sections/04_elastic_net.tex`.
- [ ] Fill out the literature Source Map in Section 4.1.

### Phase 5: Locked Holdout Evaluation & Report Polish
*Target: Days 7–10*

#### Tai (P5) — Integration & Holdout Evaluation
- [ ] Lock down all configurations and choices.
- [ ] Run `04_holdout.R` (the ONLY script allowed to load `y_test`). Evaluate OLS, Ridge, Lasso, Elastic Net, and Neural feature models. Generate holdout RMSE/MAE comparison charts, scatter plots of actual vs. predicted values, and tables.
- [ ] Complete Section 4.4 holdout analysis and Section 4.5 connection to deep learning.
- [ ] Draft the **Abstract** (`00_abstract.tex`) and the **Recommendation and Limitations** section (`05_report_quality.tex`).

---

## 🚨 Checklist Before Submitting

- [ ] All R scripts run without error from a clean session.
- [ ] `make clean && make all` produces the final PDF.
- [ ] No `y_test` usage outside `04_holdout.R`.
- [ ] All TODO comments resolved.
- [ ] AI log (`Group01_AI_Log.csv`) is complete.
- [ ] Abstract is ≤ 150 words.
- [ ] All team members can explain the full analysis.
