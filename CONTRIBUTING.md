# 👥 Contributing & Task Tracker — Group 01

## 👥 Roster & Main Roles

| Member | Student ID | Primary Role | Assigned R Files | Assigned Report Sections |
|:---|:---|:---|:---|:---|
| **Nguyễn Đình Thiên Lộc** (P1) | `24125093` | Data & EDA | `setup.R`, `01_data_prep_eda.R` | `00_authorship.tex`, `01_prediction_design.tex` |
| **Trần Lê Anh Tuấn** (P2) | `24125107` | OLS & Ridge | `02_ols.R`, `02_ridge.R` | `02_ols_ridge_lasso.tex` (Sec 2.1, 2.2) |
| **Lê Minh Thuận** (P3) | `24125105` | Lasso & Comparison | `02_lasso.R`, `02_comparison.R` | `02_ols_ridge_lasso.tex` (Sec 2.3, 2.4, 2.5) |
| **Nguyễn Bảo Minh Triết** (P4) | `24125047` | Math Derivations | *(None)* | `03_math_mechanisms.tex` (Sec 3.1, 3.2, 3.3) |
| **Nguyễn Hồng Tấn Tài** (P5) | `24125078` | Elastic Net, Neural & Integration | `04_enet.R`, `04_neural.R`, `04_holdout.R` | `00_abstract.tex`, `04_elastic_net.tex`, `05_report_quality.tex` |

*(Do not edit other members' files without asking!)*

## 🐙 Git Workflow & Branching Guidelines
We use individual branches for each member to prevent conflicts. 
**Before starting your work, switch to your dedicated branch and read your personal `TODO.md` file located in the `members/` folder!**

- **Nguyễn Đình Thiên Lộc (P1):**
  - Branch: `feature/p1-loc-data-eda`
  - Workspace: `members/P1_Loc/TODO.md`
- **Trần Lê Anh Tuấn (P2):**
  - Branch: `feature/p2-tuan-ols-ridge`
  - Workspace: `members/P2_Tuan/TODO.md`
- **Lê Minh Thuận (P3):**
  - Branch: `feature/p3-thuan-lasso-compare`
  - Workspace: `members/P3_Thuan/TODO.md`
- **Nguyễn Bảo Minh Triết (P4):**
  - Branch: `feature/p4-triet-math`
  - Workspace: `members/P4_Triet/TODO.md`
- **Nguyễn Hồng Tấn Tài (P5):**
  - Branch: `feature/p5-tai-enet-neural`
  - Workspace: `members/P5_Tai/TODO.md`

1. **Pull & Checkout:** `git pull origin main` then `git checkout feature/<your-branch>`
2. **Commit:** Prefix with your role, e.g., `git commit -m "P2: add ridge CV plot"`
3. **Push:** `git push origin feature/<your-branch>` (then open a Pull Request)

## 🏃 Execution Order
If not using `make all`, run scripts strictly in this order:
1. `Rscript -e "renv::restore(prompt = FALSE)"` (Restores the locked R environment)
2. `Rscript R_models/01_data_prep_eda.R` (Generates shared data)
3. `Rscript R_models/02_ols.R`, `02_ridge.R`, `02_lasso.R`, `04_enet.R`, `04_neural.R` (Parallel)
4. `Rscript R_models/02_comparison.R` (Needs OLS/Ridge/Lasso)
5. `Rscript R_models/04_holdout.R` (Needs ALL fits)
6. `cd report && latexmk -xelatex main.tex`

## 📅 Task Tracker

**Overall status: approximately 90%.** The statistical pipeline and report
content are substantially complete, but the generated figures still require a
source-level visual-quality pass before the submission is final.

### Phase 1: Foundation (Nguyễn Đình Thiên Lộc / P1)
- [x] Run `01_data_prep_eda.R`, split data, generate `shared_data.RData`.
- [x] Generate EDA figures (`fig_p1_correlation.pdf`, etc.) and summary table.
- [x] Draft Section 1 in LaTeX. Fill authorship info.

### Phase 2: Core Models (Trần Lê Anh Tuấn / P2 & Lê Minh Thuận / P3)
- [x] **P2:** Run `02_ols.R` & `02_ridge.R`. Generate baselines, CV curves, coeff paths.
- [x] **P2:** Draft Sections 2.1 & 2.2 in LaTeX.
- [x] **P3:** Run `02_lasso.R` & `02_comparison.R`. Generate Lasso outputs and comparisons.
- [x] **P3:** Draft Sections 2.3, 2.4, 2.5 in LaTeX. Nominate **Core Model**.

### Phase 3: Math Proofs (Nguyễn Bảo Minh Triết / P4)
- [x] **P4:** Draft Section 3 (Ridge closed-form, Lasso optimality, Evidence connection).

### Phase 4: Elastic Net & Neural Features (Nguyễn Hồng Tấn Tài / P5)
- [x] **P5:** Run `04_enet.R` & `04_neural.R`. Generate Elastic Net and ReLU feature metrics.
- [x] **P5:** Draft Section 4.1, 4.2, 4.3. Fill literature source map.

### Phase 5: Holdout & Polish (Nguyễn Hồng Tấn Tài / P5)
- [x] **P5:** Run `04_holdout.R` (use `y_test`). Generate final comparisons.
- [x] **P5:** Draft Sections 4.4, 4.5, 5, and Abstract.
- [x] **All:** Verify the complete R pipeline runs cleanly via `R_models/00_run_all.R`.
- [ ] **All:** Complete the final visual-quality review and resolve its findings.
- [x] **All:** Prepare a draft submission folder with RMarkdown, BibTeX references, and replication README.

### Phase 6: Figure Generation and Final Polish (All)
- [ ] **P1:** Refactor EDA figure generation in `01_data_prep_eda.R`; coordinate reusable plotting defaults in `setup.R`.
- [ ] **P2:** Refactor OLS and Ridge figure generation in `02_ols.R` and `02_ridge.R`.
- [ ] **P3:** Refactor Lasso and comparison figure generation in `02_lasso.R` and `02_comparison.R`.
- [ ] **P4:** Audit mathematical correctness and legibility, then send figure-specific feedback to each R-file owner.
- [ ] **P5:** Refactor Elastic Net, neural-feature, and holdout figure generation in `04_enet.R`, `04_neural.R`, and `04_holdout.R`.
- [ ] **All:** Re-run the full pipeline, compile the report, and inspect every figure at its final report size.

For this phase, fix plots in the assigned R source files. Do not hand-edit
generated PDFs, change asset filenames, or alter validated statistical results
solely for appearance.

**Latest verified run (2026-07-16):** All eight analysis scripts completed successfully.
Lasso was selected using training CV and achieved the best holdout RMSE (4.2514).
The XeLaTeX report builds successfully, but figure aesthetics remain the final
major work item before submission.
