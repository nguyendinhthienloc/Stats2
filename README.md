# STAT452 Final Project - Group 8

This repository is the active workspace for STAT452 Project 03, **Wine Quality (Red)**. The supplied data contain 1,599 red wines, 11 physicochemical predictors, and the `quality` response.

The project has two required parts:

1. A supervised-learning workflow for Wine Quality (Red): EDA, cleaning, feature selection, a baseline, at least two regularized models, and held-out evaluation.
2. A separate experimental-design study using two-factor ANOVA or a `2^k` factorial design with `k >= 2`.

Part 1 is a regression analysis of the quality score. The locked protocol uses an 80/20 stratified train/holdout split, five shared cross-validation folds, RMSE as the primary metric, and MAE and R-squared as secondary metrics.

## Group 8

| No. | Member | Student ID |
|---:|---|---:|
| 1 | Trần Lê Anh Tuấn | 24125107 |
| 2 | Nguyễn Bảo Minh Triết | 24125047 |
| 3 | Nguyễn Đình Thiên Lộc | 24125093 |
| 4 | Nguyễn Hồng Tấn Tài | 24125078 |
| 5 | Lê Minh Thuận | 24125105 |

## Repository map

| Path | Purpose |
|---|---|
| `analysis/` | Ordered R analysis scripts |
| `R/` | Shared configuration and reusable functions |
| `data/raw/` | Immutable supplied source data |
| `data/processed/` | Reproducible derived datasets |
| `output/` | Generated figures, tables, and model objects |
| `report/` | Final report source and generated PDF |
| `finals/part1/` | Part 1 implementation and report modules |
| `finals/part2/` | Five owned Part 2 analysis/report modules and collaboration plan |
| `presentation/` | Presentation source and final deck |
| `scripts/` | Restore, reproduce, and validation commands |
| `references/` | Course briefs, group assignment, notes, and labs |
| `legacy/midterm/` | Read-only Applied Statistics II midterm history |

The ordered scripts at the repository root are the canonical workflow. They
incorporate the completed Part 1 modules under `finals/part1/`; do not run the
retired nested entry points as a second pipeline. All source data, derived
data, and generated artifacts use the root `data/` and `output/` directories;
`finals/part1/` contains Part 1 implementation and report source only. Part 2
source is split into five owned modules under `finals/part2/` and is integrated
by `analysis/05_part2_experimental_design.R`.

## What to install

Use these versions and tools on every computer:

- **R 4.5.2**, exactly as recorded in `renv.lock`.
- **Pandoc 2.0 or newer**. RStudio and Quarto normally include it.
- **XeLaTeX** for the PDF report. MiKTeX is the documented and CI-tested distribution; TinyTeX or TeX Live also work when they provide `xelatex` on `PATH`.
- Git, if cloning the repository.
- Internet access for the first R package restore and any MiKTeX packages needed by the report.

R packages are handled by `renv`; do not install them manually before the first run. If R must compile a package, Windows needs Rtools 4.5, macOS needs Xcode Command Line Tools and compatible GNU Fortran, and Ubuntu/Debian needs `build-essential` and `gfortran`.

### MiKTeX setup

Windows:

1. Download and run the [Basic MiKTeX Installer](https://miktex.org/download).
2. Choose a private per-user installation.
3. Set **Install missing packages on-the-fly** to **Always**.
4. Close and reopen PowerShell or Command Prompt.

macOS:

1. Install MiKTeX from the [official macOS instructions](https://miktex.org/howto/install-miktex-mac).
2. Finish the private setup in MiKTeX Console and enable automatic installation of missing packages.
3. If `xelatex` is not found, add MiKTeX's private `~/bin` directory to your terminal `PATH` using the [official PATH instructions](https://miktex.org/howto/modify-path).

Linux:

Follow the commands for your distribution on the [official MiKTeX download page](https://miktex.org/download), then finish the setup and enable automatic package installation. For Ubuntu 24.04, the commands are:

```sh
sudo apt-get update
sudo apt-get install -y curl gnupg
curl -fsSL https://miktex.org/download/key | sudo gpg --dearmor -o /usr/share/keyrings/miktex.gpg
echo "deb [signed-by=/usr/share/keyrings/miktex.gpg] https://miktex.org/download/ubuntu noble universe" | sudo tee /etc/apt/sources.list.d/miktex.list
sudo apt-get update
sudo apt-get install -y miktex
sudo miktexsetup --shared=yes finish
sudo initexmf --admin --set-config-value='[MPM]AutoInstall=1'
```

#### Fedora setup

These instructions target Fedora 43 or 44 on x86-64. Install the build tools and Pandoc first:

```sh
sudo dnf install -y git curl gcc gcc-c++ gcc-gfortran make libxml2-devel pandoc
```

Fedora normally provides the newest R release, but this project requires exactly R 4.5.2. Install `rig`, then use it to install and select that version:

```sh
sudo dnf install -y https://github.com/r-lib/rig/releases/download/latest/r-rig-latest-1.$(arch).rpm
rig add 4.5.2
rig default 4.5.2
Rscript --version
```

Install MiKTeX from its Fedora repository. This example is for Fedora 44; replace `44` with `43` when using Fedora 43:

```sh
sudo rpm --import https://miktex.org/download/key
sudo curl -L -o /etc/yum.repos.d/miktex.repo https://miktex.org/download/fedora/44/miktex.repo
sudo dnf install -y miktex
sudo miktexsetup --shared=yes finish
sudo initexmf --admin --set-config-value='[MPM]AutoInstall=1'
xelatex --version
```

After cloning the repository, use the same project commands shown below. Fedora is supported by the documented tools, although the GitHub-hosted CI matrix currently tests Ubuntu, Windows, and macOS rather than Fedora.

On every operating system, open a new terminal and verify the tools before rendering:

```text
Rscript --version
pandoc --version
xelatex --version
```

The first command must report R 4.5.2. The last command must identify a working XeLaTeX installation.

XeLaTeX is the Unicode-capable compiler required for the Vietnamese member names. MiKTeX remains the team's recommended distribution and the one exercised by report CI.

## First run in RStudio

1. Clone the repository and open `Stats2.Rproj` in RStudio. Do not open an individual script as a standalone project.
2. In **Tools > Global Options > General > R version**, select **R 4.5.2**, then restart RStudio if requested.
3. Confirm that the Console working directory is the repository root with `getwd()`.
4. Restore the locked packages once:

   ```r
   renv::restore()
   ```

5. Run the canonical pipeline:

   ```r
   source('analysis/00_run_all.R')
   ```

The runner executes the numbered stages in order. Develop in individual stages only when their prerequisites already exist; use `00_run_all.R` for a complete reproducibility check.

Generated files belong under `data/processed/` and `output/`. Never hand-edit them: change the owning R source and rerun the pipeline.

## First run from a clean clone in a terminal

Open PowerShell, Command Prompt, macOS Terminal, or a Linux terminal. Clone the repository, enter its root folder, and run:

```text
git clone https://github.com/nguyendinhthienloc/Stats2.git
cd Stats2
Rscript --vanilla scripts/reproduce.R
```

That one R command:

1. bootstraps the `renv` version in `renv.lock`;
2. restores the exact locked R package versions;
3. checks the R version, dependency declarations, lockfile, repository, and dataset;
4. runs `analysis/00_run_all.R` in the required order.

To run the same workflow and render the PDF with the configured XeLaTeX:

```text
Rscript --vanilla scripts/reproduce.R --report
```

Run commands from the repository root. The direct `Rscript` commands are the cross-platform interface. A root `Makefile` provides optional shortcuts for members who already have Make; Make is not required by RStudio or CI.

## Useful terminal commands

```text
Rscript --vanilla scripts/restore.R
Rscript --vanilla scripts/ci_check.R
Rscript --vanilla analysis/00_run_all.R
Rscript --vanilla scripts/validate_outputs.R
Rscript --vanilla scripts/reproduce.R
Rscript --vanilla scripts/reproduce.R --report
```

These commands restore packages, check source/configuration, run the ordered
analysis, validate generated artifacts and the holdout boundary, reproduce
everything, and reproduce everything plus the PDF report. They work in
PowerShell, Command Prompt, macOS Terminal, and Linux shells.

Optional Make equivalents are `make restore`, `make check`, `make analysis`,
`make verify`, and `make report`.

## Why the restore is portable

`renv.lock`, `renv/activate.R`, and `.Rprofile` are tracked. The generated `renv/library/` directory is ignored. Each computer restores its own operating-system-specific project library from the same lockfile, so never copy or commit another member's `renv/library/` directory.

The R `languageserver` package is also restored by `renv`, so supported editors can provide completion, diagnostics, and navigation inside this isolated project environment.

The restore is strict and non-interactive. It fails clearly if the active R version is not 4.5.2, a declared package is absent from the lockfile, or the restored library and lockfile disagree.

## Updating R dependencies

When intentionally adding or upgrading an R package:

1. Add it to `Imports` in `DESCRIPTION`.
2. Install it in the project library:

   ```text
   Rscript -e "renv::install('package-name')"
   ```

3. Update the lockfile:

   ```text
   Rscript -e "renv::snapshot(prompt = FALSE)"
   ```

4. Re-run the project and commit `DESCRIPTION` and `renv.lock` together:

   ```text
   Rscript --vanilla scripts/reproduce.R
   ```

Do not edit `renv.lock` manually.

## Data and modelling safeguards

- Project seed: `4520803`.
- Model the numeric quality score as a regression response.
- Use the locked 80/20 stratified split and five shared cross-validation folds.
- Compare models by RMSE first, with MAE and R-squared as secondary metrics.
- Treat `data/raw/` as immutable.
- Generate derived data under `data/processed/`.
- Fit preprocessing, feature selection, and tuning on training/resampling data only.
- Inspect held-out test outcomes only in `analysis/04_holdout_evaluation.R`.
- Run the stages through `analysis/00_run_all.R`, not in an arbitrary order.

## Five Part 1 workstreams

This ownership split mirrors `finals/part1/collaboration/WORK_SPLIT.md`. Ownership coordinates review and handoffs; the final contribution statement must describe work that each member actually reviewed and completed.

| Section | Lead | Canonical stage |
|---|---|---|
| 1. Exploratory data analysis | Nguyễn Đình Thiên Lộc (`24125093`) | `analysis/01_eda_cleaning.R` (EDA outputs) |
| 2. Data cleaning | Trần Lê Anh Tuấn (`24125107`) | `analysis/01_eda_cleaning.R` (cleaning and preprocessing outputs) |
| 3. Feature selection | Lê Minh Thuận (`24125105`) | `analysis/02_feature_selection.R` |
| 4. Modelling with regularization | Nguyễn Bảo Minh Triết (`24125047`) | `analysis/03_regularized_models.R` |
| 5. Held-out evaluation | Nguyễn Hồng Tấn Tài (`24125078`) | `analysis/04_holdout_evaluation.R` |

Each lead hands generated artifacts to the next section, and a second member reviews the code and statistical interpretation. Sections 1--4 must not inspect held-out outcomes.

## Five Part 2 workstreams

Part 2 uses all 1,000 Student Performance rows in an observational two-factor
analysis of mathematics score by test preparation and lunch category. Dataset
discovery is excluded from contribution credit. The Part 2 tasks compensate for
the estimated Part 1 burden so every member has a combined target of 6.5
planning units; see `finals/part2/collaboration/WORK_SPLIT.md` for the calculation,
section contracts, and cross-review ring.

| Section | Proposed owner | Canonical module |
|---|---|---|
| 1. Data audit, design, and hypotheses | Nguyen Dinh Thien Loc (`24125093`) | `finals/part2/R/01_data_audit_design.R` |
| 2. Descriptive statistics and plots | Tran Le Anh Tuan (`24125107`) | `finals/part2/R/02_descriptive_visualization.R` |
| 3. Factorial ANOVA and effect sizes | Le Minh Thuan (`24125105`) | `finals/part2/R/03_factorial_anova.R` |
| 4. Diagnostics and adjusted follow-up | Nguyen Hong Tan Tai (`24125078`) | `finals/part2/R/04_diagnostics_posthoc.R` |
| 5. Interpretation and integration | Nguyen Bao Minh Triet (`24125047`) | `finals/part2/R/05_interpretation_integration.R` |

## Continuous integration

CI runs the analysis command on Ubuntu, Windows, and macOS with R 4.5.2. A separate Ubuntu job installs MiKTeX from its official repository and runs the report command. This keeps cross-platform analysis checks fast while testing the exact documented PDF toolchain.

GitHub branch protection still must be enabled before CI can be required for merges. Submission artifacts are assembled manually after CI passes.

## Deliverables

- PDF report, at most 20 pages excluding appendices.
- Reproducible R Markdown and R source that run top-to-bottom.
- Ten-minute presentation.

See [TODO.md](TODO.md) for the requirement checklist and open decisions.
